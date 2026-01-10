-- ============================================================================
-- CONSTRAINTS AND VALIDATION MIGRATION
-- ============================================================================
-- Purpose: Foreign key constraints, check constraints, and validation rules
-- Date: 2025-06-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;



-- ============================================================================
-- 5. CONSTRAINTS
-- ============================================================================

-- People constraints
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'people_career_level_check') THEN
        ALTER TABLE public.people 
        ADD CONSTRAINT people_career_level_check 
        CHECK (career_level = ANY (ARRAY['student', 'postdoc', 'faculty', 'emeritus', 'industry', 'government', 'independent', 'historical', 'pioneer', 'deceased_historical']));
    END IF;
END $$;

-- News constraints
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_news_type') THEN
        ALTER TABLE public.news 
        ADD CONSTRAINT chk_news_type 
        CHECK (news_type IN ('breaking', 'analysis', 'interview', 'press_release', 'research_summary', 'mission_update'));
    END IF;
END $$;

-- Opportunities constraints
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_opportunities_employment_type') THEN
        ALTER TABLE public.opportunities 
        ADD CONSTRAINT chk_opportunities_employment_type 
        CHECK (employment_type IN ('full_time', 'part_time', 'contract', 'internship', 'freelance', 'remote', 'hybrid'));
    END IF;
END $$;

-- Organizations constraints
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_organizations_org_type') THEN
        ALTER TABLE public.organizations 
        ADD CONSTRAINT chk_organizations_org_type 
        CHECK (organization_type IN ('company', 'university', 'government', 'nonprofit', 'research_institute'));
    END IF;
END $$;

-- Graph edges unique constraint
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unique_graph_edge') THEN
        ALTER TABLE public.graph_edges 
        ADD CONSTRAINT unique_graph_edge 
        UNIQUE (source_type, source_id, target_type, target_id, edge_type);
    END IF;
END $$;

-- ============================================================================
-- 6. INDEXES
-- ============================================================================

-- Unique index on people user_id
CREATE UNIQUE INDEX IF NOT EXISTS people_user_id_unique 
   ON public.people(user_id) WHERE user_id IS NOT NULL;

-- ============================================================================
-- 7. FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- People references
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'people_user_id_fkey') THEN
        ALTER TABLE public.people 
        ADD CONSTRAINT people_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE SET NULL;
    END IF;
END $$;

-- User profiles references
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_user_profiles_organization') THEN
        ALTER TABLE public.user_profiles 
        ADD CONSTRAINT fk_user_profiles_organization 
        FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;
    END IF;
END $$;

-- User topics references
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_topics_user_id_fkey') THEN
        ALTER TABLE public.user_topics 
        ADD CONSTRAINT user_topics_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- User categories references
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_categories_user_id_fkey') THEN
        ALTER TABLE public.user_categories 
        ADD CONSTRAINT user_categories_user_id_fkey 
        FOREIGN KEY (user_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Addresses references
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'addresses_organization_id_fkey') THEN
        ALTER TABLE public.addresses 
        ADD CONSTRAINT addresses_organization_id_fkey 
        FOREIGN KEY (organization_id) REFERENCES public.organizations(id);
    END IF;
END $$;

-- ============================================================================
-- 1. DROP LEGACY CONSTRAINTS
-- ============================================================================

-- Drop foreign key constraints from content tables
ALTER TABLE public.news DROP CONSTRAINT IF EXISTS news_content_id_fkey;
ALTER TABLE public.opportunities DROP CONSTRAINT IF EXISTS opportunities_content_id_fkey;
ALTER TABLE public.research DROP CONSTRAINT IF EXISTS research_content_id_fkey;

-- ============================================================================
-- 2. CONTENT TABLE FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- Astronomy events relationships
ALTER TABLE public.astronomy_events 
   DROP CONSTRAINT IF EXISTS astronomy_events_organization_id_fkey,
   ADD CONSTRAINT fk_astronomy_events_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.astronomy_events 
   DROP CONSTRAINT IF EXISTS astronomy_events_person_id_fkey,
   ADD CONSTRAINT fk_astronomy_events_person_id 
   FOREIGN KEY (person_id) REFERENCES public.people(id);

-- News relationships
ALTER TABLE public.news 
   DROP CONSTRAINT IF EXISTS news_organization_id_fkey,
   ADD CONSTRAINT fk_news_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.news 
   DROP CONSTRAINT IF EXISTS news_person_id_fkey,
   ADD CONSTRAINT fk_news_person_id 
   FOREIGN KEY (person_id) REFERENCES public.people(id);

-- Opportunities relationships
ALTER TABLE public.opportunities 
   DROP CONSTRAINT IF EXISTS opportunities_organization_id_fkey,
   ADD CONSTRAINT fk_opportunities_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.opportunities 
   DROP CONSTRAINT IF EXISTS opportunities_person_id_fkey,
   ADD CONSTRAINT fk_opportunities_person_id 
   FOREIGN KEY (person_id) REFERENCES public.people(id);

-- Research relationships
ALTER TABLE public.research 
   DROP CONSTRAINT IF EXISTS research_person_id_fkey,
   ADD CONSTRAINT fk_research_person_id 
   FOREIGN KEY (person_id) REFERENCES public.people(id);

-- ============================================================================
-- 3. TOPIC CLUSTER RELATIONSHIPS
-- ============================================================================

ALTER TABLE public.topic_clusters 
   DROP CONSTRAINT IF EXISTS topic_clusters_topic_id_fkey,
   ADD CONSTRAINT fk_topic_clusters_topic_id 
   FOREIGN KEY (topic_id) REFERENCES public.topics(id);

-- ============================================================================
-- 4. DOMAIN TABLE CASCADE RELATIONSHIPS
-- ============================================================================

-- Content sources relationships
ALTER TABLE public.content_sources 
   DROP CONSTRAINT IF EXISTS content_sources_organization_id_fkey,
   ADD CONSTRAINT fk_content_sources_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id) 
   ON UPDATE CASCADE ON DELETE CASCADE;

-- Crawl stats relationships
ALTER TABLE public.crawl_stats 
   DROP CONSTRAINT IF EXISTS crawl_stats_organization_id_fkey,
   ADD CONSTRAINT fk_crawl_stats_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id) 
   ON UPDATE CASCADE ON DELETE CASCADE;

-- Domain assets relationships
ALTER TABLE public.domain_assets 
   DROP CONSTRAINT IF EXISTS domain_assets_organization_id_fkey,
   ADD CONSTRAINT fk_domain_assets_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id) 
   ON UPDATE CASCADE ON DELETE CASCADE;

-- Domain contacts relationships
ALTER TABLE public.domain_contacts 
   DROP CONSTRAINT IF EXISTS domain_contacts_organization_id_fkey,
   ADD CONSTRAINT fk_domain_contacts_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id) 
   ON UPDATE CASCADE ON DELETE CASCADE;

-- Domain URLs relationships
ALTER TABLE public.domain_urls 
   DROP CONSTRAINT IF EXISTS domain_urls_organization_id_fkey,
   ADD CONSTRAINT fk_domain_urls_organization_id 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id) 
   ON UPDATE CASCADE ON DELETE SET NULL;


-- ============================================================================
-- 6. FOREIGN KEY CONSTRAINTS
-- ============================================================================

ALTER TABLE public.domain_assets 
   ADD CONSTRAINT domain_assets_organization_id_fkey 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.domain_contacts 
   ADD CONSTRAINT domain_contacts_organization_id_fkey 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.domain_urls 
   ADD CONSTRAINT domain_urls_organization_id_fkey 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

ALTER TABLE public.crawl_stats 
   ADD CONSTRAINT crawl_stats_organization_id_fkey 
   FOREIGN KEY (organization_id) REFERENCES public.organizations(id);

-- ============================================================================
-- 5. CHECK CONSTRAINTS AND VALIDATION
-- ============================================================================

-- Categories domain validation
ALTER TABLE public.categories 
   ADD CONSTRAINT chk_categories_domain 
   CHECK (domain = ANY (ARRAY['astronomy', 'space_tech']));

-- Content sources validation
ALTER TABLE public.content_sources 
   DROP CONSTRAINT IF EXISTS chk_priority_status,
   ADD CONSTRAINT chk_content_sources_priority_status 
   CHECK (priority_status = ANY (ARRAY['very_low', 'low', 'medium', 'high', 'critical']));

ALTER TABLE public.content_sources 
   DROP CONSTRAINT IF EXISTS chk_processing_status,
   ADD CONSTRAINT chk_content_sources_processing_status 
   CHECK (processing_status = ANY (ARRAY['queued', 'processing', 'completed', 'errored', 'retrying', 'timed_out', 'skipped']));

ALTER TABLE public.content_sources 
   DROP CONSTRAINT IF EXISTS chk_review_status,
   ADD CONSTRAINT chk_content_sources_review_status 
   CHECK (review_status = ANY (ARRAY['pending_review', 'under_review', 'approved', 'rejected', 'needs_changes', 'deferred']));

ALTER TABLE public.content_sources 
   DROP CONSTRAINT IF EXISTS chk_workflow_status,
   ADD CONSTRAINT chk_content_sources_workflow_status 
   CHECK (workflow_status = ANY (ARRAY['scheduled', 'queued', 'running', 'completed', 'errored', 'paused', 'cancelled']));

-- ============================================================================
-- 6. PRIMARY KEY CONSTRAINTS
-- ============================================================================

-- Topic clusters primary key
ALTER TABLE public.topic_clusters 
   ADD CONSTRAINT topic_clusters_pkey PRIMARY KEY (topic_id);

-- Permission configs primary key (conditional)
DO $$ 
BEGIN
   IF NOT EXISTS (
       SELECT 1 FROM information_schema.table_constraints 
       WHERE table_name = 'permission_configs' 
       AND constraint_type = 'PRIMARY KEY'
       AND table_schema = 'public'
   ) THEN
       ALTER TABLE public.permission_configs 
           ADD CONSTRAINT permissions_config_pkey PRIMARY KEY (id);
   END IF;
END $$;

-- ============================================================================
-- 7. UNIQUE CONSTRAINTS FOR BIGINT IDS
-- ============================================================================

-- Unique constraints for bigint_id columns
ALTER TABLE public.astronomy_events 
   ADD CONSTRAINT idx_uniq_astronomy_events_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.categories 
   ADD CONSTRAINT idx_uniq_categories_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.news 
   ADD CONSTRAINT idx_uniq_news_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.opportunities 
   ADD CONSTRAINT idx_uniq_opportunities_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.organizations 
   ADD CONSTRAINT idx_uniq_organizations_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.people 
   ADD CONSTRAINT idx_uniq_people_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.research 
   ADD CONSTRAINT idx_uniq_research_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.topics 
   ADD CONSTRAINT idx_uniq_topics_bigint_id UNIQUE (bigint_id);

ALTER TABLE public.topic_clusters 
   ADD CONSTRAINT idx_uniq_topic_clusters_topic_bigint_id UNIQUE (topic_bigint_id);

ALTER TABLE public.user_topics 
    ADD CONSTRAINT user_topics_topic_id_fkey 
    FOREIGN KEY (topic_id) REFERENCES public.topics(id) ON DELETE CASCADE;


DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_categories_category_id_fkey') THEN
        ALTER TABLE public.user_categories 
        ADD CONSTRAINT user_categories_category_id_fkey 
        FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;
    END IF;
END $$;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Verify all foreign key relationships are properly established
-- 2. Test check constraints with sample data
-- 3. Monitor constraint violation logs
-- 4. Update application code to handle new constraint validations
-- ============================================================================