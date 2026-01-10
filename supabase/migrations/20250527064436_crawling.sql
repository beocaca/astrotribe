-- ============================================================================
-- DOMAIN SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Domain processing tables with computed columns and organization relationships
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. DOMAIN CONTACTS TABLE UPDATES
-- ============================================================================

ALTER TABLE public.domain_contacts 
   ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
   ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
   ALTER COLUMN domain_root_id SET NOT NULL,
   ALTER COLUMN organization_id SET NOT NULL,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_high_confidence,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_verified_contact,
   DROP COLUMN IF EXISTS company_id,
   ADD COLUMN IF NOT EXISTS organization_id UUID,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_high_confidence_computed BOOLEAN GENERATED ALWAYS AS (
       confidence >= 0.8
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_verified_contact_computed BOOLEAN GENERATED ALWAYS AS (
       (processing_status = 'completed') AND 
       (review_status = 'approved') AND 
       (moderation_status = 'safe') AND 
       (confidence >= 0.7)
   ) STORED;

-- ============================================================================
-- 2. DOMAIN URLS TABLE UPDATES
-- ============================================================================

ALTER TABLE public.domain_urls 
   ALTER COLUMN domain_root_id SET NOT NULL,
   DROP COLUMN IF EXISTS has_errors,
   DROP COLUMN IF EXISTS is_approved,
   DROP COLUMN IF EXISTS is_high_priority,
   DROP COLUMN IF EXISTS is_low_priority,
   DROP COLUMN IF EXISTS is_processing,
   DROP COLUMN IF EXISTS is_ready_to_process,
   DROP COLUMN IF EXISTS company_id,
   ADD COLUMN IF NOT EXISTS organization_id UUID,
   ADD COLUMN has_errors_computed BOOLEAN GENERATED ALWAYS AS (
       error_count > 0
   ) STORED,
   ADD COLUMN is_approved_computed BOOLEAN GENERATED ALWAYS AS (
       review_status = 'approved'
   ) STORED,
   ADD COLUMN is_high_priority_computed BOOLEAN GENERATED ALWAYS AS (
       priority_status = ANY(ARRAY['high', 'critical'])
   ) STORED,
   ADD COLUMN is_low_priority_computed BOOLEAN GENERATED ALWAYS AS (
       priority_status = ANY(ARRAY['very_low', 'low'])
   ) STORED,
   ADD COLUMN is_processing_computed BOOLEAN GENERATED ALWAYS AS (
       processing_status = ANY(ARRAY['queued', 'processing', 'retrying'])
   ) STORED,
   ADD COLUMN is_ready_to_process_computed BOOLEAN GENERATED ALWAYS AS (
       (processing_status = 'queued') AND (error_count < 3)
   ) STORED;

-- ============================================================================
-- 3. DOMAIN ROOTS TABLE UPDATES
-- ============================================================================


-- ============================================================================
-- 5. CRAWL STATS TABLE UPDATES
-- ============================================================================

ALTER TABLE public.crawl_stats 
   DROP COLUMN IF EXISTS company_id,
   ADD COLUMN organization_id UUID NOT NULL;


-- ============================================================================
-- 7. FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_sites_to_crawl(fetch_limit INTEGER)
RETURNS SETOF public.organizations
LANGUAGE sql
AS $$
   SELECT *
   FROM public.organizations o
   WHERE
       o.url IS NOT NULL
       AND o.url != ''
       AND o.visibility_status = 'published'
       AND o.review_status = 'approved'
       AND public.should_rescrape(o.scrape_frequency, o.scraped_at)
   ORDER BY COALESCE(o.scraped_at, '1970-01-01'::TIMESTAMP) ASC
   LIMIT fetch_limit
$$;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Update application code to use computed column names (_computed suffix)
-- 2. Migrate data from company_id to organization_id where needed
-- 3. Verify foreign key relationships are properly established
-- 4. Test get_sites_to_crawl function with new status columns
-- ============================================================================