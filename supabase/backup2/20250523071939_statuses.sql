-- ===================================
-- STATUS SYSTEM MIGRATION - COMPLETE REFACTORED
-- ===================================
-- Migration Order: Enums → Core Tables → Table Modifications → Functions → Indexes → Constraints → Triggers → Permissions
-- 
-- ===================================
-- 1. ENUM MANAGEMENT
-- ===================================

-- Create new properly named enums (following _enum convention)
CREATE TYPE public.contact_type_enum AS ENUM ('personal', 'company', 'professional', 'recruitment', 'founder');
CREATE TYPE public.discount_period_enum AS ENUM ('yearly', 'monthly', 'once');
CREATE TYPE public.discount_type_enum AS ENUM ('percentage', 'flat');
CREATE TYPE public.privacy_level_enum AS ENUM ('private', 'connected', 'public');

-- ===================================
-- 2. CORE STATUS SYSTEM TABLES
-- ===================================

-- Status registry - central validation and metadata store
CREATE TABLE public.statuses (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    key text NOT NULL,                          -- Status identifier (e.g., 'published', 'flagged')
    description text,                           -- Human-readable description
    track text NOT NULL,                       -- Status track (visibility, processing, etc.)
    computed_column_name text,                -- Optional computed column name for derived status
    computed_condition text,                   -- Condition for computed status (e.g., 'visibility_status = ''published''')
    is_computed boolean DEFAULT false,         -- Is this a computed status?
    allowed_transitions text[],                -- Valid next statuses (NULL = no restrictions)
    is_terminal boolean DEFAULT false,          -- Cannot transition from this status
    priority integer DEFAULT 0,                -- Display/processing priority
    color text,                                -- UI color (format: color-shade like 'blue-500')
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Status history - immutable audit trail for all status changes
CREATE TABLE public.status_history (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    record_id uuid NOT NULL,                   -- ID of the record that changed
    source_table text NOT NULL,               -- Table containing the record
    track text NOT NULL,                      -- Which status track changed
    from_status text,                         -- Previous status (NULL for initial)
    to_status text NOT NULL,                  -- New status
    transitioned_at timestamp with time zone DEFAULT now(),
    metadata jsonb                            -- Additional context (user_id, reason, etc.)
);

-- ===================================
-- 3. TABLE MODIFICATIONS - CONTENT TABLES
-- ===================================

-- News - News content (full status tracking)
ALTER TABLE public.news 
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS indexing_status text DEFAULT 'pending'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED;

-- Research - Research papers (full status tracking)
ALTER TABLE public.research 
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS indexing_status text DEFAULT 'pending'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED;

-- Topics - Knowledge topics (full status tracking)
ALTER TABLE public.topics 
DROP COLUMN IF EXISTS status_id,
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS indexing_status text DEFAULT 'pending'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_flagged boolean GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_indexed boolean GENERATED ALWAYS AS (indexing_status = 'indexed'::text) STORED;

-- Categories - Content categorization
ALTER TABLE public.categories 
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_flagged boolean GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text])) STORED;

-- Newsletters - Newsletter content
ALTER TABLE public.newsletters 
DROP COLUMN IF EXISTS content_status,
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED;

-- Astronomy Events - Event calendar
ALTER TABLE public.astronomy_events 
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'published'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED;

-- ===================================
-- 4. TABLE MODIFICATIONS - DIRECTORY TABLES
-- ===================================

-- Organizations - Public directory
ALTER TABLE public.organizations 
DROP COLUMN IF EXISTS content_status,
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_flagged boolean GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_directory_ready boolean GENERATED ALWAYS AS (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text) AND (url IS NOT NULL))) STORED;

-- People - People profiles
ALTER TABLE public.people 
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_flagged boolean GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_directory_ready boolean GENERATED ALWAYS AS (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text) AND (name IS NOT NULL))) STORED;

-- Opportunities - Job listings
ALTER TABLE public.opportunities 
DROP COLUMN IF EXISTS content_status,
ADD COLUMN IF NOT EXISTS visibility_status text DEFAULT 'draft'::text,
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_public boolean GENERATED ALWAYS AS (visibility_status = 'published'::text) STORED,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_active_opportunity boolean GENERATED ALWAYS AS (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) STORED;

-- ===================================
-- 5. TABLE MODIFICATIONS - USER CONTENT
-- ===================================

-- User Profiles - User moderation
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_flagged boolean GENERATED ALWAYS AS (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_suspended boolean GENERATED ALWAYS AS (moderation_status = 'suspended'::text) STORED,
ADD COLUMN IF NOT EXISTS is_banned boolean GENERATED ALWAYS AS (moderation_status = 'banned'::text) STORED,
ADD COLUMN IF NOT EXISTS can_interact boolean GENERATED ALWAYS AS (((moderation_status = ANY (ARRAY['safe'::text, 'flagged'::text])) AND (is_active = true))) STORED;

-- ===================================
-- 7. TABLE MODIFICATIONS - DOMAIN PROCESSING
-- ===================================

-- Content Sources - Source management and workflow
ALTER TABLE public.content_sources 
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS workflow_status text DEFAULT 'scheduled'::text,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_workflow_active boolean GENERATED ALWAYS AS (workflow_status = ANY (ARRAY['scheduled'::text, 'queued'::text, 'running'::text])) STORED,
ADD COLUMN IF NOT EXISTS has_failures boolean GENERATED ALWAYS AS (((has_failed = true) OR (failed_count > 0))) STORED,
ADD COLUMN IF NOT EXISTS is_source_healthy boolean GENERATED ALWAYS AS (((processing_status = 'completed'::text) AND (workflow_status = 'completed'::text) AND ((failed_count IS NULL) OR (failed_count < 3)))) STORED;

-- Domain URLs - URL processing with priority
ALTER TABLE public.domain_urls 
DROP COLUMN IF EXISTS priority,
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'queued'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS priority_status text DEFAULT 'medium'::text,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS has_errors boolean GENERATED ALWAYS AS (error_count > 0) STORED,
ADD COLUMN IF NOT EXISTS is_ready_to_process boolean GENERATED ALWAYS AS (((processing_status = 'queued'::text) AND (error_count < 3))) STORED,
ADD COLUMN IF NOT EXISTS is_high_priority boolean GENERATED ALWAYS AS (priority_status = ANY (ARRAY['high'::text, 'critical'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_low_priority boolean GENERATED ALWAYS AS (priority_status = ANY (ARRAY['very_low'::text, 'low'::text])) STORED;

-- Domain Contacts - Contact extraction
ALTER TABLE public.domain_contacts 
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'completed'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS moderation_status text DEFAULT 'safe'::text,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_high_confidence boolean GENERATED ALWAYS AS (confidence >= 0.8) STORED,
ADD COLUMN IF NOT EXISTS is_verified_contact boolean GENERATED ALWAYS AS (((processing_status = 'completed'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text) AND (confidence >= 0.7))) STORED;

-- Domain Assets - Asset processing
ALTER TABLE public.domain_assets 
ADD COLUMN IF NOT EXISTS processing_status text DEFAULT 'completed'::text,
ADD COLUMN IF NOT EXISTS review_status text DEFAULT 'pending_review'::text,
ADD COLUMN IF NOT EXISTS is_processing boolean GENERATED ALWAYS AS (processing_status = ANY (ARRAY['queued'::text, 'processing'::text, 'retrying'::text])) STORED,
ADD COLUMN IF NOT EXISTS is_approved boolean GENERATED ALWAYS AS (review_status = 'approved'::text) STORED,
ADD COLUMN IF NOT EXISTS is_available boolean GENERATED ALWAYS AS (((processing_status = 'completed'::text) AND (review_status = 'approved'::text) AND (asset_url IS NOT NULL))) STORED;

-- ===================================
-- 8. ENUM COLUMN UPDATES
-- ===================================

-- Update existing enum columns to use new enum types
ALTER TABLE public.contacts 
ALTER COLUMN contact_type SET DATA TYPE public.contact_type_enum USING contact_type::text::public.contact_type_enum,
ALTER COLUMN privacy_level SET DATA TYPE public.privacy_level_enum USING privacy_level::text::public.privacy_level_enum;

ALTER TABLE public.customer_subscription_offers 
ALTER COLUMN discount_type SET DATA TYPE public.discount_type_enum USING discount_type::text::public.discount_type_enum,
ALTER COLUMN discount_period SET DATA TYPE public.discount_period_enum USING discount_period::text::public.discount_period_enum;

-- ===================================
-- 9. CORE STATUS FUNCTIONS
-- ===================================

-- Universal status update function with validation and audit

-- Enhanced status update function with validation
CREATE OR REPLACE FUNCTION "public"."update_status"(
    p_table_name text, 
    p_record_id uuid, 
    p_track text, 
    p_new_status text, 
    p_metadata jsonb DEFAULT NULL::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  old_status text;
  status_column text := p_track || '_status';
BEGIN
  -- Get current status value
  EXECUTE format('SELECT %I FROM %I WHERE id = $1', status_column, p_table_name)
  INTO old_status USING p_record_id;

  -- Validate status transition
  PERFORM "public"."validate_status"(p_table_name, p_track, old_status, p_new_status);

  -- Update the status column
  EXECUTE format('UPDATE %I SET %I = $1, updated_at = now() WHERE id = $2', 
    p_table_name, status_column) 
  USING p_new_status, p_record_id;

  -- Log the transition
  INSERT INTO "public"."status_history" (
    record_id, source_table, track, from_status, to_status, metadata
  ) VALUES (
    p_record_id, p_table_name, p_track, old_status, p_new_status, p_metadata
  );
END;
$function$;

-- Batch status update function with validation
CREATE OR REPLACE FUNCTION "public"."update_status_batch"(
    p_table_name text, 
    p_record_ids uuid[], 
    p_track text, 
    p_new_status text, 
    p_metadata jsonb DEFAULT NULL::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  status_column text := p_track || '_status';
  record_batch record;
BEGIN
  -- Get current statuses and validate transitions for each record
  FOR record_batch IN 
    EXECUTE format('SELECT id, %I as current_status FROM %I WHERE id = ANY($1)', 
                   status_column, p_table_name) 
    USING p_record_ids
  LOOP
    -- Validate each record's status transition
    PERFORM "public"."validate_status"(p_table_name, p_track, record_batch.current_status, p_new_status);
  END LOOP;

  -- Batch update all records (only after all validations pass)
  EXECUTE format('UPDATE %I SET %I = $1, updated_at = now() WHERE id = ANY($2)', 
    p_table_name, status_column) 
  USING p_new_status, p_record_ids;

  -- Batch insert history records
  INSERT INTO "public"."status_history" (record_id, source_table, track, to_status, metadata)
  SELECT unnest(p_record_ids), p_table_name, p_track, p_new_status, p_metadata;
END;
$function$;



CREATE OR REPLACE FUNCTION public.get_table_status_tracks(p_table_name text)
 RETURNS text[]
 LANGUAGE plpgsql
AS $function$
DECLARE
  table_comment text;
  status_section text;
  tracks text[];
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
  -- Format: 'domain:content | purpose:... | status:visibility,processing,review'
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
$function$
;


CREATE OR REPLACE FUNCTION public.validate_status(p_table_name text, p_track text, p_old_status text, p_new_status text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  table_tracks text[];
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
$function$
;

-- ===================================
-- 10. PRIMARY KEYS AND UNIQUE CONSTRAINTS
-- ===================================

-- Core status tables
ALTER TABLE public.statuses ADD CONSTRAINT statuses_pkey PRIMARY KEY (id);
ALTER TABLE public.status_history ADD CONSTRAINT status_history_pkey PRIMARY KEY (id);

-- Unique constraints
ALTER TABLE public.statuses ADD CONSTRAINT unique_status_per_track UNIQUE (key, track);

-- ===================================
-- 11. CHECK CONSTRAINTS
-- ===================================

-- Status registry constraints
ALTER TABLE public.statuses ADD CONSTRAINT statuses_track_check 
CHECK (track = ANY (ARRAY['visibility'::text, 'processing'::text, 'review'::text, 'moderation'::text, 'indexing'::text, 'workflow'::text, 'priority'::text]));

ALTER TABLE public.statuses ADD CONSTRAINT statuses_color_check 
CHECK (color ~ '^[a-z]+-[0-9]{3}$'::text);


-- ===================================
-- 15. VALIDATION QUERIES
-- ===================================

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

alter table "public"."status_history" 
    add column if not exists "created_at" timestamp without time zone not null default now(),
    add column if not exists "updated_at" timestamp without time zone not null default now();


alter table "public"."astronomy_events" add column "moderation_status" text;
alter table "public"."astronomy_events" add column "review_status" text;
alter table "public"."opportunities" add column "deleted_at" timestamp with time zone;
alter table "public"."opportunities" add column "is_active" boolean default true;
alter table "public"."research" add column "deleted_at" timestamp with time zone;

-- ===================================
-- MIGRATION COMPLETE
-- ===================================
-- 
-- POST-MIGRATION TASKS:
-- 1. Populate status registry with your application's status definitions
-- 2. Set up RLS policies for status_history and statuses tables
-- 4. Test status transitions with update_status function
-- 5. Consider setting up monitoring for status_history growth
-- ===================================