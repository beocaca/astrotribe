-- ============================================================================
-- MIGRATION: Graph Layer Infrastructure
-- Generated: 2025-06-03
-- Purpose: Implement knowledge graph with partitioned edges and node mapping
-- ============================================================================

SET check_function_bodies = off;

-- ============================================================================
-- SEQUENCES
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS public.allowed_edge_types_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.graph_edges_id_seq;

-- ============================================================================
-- TABLE MODIFICATIONS
-- ============================================================================

-- Modernize categories table structure
DO $$ BEGIN
    -- Drop obsolete columns if they exist
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='description') THEN
        ALTER TABLE public.categories DROP COLUMN description, DROP COLUMN locale, DROP COLUMN name, 
                                        DROP COLUMN published_at, DROP COLUMN published_at_timestamptz;
    END IF;
    
    -- Add new columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='title') THEN
        ALTER TABLE public.categories 
            ADD COLUMN title text NOT NULL DEFAULT 'Untitled',
            ADD COLUMN slug text,
            ADD COLUMN summary text;
        
        -- Remove default after adding
        ALTER TABLE public.categories ALTER COLUMN title DROP DEFAULT;
    END IF;
END $$;

-- Enhance people table for graph relationships
DO $$ BEGIN
    -- Drop obsolete columns if they exist
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='people' AND column_name='affiliation') THEN
        ALTER TABLE public.people DROP COLUMN affiliation, DROP COLUMN email, DROP COLUMN orcid, DROP COLUMN role;
    END IF;
    
    -- Add new columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='people' AND column_name='user_id') THEN
        ALTER TABLE public.people 
            ADD COLUMN user_id uuid REFERENCES public.user_profiles(id) ON DELETE SET NULL,
            ADD COLUMN birth_year integer,
            ADD COLUMN death_year integer,
            ADD COLUMN career_level text,
            ADD COLUMN nationality text,
            ADD COLUMN honorific_prefix text,
            ADD COLUMN description text;
    END IF;
    
    -- Add constraints
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name='people_career_level_check') THEN
        ALTER TABLE public.people ADD CONSTRAINT people_career_level_check 
            CHECK (career_level = ANY (ARRAY['student', 'postdoc', 'faculty', 'emeritus', 'industry', 'government', 'independent', 'historical', 'pioneer', 'deceased_historical']));
    END IF;
    
    -- Add unique constraint on user_id
    IF NOT EXISTS (
      SELECT 1 FROM pg_indexes WHERE tablename = 'people' AND indexname = 'people_user_id_unique'
    ) THEN
        CREATE UNIQUE INDEX people_user_id_unique ON public.people(user_id) WHERE user_id IS NOT NULL;
    END IF;
END $$;

-- ============================================================================
-- CORE GRAPH TABLES
-- ============================================================================

-- Edge type configuration table
CREATE TABLE IF NOT EXISTS public.allowed_edge_types (
    id integer NOT NULL DEFAULT nextval('public.allowed_edge_types_id_seq'::regclass) PRIMARY KEY,
    source_type text NOT NULL,
    target_type text NOT NULL,
    edge_type text NOT NULL,
    description text,
    is_ai_inferable boolean DEFAULT true,
    confidence_threshold double precision DEFAULT 0.7,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);

-- Main partitioned graph edges table
CREATE TABLE IF NOT EXISTS public.graph_edges (
    id bigint NOT NULL DEFAULT nextval('public.graph_edges_id_seq'::regclass),
    source_type text NOT NULL,
    source_id uuid NOT NULL,
    target_type text NOT NULL,
    target_id uuid NOT NULL,
    edge_type text NOT NULL,
    weight double precision DEFAULT 1.0,
    confidence double precision DEFAULT 1.0,
    ai_model text,
    evidence_metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    -- Performance optimization columns
    phase1_int_source integer,
    phase1_int_target integer,
    -- Composite primary key for partitioning
    PRIMARY KEY (id, edge_type)
) PARTITION BY LIST (edge_type);

-- Topic clusters for performance optimization
create table "public"."topic_clusters" (
    "topic_id" uuid not null,
    "topic_bigint_id" bigint not null,
    "last_computed" timestamp with time zone default now(),
    "people_bigint_ids" bigint[] default '{}'::bigint[],
    "research_bigint_ids" bigint[] default '{}'::bigint[],
    "news_bigint_ids" bigint[] default '{}'::bigint[],
    "organization_bigint_ids" bigint[] default '{}'::bigint[],
    "total_entities" integer generated always as ((((
        coalesce(array_length(people_bigint_ids, 1), 0) + 
        coalesce(array_length(research_bigint_ids, 1), 0)
    ) + coalesce(array_length(news_bigint_ids, 1), 0)) + 
    coalesce(array_length(organization_bigint_ids, 1), 0))) stored,
    "created_at" timestamp with time zone not null default now()
);


-- ============================================================================
-- GRAPH EDGE PARTITIONS
-- ============================================================================

-- Authorship relationships (author -> content)
CREATE TABLE IF NOT EXISTS public.graph_edges_authorship 
    PARTITION OF public.graph_edges 
    FOR VALUES IN ('authored_by', 'published_by');

-- Citation relationships (content -> content)
CREATE TABLE IF NOT EXISTS public.graph_edges_citation 
    PARTITION OF public.graph_edges 
    FOR VALUES IN ('cites', 'referenced_by', 'builds_on');

-- Organizational relationships (person -> organization)
CREATE TABLE IF NOT EXISTS public.graph_edges_organizational 
    PARTITION OF public.graph_edges 
    FOR VALUES IN ('affiliated_with', 'employed_by');

-- Semantic relationships (content -> topic/tag)
CREATE TABLE IF NOT EXISTS public.graph_edges_semantic 
    PARTITION OF public.graph_edges 
    FOR VALUES IN ('tagged_with', 'mentions', 'related_to');

-- Experimental/other relationships (catch-all)
CREATE TABLE IF NOT EXISTS public.graph_edges_experimental 
    PARTITION OF public.graph_edges DEFAULT;



-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Validate edge types against allowed configurations
CREATE OR REPLACE FUNCTION public.validate_edge_type()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.allowed_edge_types 
        WHERE source_type = NEW.source_type 
          AND target_type = NEW.target_type 
          AND edge_type = NEW.edge_type 
          AND is_active = true
          AND NEW.confidence >= confidence_threshold
    ) THEN
        RAISE EXCEPTION 'Invalid edge type: % from % to % with confidence %. Check allowed_edge_types table.', 
            NEW.edge_type, NEW.source_type, NEW.target_type, NEW.confidence;
    END IF;
    
    RETURN NEW;
END;
$function$;


CREATE OR REPLACE FUNCTION public.populate_topic_clusters_batch(p_batch_size integer DEFAULT 10, p_min_confidence double precision DEFAULT 0.7)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  topic_batch uuid[];
  current_topic uuid;
  topic_bigint BIGINT;
  batch_start_time timestamp;
  topic_start_time timestamp;
  topic_duration interval;
  topics_processed integer := 0;
  entities_found integer;
  batch_display_text text;
BEGIN
  RAISE NOTICE 'Starting topic clusters population (batch size: %, min confidence: %)', 
    p_batch_size, p_min_confidence;
  
  -- Get batch of topic IDs that need processing
  SELECT array_agg(id) INTO topic_batch
  FROM (
    SELECT t.id 
    FROM public.topics t
    LEFT JOIN public.topic_clusters tc ON t.id = tc.topic_id
    WHERE tc.topic_id IS NULL  -- Only topics not yet processed
      AND t.bigint_id IS NOT NULL  -- Must have bigint mapping
    ORDER BY t.created_at DESC  -- Process newest first
    LIMIT p_batch_size
  ) batch_topics;
  
  IF topic_batch IS NULL OR array_length(topic_batch, 1) = 0 THEN
    RAISE NOTICE '✅ No topics need processing - all clusters up to date';
    RETURN;
  END IF;
  
  -- Display batch info
  IF array_length(topic_batch, 1) > 5 THEN
    batch_display_text := array_to_string(topic_batch[1:5], ', ') || ', ...';
  ELSE
    batch_display_text := array_to_string(topic_batch, ', ');
  END IF;
  
  RAISE NOTICE 'Processing % topics: %', 
    array_length(topic_batch, 1), 
    batch_display_text;
  
  batch_start_time := clock_timestamp();
  
  -- Process each topic individually for better error handling
  FOREACH current_topic IN ARRAY topic_batch LOOP
    topic_start_time := clock_timestamp();
    
    -- Get topic's bigint_id (CRITICAL: Use bigint_id from topics table)
    SELECT bigint_id INTO topic_bigint 
    FROM public.topics 
    WHERE id = current_topic;
    
    IF topic_bigint IS NULL THEN
      RAISE NOTICE '⚠️  Skipping topic % - no bigint_id mapping', current_topic;
      CONTINUE;
    END IF;
    
    RAISE NOTICE '  Processing topic % with bigint_id %', current_topic, topic_bigint;
    
    -- UPDATED: Use new column names (source_id instead of source_bigint_id)
    INSERT INTO public.topic_clusters (
      topic_id, 
      topic_bigint_id, 
      people_bigint_ids, 
      research_bigint_ids, 
      news_bigint_ids, 
      organization_bigint_ids
    )
    WITH all_edges AS (
      -- Semantic partition (entities → topics)
      SELECT source_type, source_id, confidence
      FROM public.graph_edges_semantic
      WHERE target_id = topic_bigint  -- UPDATED: target_id instead of target_bigint_id
        AND target_type = 'topic'            
        AND confidence >= p_min_confidence
        AND source_type IN ('person', 'research', 'news', 'organization')
        AND source_id IS NOT NULL  -- UPDATED: source_id instead of source_bigint_id
      
      UNION ALL
      
      -- Authorship partition  
      SELECT source_type, source_id, confidence
      FROM public.graph_edges_authorship
      WHERE target_id = topic_bigint 
        AND target_type = 'topic'
        AND confidence >= p_min_confidence
        AND source_type IN ('person', 'research', 'news', 'organization')
        AND source_id IS NOT NULL
      
      UNION ALL
      
      -- Citation partition
      SELECT source_type, source_id, confidence
      FROM public.graph_edges_citation
      WHERE target_id = topic_bigint 
        AND target_type = 'topic'
        AND confidence >= p_min_confidence
        AND source_type IN ('person', 'research', 'news', 'organization')
        AND source_id IS NOT NULL
      
      UNION ALL
      
      -- Organizational partition
      SELECT source_type, source_id, confidence
      FROM public.graph_edges_organizational
      WHERE target_id = topic_bigint 
        AND target_type = 'topic'
        AND confidence >= p_min_confidence
        AND source_type IN ('person', 'research', 'news', 'organization')
        AND source_id IS NOT NULL
      
      UNION ALL
      
      -- Experimental partition
      SELECT source_type, source_id, confidence
      FROM public.graph_edges_experimental
      WHERE target_id = topic_bigint 
        AND target_type = 'topic'
        AND confidence >= p_min_confidence
        AND source_type IN ('person', 'research', 'news', 'organization')
        AND source_id IS NOT NULL
    )
    SELECT 
      current_topic,
      topic_bigint,
      COALESCE(array_agg(DISTINCT source_id) FILTER (WHERE source_type = 'person'), '{}'),
      COALESCE(array_agg(DISTINCT source_id) FILTER (WHERE source_type = 'research'), '{}'),
      COALESCE(array_agg(DISTINCT source_id) FILTER (WHERE source_type = 'news'), '{}'),
      COALESCE(array_agg(DISTINCT source_id) FILTER (WHERE source_type = 'organization'), '{}')
    FROM all_edges
    ON CONFLICT (topic_id) DO UPDATE SET
      people_bigint_ids = EXCLUDED.people_bigint_ids,
      research_bigint_ids = EXCLUDED.research_bigint_ids,
      news_bigint_ids = EXCLUDED.news_bigint_ids,
      organization_bigint_ids = EXCLUDED.organization_bigint_ids,
      last_computed = now();
    
    -- Calculate entities found for this topic using BIGINT arrays
    SELECT 
      COALESCE(array_length(people_bigint_ids, 1), 0) + 
      COALESCE(array_length(research_bigint_ids, 1), 0) + 
      COALESCE(array_length(news_bigint_ids, 1), 0) + 
      COALESCE(array_length(organization_bigint_ids, 1), 0)
    INTO entities_found
    FROM public.topic_clusters 
    WHERE topic_id = current_topic;
    
    topics_processed := topics_processed + 1;
    topic_duration := clock_timestamp() - topic_start_time;
    
    RAISE NOTICE '  └─ Topic % (%/%): % entities found in %ms', 
      current_topic, 
      topics_processed, 
      array_length(topic_batch, 1),
      COALESCE(entities_found, 0),
      ROUND(EXTRACT(EPOCH FROM topic_duration) * 1000);
      
    -- Small delay to prevent overwhelming the database
    IF topics_processed % 5 = 0 THEN
      PERFORM pg_sleep(0.1);
    END IF;
    
  END LOOP;
  
  -- Final summary
  RAISE NOTICE '✅ Batch completed: % topics processed in %ms (avg: %ms per topic)', 
    topics_processed,
    ROUND(EXTRACT(EPOCH FROM (clock_timestamp() - batch_start_time)) * 1000),
    ROUND(EXTRACT(EPOCH FROM (clock_timestamp() - batch_start_time)) * 1000 / GREATEST(topics_processed, 1));
    
  -- Update table statistics for better query planning
  ANALYZE topic_clusters;
  
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE '❌ Error processing topic clusters: % - %', SQLSTATE, SQLERRM;
  RAISE;
END;
$function$
;


-- ============================================================================
-- SEQUENCE OWNERSHIP
-- ============================================================================

ALTER SEQUENCE public.allowed_edge_types_id_seq OWNED BY public.allowed_edge_types.id;
ALTER SEQUENCE public.graph_edges_id_seq OWNED BY public.graph_edges.id;

-- ============================================================================
-- ROW LEVEL SECURITY SETUP
-- ============================================================================

-- Enable RLS on new tables (policies will be applied separately)


alter table "public"."allowed_edge_types" 
    add column if not exists "updated_at" timestamp without time zone not null default now();

-- Graph edges unique constraint
alter table "public"."graph_edges" 
    add constraint "unique_graph_edge" 
    unique ("source_type", "source_id", "target_type", "target_id", "edge_type");




-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================