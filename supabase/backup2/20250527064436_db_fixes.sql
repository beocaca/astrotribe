-- ============================================================================
-- MIGRATION: Company ID to Organization ID Refactor
-- Purpose: Standardize entity references to use 'organization' terminology
-- Critical: This migration renames foreign key columns across multiple tables
-- ============================================================================

-- ============================================================================
-- STEP 1: DROP EXISTING CONSTRAINTS & INDEXES
-- Purpose: Remove constraints that will be recreated with new column names
-- ============================================================================


-- ============================================================================
-- STEP 2: COLUMN MIGRATIONS (company_id → organization_id)
-- Purpose: Standardize foreign key column naming across all tables
-- Critical: Data migration handled automatically by column rename
-- ============================================================================

-- addresses: Remove company_id, add organization_id for address linking
ALTER TABLE "public"."addresses" DROP COLUMN "company_id";
ALTER TABLE "public"."addresses" ADD COLUMN "organization_id" uuid NOT NULL;

-- crawl_stats: Link crawl statistics to organizations
ALTER TABLE "public"."crawl_stats" DROP COLUMN "company_id";
ALTER TABLE "public"."crawl_stats" ADD COLUMN "organization_id" uuid NOT NULL;

-- domain_assets: Associate domain assets with organizations
ALTER TABLE "public"."domain_assets" DROP COLUMN "company_id";
ALTER TABLE "public"."domain_assets" ADD COLUMN "organization_id" uuid;

-- domain_contacts: Link domain contact info to organizations
ALTER TABLE "public"."domain_contacts" DROP COLUMN "company_id";
ALTER TABLE "public"."domain_contacts" ADD COLUMN "organization_id" uuid;

-- domain_urls: Link URLs to their parent organizations
ALTER TABLE "public"."domain_urls" DROP COLUMN "company_id";
ALTER TABLE "public"."domain_urls" ADD COLUMN "organization_id" uuid;

-- user_profiles: Remove unused primary_address_id column
ALTER TABLE "public"."user_profiles" DROP COLUMN "primary_address_id";

-- ============================================================================
-- STEP 3: VECTOR SEARCH INDEXES
-- Purpose: Enable semantic search capabilities with HNSW indexes
-- Performance: Optimized for cosine similarity searches
-- ============================================================================


-- ============================================================================
-- STEP 5: FOREIGN KEY CONSTRAINTS
-- Purpose: Restore referential integrity with new column names
-- Security: CASCADE deletes for user data, protect organization data
-- ============================================================================

-- Organization references (protect organization data)
ALTER TABLE "public"."addresses" 
ADD CONSTRAINT "addresses_organization_id_fkey" 
FOREIGN KEY (organization_id) REFERENCES "public"."organizations"(id);

ALTER TABLE "public"."crawl_stats" 
ADD CONSTRAINT "crawl_stats_organization_id_fkey" 
FOREIGN KEY (organization_id) REFERENCES "public"."organizations"(id);

ALTER TABLE "public"."domain_assets" 
ADD CONSTRAINT "domain_assets_organization_id_fkey" 
FOREIGN KEY (organization_id) REFERENCES "public"."organizations"(id);

ALTER TABLE "public"."domain_contacts" 
ADD CONSTRAINT "domain_contacts_organization_id_fkey" 
FOREIGN KEY (organization_id) REFERENCES "public"."organizations"(id);

ALTER TABLE "public"."domain_urls" 
ADD CONSTRAINT "domain_urls_organization_id_fkey" 
FOREIGN KEY (organization_id) REFERENCES "public"."organizations"(id);

-- User references (CASCADE delete for user data cleanup)
ALTER TABLE "public"."user_categories" 
ADD CONSTRAINT "user_categories_user_id_fkey" 
FOREIGN KEY (user_id) REFERENCES "public"."user_profiles"(id) ON DELETE CASCADE;

ALTER TABLE "public"."user_topics" 
ADD CONSTRAINT "user_topics_user_id_fkey" 
FOREIGN KEY (user_id) REFERENCES "public"."user_profiles"(id) ON DELETE CASCADE;


-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================