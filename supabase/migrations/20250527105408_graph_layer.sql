-- ============================================================================
-- GRAPH LAYER INFRASTRUCTURE MIGRATION
-- ============================================================================
-- Purpose: Knowledge graph with partitioned edges and node mapping
-- Date: 2025-06-03
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. SEQUENCES
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS public.allowed_edge_types_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.graph_edges_id_seq;


-- ============================================================================
-- 3. CORE GRAPH TABLES
-- ============================================================================

-- Edge type configuration table
CREATE TABLE IF NOT EXISTS public.allowed_edge_types (
   id INTEGER NOT NULL DEFAULT nextval('public.allowed_edge_types_id_seq'::regclass) PRIMARY KEY,
   source_type TEXT NOT NULL,
   target_type TEXT NOT NULL,
   edge_type TEXT NOT NULL,
   description TEXT,
   is_ai_inferable BOOLEAN DEFAULT true,
   confidence_threshold DOUBLE PRECISION DEFAULT 0.7,
   is_active BOOLEAN DEFAULT true,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Main partitioned graph edges table
CREATE TABLE IF NOT EXISTS public.graph_edges (
   id BIGINT NOT NULL DEFAULT nextval('public.graph_edges_id_seq'::regclass),
   source_type TEXT NOT NULL,
   source_id BIGINT NOT NULL,
   source_uuid_id UUID,
   target_type TEXT NOT NULL,
   target_id BIGINT NOT NULL,
   target_uuid_id UUID,
   edge_type TEXT NOT NULL,
   weight DOUBLE PRECISION DEFAULT 1.0,
   confidence DOUBLE PRECISION DEFAULT 1.0,
   ai_model TEXT,
   evidence_metadata JSONB,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   updated_at TIMESTAMPTZ DEFAULT NOW(),
   
   PRIMARY KEY (id, edge_type)
) PARTITION BY LIST (edge_type);


-- ============================================================================
-- 4. GRAPH EDGES OPTIMIZATION
-- ============================================================================


-- Topic clusters for performance optimization
CREATE TABLE IF NOT EXISTS public.topic_clusters (
   topic_id UUID NOT NULL,
   topic_bigint_id BIGINT NOT NULL,
   last_computed TIMESTAMPTZ DEFAULT NOW(),
   people_bigint_ids BIGINT[] DEFAULT '{}',
   research_bigint_ids BIGINT[] DEFAULT '{}',
   news_bigint_ids BIGINT[] DEFAULT '{}',
   organization_bigint_ids BIGINT[] DEFAULT '{}',
   total_entities INTEGER GENERATED ALWAYS AS (
       COALESCE(array_length(people_bigint_ids, 1), 0) + 
       COALESCE(array_length(research_bigint_ids, 1), 0) + 
       COALESCE(array_length(news_bigint_ids, 1), 0) + 
       COALESCE(array_length(organization_bigint_ids, 1), 0)
   ) STORED,
   created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 4. GRAPH EDGE PARTITIONS
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
-- 2. TABLE MODIFICATIONS
-- ============================================================================

-- Categories table modernization
DO $$ 
BEGIN
   -- Drop obsolete columns if they exist
   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='description') THEN
       ALTER TABLE public.categories 
           DROP COLUMN IF EXISTS description, 
           DROP COLUMN IF EXISTS locale, 
           DROP COLUMN IF EXISTS name, 
           DROP COLUMN IF EXISTS published_at, 
           DROP COLUMN IF EXISTS published_at_timestamptz;
   END IF;
   
   -- Add new columns if they don't exist
   IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='categories' AND column_name='title') THEN
       ALTER TABLE public.categories 
           ADD COLUMN title TEXT NOT NULL DEFAULT 'Untitled',
           ADD COLUMN slug TEXT,
           ADD COLUMN summary TEXT;
       
       -- Remove default after adding
       ALTER TABLE public.categories ALTER COLUMN title DROP DEFAULT;
   END IF;
END $$;

-- People table enhancement for graph relationships
DO $$ 
BEGIN
   -- Drop obsolete columns if they exist
   IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='people' AND column_name='affiliation') THEN
       ALTER TABLE public.people 
           DROP COLUMN IF EXISTS affiliation, 
           DROP COLUMN IF EXISTS email, 
           DROP COLUMN IF EXISTS orcid, 
           DROP COLUMN IF EXISTS role;
   END IF;
   
   -- Add new columns if they don't exist
   IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='people' AND column_name='user_id') THEN
       ALTER TABLE public.people 
           ADD COLUMN user_id UUID,
           ADD COLUMN birth_year INTEGER,
           ADD COLUMN death_year INTEGER,
           ADD COLUMN career_level TEXT,
           ADD COLUMN nationality TEXT,
           ADD COLUMN honorific_prefix TEXT,
           ADD COLUMN description TEXT;
   END IF;
END $$;

-- User profiles organization link
ALTER TABLE public.user_profiles 
   DROP COLUMN IF EXISTS primary_address_id,
   ADD COLUMN IF NOT EXISTS organization_id UUID;

-- Addresses organization link
ALTER TABLE public.addresses 
   DROP COLUMN IF EXISTS company_id,
   ADD COLUMN IF NOT EXISTS organization_id UUID NOT NULL;

-- Organizations classification
ALTER TABLE public.organizations 
   ADD COLUMN IF NOT EXISTS organization_type TEXT DEFAULT 'company';

-- User topics learning progression
ALTER TABLE public.user_topics 
   ADD COLUMN IF NOT EXISTS subscribed_at TIMESTAMPTZ;

-- Organization people timestamps
ALTER TABLE public.organization_people 
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Allowed edge types timestamps
ALTER TABLE public.allowed_edge_types 
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();



-- ============================================================================
-- 8. FUNCTIONS
-- ============================================================================

-- Validate edge types against allowed configurations
CREATE OR REPLACE FUNCTION public.validate_edge_type()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
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
$$;

-- Populate topic clusters batch processing
CREATE OR REPLACE FUNCTION public.populate_topic_clusters_batch(p_batch_size INTEGER DEFAULT 10, p_min_confidence DOUBLE PRECISION DEFAULT 0.7)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
   topic_batch UUID[];
   current_topic UUID;
   topic_bigint BIGINT;
   batch_start_time TIMESTAMP;
   topic_start_time TIMESTAMP;
   topic_duration INTERVAL;
   topics_processed INTEGER := 0;
   entities_found INTEGER;
   batch_display_text TEXT;
BEGIN
   RAISE NOTICE 'Starting topic clusters population (batch size: %, min confidence: %)', 
       p_batch_size, p_min_confidence;
   
   -- Get batch of topic IDs that need processing
   SELECT array_agg(id) INTO topic_batch
   FROM (
       SELECT t.id 
       FROM public.topics t
       LEFT JOIN public.topic_clusters tc ON t.id = tc.topic_id
       WHERE tc.topic_id IS NULL
         AND t.bigint_id IS NOT NULL
       ORDER BY t.created_at DESC
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
       
       -- Get topic's bigint_id
       SELECT bigint_id INTO topic_bigint 
       FROM public.topics 
       WHERE id = current_topic;
       
       IF topic_bigint IS NULL THEN
           RAISE NOTICE '⚠️  Skipping topic % - no bigint_id mapping', current_topic;
           CONTINUE;
       END IF;
       
       RAISE NOTICE '  Processing topic % with bigint_id %', current_topic, topic_bigint;
       
       -- Insert/update topic cluster
       INSERT INTO public.topic_clusters (
           topic_id, 
           topic_bigint_id, 
           people_bigint_ids, 
           research_bigint_ids, 
           news_bigint_ids, 
           organization_bigint_ids
       )
       WITH all_edges AS (
           SELECT source_type, source_id, confidence
           FROM public.graph_edges_semantic
           WHERE target_id = topic_bigint
             AND target_type = 'topic'            
             AND confidence >= p_min_confidence
             AND source_type IN ('person', 'research', 'news', 'organization')
             AND source_id IS NOT NULL
           
           UNION ALL
           
           SELECT source_type, source_id, confidence
           FROM public.graph_edges_authorship
           WHERE target_id = topic_bigint 
             AND target_type = 'topic'
             AND confidence >= p_min_confidence
             AND source_type IN ('person', 'research', 'news', 'organization')
             AND source_id IS NOT NULL
           
           UNION ALL
           
           SELECT source_type, source_id, confidence
           FROM public.graph_edges_citation
           WHERE target_id = topic_bigint 
             AND target_type = 'topic'
             AND confidence >= p_min_confidence
             AND source_type IN ('person', 'research', 'news', 'organization')
             AND source_id IS NOT NULL
           
           UNION ALL
           
           SELECT source_type, source_id, confidence
           FROM public.graph_edges_organizational
           WHERE target_id = topic_bigint 
             AND target_type = 'topic'
             AND confidence >= p_min_confidence
             AND source_type IN ('person', 'research', 'news', 'organization')
             AND source_id IS NOT NULL
           
           UNION ALL
           
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
           last_computed = NOW();
       
       -- Calculate entities found for this topic
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
$$;

-- ============================================================================
-- 9. SEQUENCE OWNERSHIP
-- ============================================================================

ALTER SEQUENCE public.allowed_edge_types_id_seq OWNED BY public.allowed_edge_types.id;
ALTER SEQUENCE public.graph_edges_id_seq OWNED BY public.graph_edges.id;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Populate allowed_edge_types table with application-specific edge configurations
-- 2. Test graph edge insertion and validation
-- 3. Run populate_topic_clusters_batch() to initialize topic clusters
-- 4. Set up monitoring for graph performance
-- ============================================================================