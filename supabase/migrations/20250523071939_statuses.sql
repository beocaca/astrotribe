-- ============================================================================
-- STATUS SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Complete status system with registry, history, and status columns
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;


-- ============================================================================
-- 2. CORE STATUS SYSTEM TABLES
-- ============================================================================

-- Status registry - central validation and metadata store
CREATE TABLE public.statuses (
   id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
   key TEXT NOT NULL,
   description TEXT,
   track TEXT NOT NULL,
   computed_column_name TEXT,
   computed_condition TEXT,
   is_computed BOOLEAN DEFAULT false,
   allowed_transitions TEXT[],
   is_terminal BOOLEAN DEFAULT false,
   priority INTEGER DEFAULT 0,
   color TEXT,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Status history - immutable audit trail for all status changes
CREATE TABLE public.status_history (
   id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
   record_id UUID NOT NULL,
   source_table TEXT NOT NULL,
   track TEXT NOT NULL,
   from_status TEXT,
   to_status TEXT NOT NULL,
   transitioned_at TIMESTAMPTZ DEFAULT NOW(),
   metadata JSONB,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 3. TABLE MODIFICATIONS - CONTENT TABLES
-- ============================================================================

-- News - News content (full status tracking)
ALTER TABLE public.news 
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS indexing_status TEXT DEFAULT 'pending',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED;

-- Research - Research papers (full status tracking)
ALTER TABLE public.research 
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS indexing_status TEXT DEFAULT 'pending',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Topics - Knowledge topics (full status tracking)
ALTER TABLE public.topics 
   DROP COLUMN IF EXISTS status_id,
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS indexing_status TEXT DEFAULT 'pending',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged', 'suspended', 'banned'])) STORED,
   ADD COLUMN IF NOT EXISTS is_indexed BOOLEAN GENERATED ALWAYS AS (indexing_status = 'indexed') STORED;

-- Categories - Content categorization
ALTER TABLE public.categories 
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged', 'suspended', 'banned'])) STORED;

-- Astronomy Events - Event calendar
ALTER TABLE public.astronomy_events 
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'published',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT,
   ADD COLUMN IF NOT EXISTS review_status TEXT,
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED;

-- ============================================================================
-- 4. TABLE MODIFICATIONS - DIRECTORY TABLES
-- ============================================================================

-- Organizations - Public directory
ALTER TABLE public.organizations 
   DROP COLUMN IF EXISTS content_status,
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged', 'suspended', 'banned'])) STORED,
   ADD COLUMN IF NOT EXISTS is_directory_ready BOOLEAN GENERATED ALWAYS AS (((visibility_status = 'published') AND (review_status = 'approved') AND (moderation_status = 'safe') AND (url IS NOT NULL))) STORED;

-- People - People profiles
ALTER TABLE public.people 
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged', 'suspended', 'banned'])) STORED,
   ADD COLUMN IF NOT EXISTS is_directory_ready BOOLEAN GENERATED ALWAYS AS (((visibility_status = 'published') AND (review_status = 'approved') AND (moderation_status = 'safe') AND (name IS NOT NULL))) STORED;

-- Opportunities - Job listings
ALTER TABLE public.opportunities 
   DROP COLUMN IF EXISTS content_status,
   ADD COLUMN IF NOT EXISTS visibility_status TEXT DEFAULT 'draft',
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
   ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
   ADD COLUMN IF NOT EXISTS is_public BOOLEAN GENERATED ALWAYS AS (visibility_status = 'published') STORED,
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_active_opportunity BOOLEAN GENERATED ALWAYS AS (((visibility_status = 'published') AND (review_status = 'approved') AND (moderation_status = 'safe'))) STORED;

-- ============================================================================
-- 5. TABLE MODIFICATIONS - USER CONTENT
-- ============================================================================

-- User Profiles - User moderation
ALTER TABLE public.user_profiles 
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged', 'suspended', 'banned'])) STORED,
   ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN GENERATED ALWAYS AS (moderation_status = 'suspended') STORED,
   ADD COLUMN IF NOT EXISTS is_banned BOOLEAN GENERATED ALWAYS AS (moderation_status = 'banned') STORED,
   ADD COLUMN IF NOT EXISTS can_interact BOOLEAN GENERATED ALWAYS AS (((moderation_status = ANY (ARRAY['safe', 'flagged'])) AND (is_active = true))) STORED;

-- ============================================================================
-- 6. TABLE MODIFICATIONS - DOMAIN PROCESSING
-- ============================================================================

-- Content Sources - Source management and workflow
ALTER TABLE public.content_sources 
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS workflow_status TEXT DEFAULT 'scheduled',
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_workflow_active BOOLEAN GENERATED ALWAYS AS (workflow_status = ANY (ARRAY['scheduled', 'queued', 'running'])) STORED,
   ADD COLUMN IF NOT EXISTS has_failures BOOLEAN GENERATED ALWAYS AS (((has_failed = true) OR (failed_count > 0))) STORED,
   ADD COLUMN IF NOT EXISTS is_source_healthy BOOLEAN GENERATED ALWAYS AS (((processing_status = 'completed') AND (workflow_status = 'completed') AND ((failed_count IS NULL) OR (failed_count < 3)))) STORED;

-- Domain URLs - URL processing with priority
ALTER TABLE public.domain_urls 
   DROP COLUMN IF EXISTS priority,
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'queued',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS priority_status TEXT DEFAULT 'medium',
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS has_errors BOOLEAN GENERATED ALWAYS AS (error_count > 0) STORED,
   ADD COLUMN IF NOT EXISTS is_ready_to_process BOOLEAN GENERATED ALWAYS AS (((processing_status = 'queued') AND (error_count < 3))) STORED,
   ADD COLUMN IF NOT EXISTS is_high_priority BOOLEAN GENERATED ALWAYS AS (priority_status = ANY (ARRAY['high', 'critical'])) STORED,
   ADD COLUMN IF NOT EXISTS is_low_priority BOOLEAN GENERATED ALWAYS AS (priority_status = ANY (ARRAY['very_low', 'low'])) STORED;

-- Domain Contacts - Contact extraction
ALTER TABLE public.domain_contacts 
   ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'completed',
   ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN IF NOT EXISTS moderation_status TEXT DEFAULT 'safe',
   ADD COLUMN IF NOT EXISTS is_processing BOOLEAN GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued', 'processing', 'retrying'])) STORED,
   ADD COLUMN IF NOT EXISTS is_approved BOOLEAN GENERATED ALWAYS AS (review_status = 'approved') STORED,
   ADD COLUMN IF NOT EXISTS is_high_confidence BOOLEAN GENERATED ALWAYS AS (confidence >= 0.8) STORED,
   ADD COLUMN IF NOT EXISTS is_verified_contact BOOLEAN GENERATED ALWAYS AS (((processing_status = 'completed') AND (review_status = 'approved') AND (moderation_status = 'safe') AND (confidence >= 0.7))) STORED;

ALTER TABLE public.domain_roots 
   ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();



-- ============================================================================
-- 1. CORE CONTENT TABLES - BIGINT IDS AND COMPUTED COLUMNS
-- ============================================================================

-- Astronomy events table updates
ALTER TABLE public.astronomy_events 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN is_indexed BOOLEAN DEFAULT false,
   ADD COLUMN organization_id UUID,
   ADD COLUMN person_id UUID,
   ADD COLUMN processing_status TEXT DEFAULT 'queued',
   ADD COLUMN url TEXT,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- Categories table updates
ALTER TABLE public.categories 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN domain TEXT NOT NULL,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_flagged, 
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_flagged_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = ANY(ARRAY['flagged', 'suspended', 'banned'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- News table updates
ALTER TABLE public.news 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN is_indexed BOOLEAN DEFAULT false,
   ADD COLUMN organization_id UUID,
   ADD COLUMN person_id UUID,
   DROP COLUMN IF EXISTS content_id,
   DROP COLUMN IF EXISTS graph_migrated_at,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- Opportunities table updates
ALTER TABLE public.opportunities 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN is_indexed BOOLEAN DEFAULT false,
   ADD COLUMN organization_id UUID,
   ADD COLUMN person_id UUID,
   DROP COLUMN IF EXISTS content_id,
   DROP COLUMN IF EXISTS is_active_opportunity,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_active_opportunity_computed BOOLEAN GENERATED ALWAYS AS (
       (visibility_status = 'published') AND 
       (review_status = 'approved') AND 
       (moderation_status = 'safe')
   ) STORED,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- Organizations table updates
ALTER TABLE public.organizations 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN processing_status VARCHAR(50) DEFAULT 'queued',
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_directory_ready,
   DROP COLUMN IF EXISTS is_flagged,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_directory_ready_computed BOOLEAN GENERATED ALWAYS AS (
       (visibility_status = 'published') AND 
       (review_status = 'approved') AND 
       (moderation_status = 'safe') AND 
       (url IS NOT NULL)
   ) STORED,
   ADD COLUMN is_flagged_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = ANY(ARRAY['flagged', 'suspended', 'banned'])
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- People table updates
ALTER TABLE public.people 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_directory_ready,
   DROP COLUMN IF EXISTS is_flagged,
   DROP COLUMN IF EXISTS is_public,
   DROP COLUMN IF EXISTS user_id,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_directory_ready_computed BOOLEAN GENERATED ALWAYS AS (
       (visibility_status = 'published') AND 
       (review_status = 'approved') AND 
       (moderation_status = 'safe') AND 
       (name IS NOT NULL)
   ) STORED,
   ADD COLUMN is_flagged_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = ANY(ARRAY['flagged', 'suspended', 'banned'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- Research table updates
ALTER TABLE public.research 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   ADD COLUMN is_indexed BOOLEAN DEFAULT false,
   ADD COLUMN person_id UUID,
   DROP COLUMN IF EXISTS content_id,
   DROP COLUMN IF EXISTS graph_migrated_at,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- Topics table updates
ALTER TABLE public.topics 
   ADD COLUMN bigint_id BIGSERIAL NOT NULL,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_flagged,
   DROP COLUMN IF EXISTS is_indexed,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_public,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_flagged_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = ANY(ARRAY['flagged', 'suspended', 'banned'])
   ) STORED,
   ADD COLUMN is_indexed_computed BOOLEAN GENERATED ALWAYS AS (
       indexing_status = 'indexed'
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_public_computed BOOLEAN GENERATED ALWAYS AS (
       visibility_status = 'published'
   ) STORED;

-- ============================================================================
-- 2. DOMAIN TABLES - COMPUTED COLUMNS AND OPTIMIZATIONS
-- ============================================================================

-- Content sources optimizations
ALTER TABLE public.content_sources 
   ADD COLUMN review_status TEXT DEFAULT 'pending_review',
   ADD COLUMN priority_status TEXT NOT NULL,
   ADD COLUMN last_extracted_urls JSONB DEFAULT '[]',
   ALTER COLUMN organization_id SET NOT NULL,
   DROP COLUMN IF EXISTS has_failures,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_source_healthy,
   DROP COLUMN IF EXISTS is_workflow_active,
   DROP COLUMN IF EXISTS priority,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_healthy_computed BOOLEAN GENERATED ALWAYS AS (
       (processing_status = 'completed') AND 
       (workflow_status = 'completed') AND 
       (review_status = 'approved') AND 
       ((failed_count IS NULL) OR (failed_count < 3))
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_workflow_active_computed BOOLEAN GENERATED ALWAYS AS (
       workflow_status = ANY(ARRAY['scheduled', 'queued', 'running'])
   ) STORED;


ALTER TABLE public.domain_assets 
  -- Column management
  DROP COLUMN IF EXISTS company_id,
  DROP COLUMN IF EXISTS is_approved,
  DROP COLUMN IF EXISTS is_available,
  DROP COLUMN IF EXISTS is_processing,
  ADD COLUMN IF NOT EXISTS organization_id UUID,
  ADD COLUMN IF NOT EXISTS processing_status TEXT DEFAULT 'completed',
  ADD COLUMN IF NOT EXISTS review_status TEXT DEFAULT 'pending_review',
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  ALTER COLUMN domain_root_id SET NOT NULL,
  ALTER COLUMN organization_id SET NOT NULL,
  
  -- Computed columns
  ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
      review_status = 'approved'
  ) STORED,
  ADD COLUMN is_available_computed BOOLEAN GENERATED ALWAYS AS (
      (processing_status = 'completed') AND 
      (review_status = 'approved') AND 
      (asset_url IS NOT NULL)
  ) STORED,
  ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
      processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
  ) STORED;

-- ============================================================================
-- 3. USER AND SYSTEM TABLES - COMPUTED COLUMNS
-- ============================================================================

-- User profiles computed columns
ALTER TABLE public.user_profiles 
   DROP COLUMN IF EXISTS can_interact,
   DROP COLUMN IF EXISTS is_banned,
   DROP COLUMN IF EXISTS is_flagged,
   DROP COLUMN IF EXISTS is_suspended,
   ADD COLUMN can_interact_computed BOOLEAN GENERATED ALWAYS AS (
       (moderation_status = ANY(ARRAY['safe', 'flagged'])) AND (is_active = true)
   ) STORED,
   ADD COLUMN is_banned_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = 'banned'
   ) STORED,
   ADD COLUMN is_flagged_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = ANY(ARRAY['flagged', 'suspended', 'banned'])
   ) STORED,
   ADD COLUMN is_suspended_computed BOOLEAN GENERATED ALWAYS AS (
       moderation_status = 'suspended'
   ) STORED;

-- ============================================================================
-- 5. MISSING TIMESTAMPS AND SYSTEM COLUMNS
-- ============================================================================

-- Add missing timestamps
ALTER TABLE public.customer_payments 
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.customer_processed_webhooks 
   ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.customer_refunds 
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.user_categories 
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.user_topics 
   ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();


-- ============================================================================
-- 7. ENUM COLUMN UPDATES
-- ============================================================================

-- Update existing enum columns to use new enum types

ALTER TABLE public.customer_subscription_offers 
   ALTER COLUMN discount_type SET DATA TYPE public.discount_type_enum USING discount_type::TEXT::public.discount_type_enum,
   ALTER COLUMN discount_period SET DATA TYPE public.discount_period_enum USING discount_period::TEXT::public.discount_period_enum;

-- ============================================================================
-- 8. CORE STATUS FUNCTIONS
-- ============================================================================

-- Helper function to parse status tracks from table comment
CREATE OR REPLACE FUNCTION public.get_table_status_tracks(p_table_name TEXT)
RETURNS TEXT[]
LANGUAGE plpgsql
AS $$
DECLARE
   table_comment TEXT;
   status_section TEXT;
   tracks TEXT[];
BEGIN
   -- Get table comment
   SELECT obj_description(oid) INTO table_comment
   FROM pg_class 
   WHERE relname = p_table_name 
   AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
   
   -- Return empty array if no comment
   IF table_comment IS NULL THEN
       RETURN '{}';
   END IF;
   
   -- Extract status section from comment
   status_section := substring(table_comment FROM 'status:([^|]+)');
   
   -- Return empty array if no status section
   IF status_section IS NULL THEN
       RETURN '{}';
   END IF;
   
   -- Split comma-separated tracks and trim whitespace
   SELECT array_agg(trim(track))
   INTO tracks
   FROM unnest(string_to_array(status_section, ',')) AS track;
   
   RETURN COALESCE(tracks, '{}');
END;
$$;

-- Status validation function
CREATE OR REPLACE FUNCTION public.validate_status(p_table_name TEXT, p_track TEXT, p_old_status TEXT, p_new_status TEXT)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
   table_tracks TEXT[];
BEGIN
   -- Get status tracks from table comment
   table_tracks := get_table_status_tracks(p_table_name);
   
   -- Check if table declares this status track
   IF NOT (p_track = ANY(table_tracks)) THEN
       RAISE EXCEPTION 'Table "%" does not declare status track "%" in its comment. Declared tracks: %', 
           p_table_name, p_track, array_to_string(table_tracks, ', ');
   END IF;
   
   -- Validate new status exists in registry for this track
   IF NOT EXISTS(
       SELECT 1 FROM public.statuses 
       WHERE key = p_new_status 
       AND track = p_track
   ) THEN
       RAISE EXCEPTION 'Invalid status "%" for track "%" on table "%"', 
           p_new_status, p_track, p_table_name;
   END IF;

   -- Validate transition is allowed (if constraints exist)
   IF p_old_status IS NOT NULL AND EXISTS(
       SELECT 1 FROM public.statuses 
       WHERE key = p_old_status 
       AND track = p_track 
       AND allowed_transitions IS NOT NULL
       AND NOT (p_new_status = ANY(allowed_transitions))
   ) THEN
       RAISE EXCEPTION 'Invalid transition from "%" to "%" in track "%"', 
           p_old_status, p_new_status, p_track;
   END IF;
END;
$$;

-- Universal status update function with validation and audit
CREATE OR REPLACE FUNCTION public.update_status(
   p_table_name TEXT, 
   p_record_id UUID, 
   p_track TEXT, 
   p_new_status TEXT, 
   p_metadata JSONB DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
   old_status TEXT;
   status_column TEXT := p_track || '_status';
BEGIN
   -- Get current status value
   EXECUTE format('SELECT %I FROM %I WHERE id = $1', status_column, p_table_name)
   INTO old_status USING p_record_id;

   -- Validate status transition
   PERFORM public.validate_status(p_table_name, p_track, old_status, p_new_status);

   -- Update the status column
   EXECUTE format('UPDATE %I SET %I = $1, updated_at = now() WHERE id = $2', 
       p_table_name, status_column) 
   USING p_new_status, p_record_id;

   -- Log the transition
   INSERT INTO public.status_history (
       record_id, source_table, track, from_status, to_status, metadata
   ) VALUES (
       p_record_id, p_table_name, p_track, old_status, p_new_status, p_metadata
   );
END;
$$;

-- Batch status update function with validation
CREATE OR REPLACE FUNCTION public.update_status_batch(
   p_table_name TEXT, 
   p_record_ids UUID[], 
   p_track TEXT, 
   p_new_status TEXT, 
   p_metadata JSONB DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
   status_column TEXT := p_track || '_status';
   record_batch RECORD;
BEGIN
   -- Get current statuses and validate transitions for each record
   FOR record_batch IN 
       EXECUTE format('SELECT id, %I as current_status FROM %I WHERE id = ANY($1)', 
                      status_column, p_table_name) 
       USING p_record_ids
   LOOP
       -- Validate each record's status transition
       PERFORM public.validate_status(p_table_name, p_track, record_batch.current_status, p_new_status);
   END LOOP;

   -- Batch update all records (only after all validations pass)
   EXECUTE format('UPDATE %I SET %I = $1, updated_at = now() WHERE id = ANY($2)', 
       p_table_name, status_column) 
   USING p_new_status, p_record_ids;

   -- Batch insert history records
   INSERT INTO public.status_history (record_id, source_table, track, to_status, metadata)
   SELECT unnest(p_record_ids), p_table_name, p_track, p_new_status, p_metadata;
END;
$$;

-- ============================================================================
-- 9. TABLE CONSTRAINTS
-- ============================================================================

-- Unique constraints
ALTER TABLE public.statuses 
   ADD CONSTRAINT unique_status_per_track UNIQUE (key, track);

-- Check constraints
ALTER TABLE public.statuses 
   ADD CONSTRAINT statuses_track_check 
   CHECK (track = ANY (ARRAY['visibility', 'processing', 'review', 'moderation', 'indexing', 'workflow', 'priority'])),
   ADD CONSTRAINT statuses_color_check 
   CHECK (color ~ '^[a-z]+-[0-9]{3}$');

-- ============================================================================
-- 10. VALIDATION
-- ============================================================================

-- Validate status system is working
DO $$
BEGIN
   -- Check core tables exist
   IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'statuses') THEN
       RAISE EXCEPTION 'Status registry table missing';
   END IF;
   
   IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'status_history') THEN
       RAISE EXCEPTION 'Status history table missing';
   END IF;
   
   -- Check functions exist
   IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_status') THEN
       RAISE EXCEPTION 'update_status function missing';
   END IF;
   
   IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_status_batch') THEN
       RAISE EXCEPTION 'update_status_batch function missing';
   END IF;
   
   RAISE NOTICE 'Status system migration validation passed';
END $$;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Populate status registry with application status definitions
-- 2. Set up RLS policies for status_history and statuses tables
-- 3. Test status transitions with update_status function
-- 4. Consider setting up monitoring for status_history growth
-- ============================================================================