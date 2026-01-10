-- ============================================================================
-- TOPICS SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Core topics system with content relationships, embeddings,
--          user interactions, and comprehensive knowledge graph
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. EXTENSIONS
-- ============================================================================
DROP EXTENSION IF EXISTS vector;

CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "extensions" VERSION '0.8.0';
CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions" VERSION '1.3';
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions" VERSION '1.6';
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions" VERSION '3.3.7';
CREATE EXTENSION IF NOT EXISTS "pgrouting" WITH SCHEMA "extensions" VERSION '3.4.1';
CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA "extensions" VERSION '1.1';
create extension if not exists "hypopg" with schema "extensions";
create extension if not exists "index_advisor" with schema "extensions";



-- ============================================================================
-- 2. CLEANUP EXISTING STRUCTURES
-- ============================================================================

-- Drop constraints and indexes for content_categories
ALTER TABLE "public"."content_categories" DROP CONSTRAINT IF EXISTS "content_categories_role_check";
ALTER TABLE "public"."content_categories" DROP CONSTRAINT IF EXISTS "content_categories_pkey";
ALTER TABLE "public"."user_categories" DROP CONSTRAINT IF EXISTS "user_categories_user_id_fkey";
ALTER TABLE "public"."user_categories" DROP CONSTRAINT IF EXISTS "user_categories_category_id_fkey";

-- Drop indexes
DROP INDEX IF EXISTS "public"."content_categories_category_id_idx";
DROP INDEX IF EXISTS "public"."content_categories_role_idx";
DROP INDEX IF EXISTS "public"."idx_cc_contact_id";
DROP INDEX IF EXISTS "public"."idx_dr_created_at";
DROP INDEX IF EXISTS "public"."idx_dr_source_url";
DROP INDEX IF EXISTS "public"."idx_dr_target_url";
DROP INDEX IF EXISTS "public"."idx_user_categories_category_id";
DROP INDEX IF EXISTS "public"."idx_user_categories_user_id";
DROP INDEX IF EXISTS "public"."content_categories_pkey";

-- Drop tables

drop table if exists "public"."category_topics" cascade;
drop table if exists "public"."content_categories" cascade;
drop table if exists "public"."content_embeddings" cascade;
drop table if exists "public"."content_interactions" cascade;
drop table if exists "public"."content_topics" cascade;
drop table if exists "public"."content_types" cascade;
drop table if exists "public"."contents" cascade;
drop table if exists "public"."domain_relationships" cascade;
drop table if exists "public"."graph_node_mapping" cascade;
drop table if exists "public"."organization_contents" cascade;
drop table if exists "public"."people_contents" cascade;
drop table if exists "public"."people_topics" cascade;
drop table if exists "public"."query_user" cascade;
drop table if exists "public"."reference_types" cascade;
drop table if exists "public"."social_media" cascade;
drop table if exists "public"."topic_graph_embeddings" cascade;
drop table if exists "public"."topic_mentions" cascade;
drop table if exists "public"."topic_relations" cascade;
drop table if exists "public"."bookmark_folders" CASCADE;
drop table if exists "public"."bookmarks" CASCADE;
drop table if exists "public"."comments" CASCADE;
drop table if exists "public"."feature_engagements" CASCADE;
drop table if exists "public"."topic_comments" CASCADE;
drop table if exists "public"."votes" CASCADE;
drop table if exists "public"."domain_documents" CASCADE;

-- ========================================
-- 🔥 DROP LEGACY TABLES (Permissions, Tags, Ads, Metrics)
-- ========================================

-- legacy, we can just use the new taxonomy layer to handle this
DROP TABLE IF EXISTS public.feed_categories CASCADE;
DROP TABLE IF EXISTS public.feed_sources CASCADE;
DROP TABLE IF EXISTS public.feeds CASCADE;

-- dropped in preparation for simplified ad flow
DROP TABLE IF EXISTS public.ad_daily_metrics CASCADE;
DROP TABLE IF EXISTS public.ad_packages CASCADE;
DROP TABLE IF EXISTS public.ad_variants CASCADE;
DROP TABLE IF EXISTS public.ads CASCADE;

-- replaced with organizations entity table
DROP TABLE IF EXISTS public.companies CASCADE;
DROP TABLE IF EXISTS public.company_employees CASCADE;
DROP TABLE IF EXISTS public.company_contacts CASCADE;
DROP TABLE IF EXISTS public.company_extras CASCADE;
DROP TABLE IF EXISTS public.company_metrics CASCADE;


-- not needed, we have domain_blacklist this is enough
DROP TABLE IF EXISTS public.domain_whitelist CASCADE;

-- not planned yet, removed for now
DROP TABLE IF EXISTS public.follows CASCADE;

-- legacy, not needed now
DROP TABLE IF EXISTS public.referrals CASCADE;
DROP TABLE IF EXISTS public.referrer_blocks CASCADE;
DROP TABLE IF EXISTS public.blocked_ips CASCADE;

-- dropped in preperation for simplified permissions flow
DROP TABLE IF EXISTS public.plan_permissions CASCADE;
DROP TABLE IF EXISTS public.role_hierarchy CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.role_permissions_materialized CASCADE;

-- was used to assign weight to different interactions like votes, comments, bookmarks - this needs proper planning
DROP TABLE IF EXISTS public.scoring_weights CASCADE;

-- duplicate of crawler_stats
DROP TABLE IF EXISTS public.spider_metrics CASCADE;

-- legacy, need to plan this out properly, only important once we are scaling
DROP TABLE IF EXISTS public.table_maintenance_log CASCADE;
DROP TABLE IF EXISTS public.table_query_performance CASCADE;
DROP TABLE IF EXISTS public.table_sequence_usage CASCADE;
DROP TABLE IF EXISTS public.table_statistics CASCADE;

-- overcomplication, not needed now
DROP TABLE IF EXISTS public.user_metrics CASCADE;
-- not being used
DROP TABLE IF EXISTS public.metric_definitions CASCADE;

-- REPLACED WITH topics FROM NEW TAXONOMY LAYER
DROP TABLE IF EXISTS public.tags CASCADE;
DROP TABLE IF EXISTS public.user_tags CASCADE;
DROP TABLE IF EXISTS public.content_tags CASCADE;


DROP TABLE IF EXISTS public.business_domains CASCADE;
DROP TABLE IF EXISTS public.domain_blacklist CASCADE;

DROP TABLE IF EXISTS public.query_user CASCADE;
DROP TABLE IF EXISTS public.queries CASCADE;


-- NOT NEEDED SINCE USING MASTRA WHICH USES mastra SCHEMA
DROP TABLE IF EXISTS public.workflows CASCADE;

-- we now use the main content_sources table as our primary way for content ingestion, and the statuses table to track the review process
DROP TABLE IF EXISTS public.domain_content CASCADE;
DROP TABLE IF EXISTS public.domain_content_sources CASCADE;


-- ========================================
-- 🧹 DROP LEGACY VIEWS & MATERIALIZED VIEWS
-- ========================================

DROP MATERIALIZED VIEW IF EXISTS public.referral_stats;
DROP MATERIALIZED VIEW IF EXISTS public.referrer_risk_metrics;

DROP VIEW IF EXISTS public.security_metrics;
DROP VIEW IF EXISTS public.slow_query_patterns;

-- ========================================
-- 🧽 CLEANUP DEPRECATED TABLES
-- ========================================


-- Drop materialized view (will be recreated)
DROP MATERIALIZED VIEW IF EXISTS "public"."topic_feeds_mview";
-- Drop views and materialized views
drop view if exists "public"."discovery_query_performance";
drop view if exists "public"."discovery_table_stats";
drop view if exists "public"."graph_routes_v1";
drop materialized view if exists "public"."topic_hierarchy_mview";


-- Drop indexes that reference old column names
DROP INDEX IF EXISTS "public"."idx_crawl_stats_company_id";
DROP INDEX IF EXISTS "public"."idx_domain_urls_company_id";
DROP INDEX IF EXISTS "public"."idx_user_content_moderation";

DROP TABLE IF EXISTS public.contacts CASCADE;


-- =============================================================================
-- SECTION 2: DROP OPERATIONS - TRIGGERS, VIEWS, FUNCTIONS
-- =============================================================================



-- Drop triggers
drop trigger if exists "insert_user_metadata_trigger" on "public"."user_profiles";
drop trigger if exists "update_user_app_metadata_trigger" on "public"."user_profiles";
drop trigger if exists "update_user_metadata_trigger" on "public"."user_profiles";


-- Drop functions
drop function if exists "public"."handle_send_webhook"();
drop function if exists "public"."set_user_plan_and_role"() cascade;
drop function if exists "public"."should_send_webhook"(table_name text, operation text, old_record record, new_record record);
drop function if exists "public"."update_user_app_metadata"();
drop function if exists "public"."update_user_metadata"();


-- ============================================================================
-- 2. FUNCTION CLEANUP
-- ============================================================================

-- Analytics and scoring functions
DROP FUNCTION IF EXISTS "public"."calculate_hot_score"(bigint, bigint, timestamptz, double precision, double precision, double precision, double precision);
DROP FUNCTION IF EXISTS "public"."calculate_table_growth"(text, timestamptz);
DROP FUNCTION IF EXISTS "public"."calculate_table_growth"(text, interval, integer);
DROP FUNCTION IF EXISTS "public"."update_content_score"(uuid, integer);
DROP FUNCTION IF EXISTS "public"."update_hot_score_for_content"();
DROP FUNCTION IF EXISTS "public"."update_vote_accuracy"(uuid);
DROP FUNCTION IF EXISTS "public"."update_vote_metrics"();
DROP FUNCTION IF EXISTS "public"."update_feature_vote_counts"();

-- Maintenance and monitoring functions
DROP FUNCTION IF EXISTS "public"."cleanup_expired_locks"();
DROP FUNCTION IF EXISTS "public"."cleanup_table_stats"();
DROP FUNCTION IF EXISTS "public"."execute_weekly_maintenance"();
DROP FUNCTION IF EXISTS "public"."perform_weekly_maintenance"();
DROP FUNCTION IF EXISTS "public"."maintain_user_metrics"();
DROP FUNCTION IF EXISTS "public"."ensure_user_metrics"();

-- Database analysis functions
DROP FUNCTION IF EXISTS "public"."gather_database_stats"();
DROP FUNCTION IF EXISTS "public"."get_autovacuum_candidates"();
DROP FUNCTION IF EXISTS "public"."get_available_tables"();
DROP FUNCTION IF EXISTS "public"."get_column_metadata"(text);
DROP FUNCTION IF EXISTS "public"."get_connection_stats"();
DROP FUNCTION IF EXISTS "public"."get_connection_usage"();
DROP FUNCTION IF EXISTS "public"."get_duplicate_indexes"();
DROP FUNCTION IF EXISTS "public"."get_fragmented_objects"();
DROP FUNCTION IF EXISTS "public"."get_high_sequence_usage"();
DROP FUNCTION IF EXISTS "public"."get_indexes_to_reindex"();
DROP FUNCTION IF EXISTS "public"."get_long_running_transactions"();
DROP FUNCTION IF EXISTS "public"."get_maintenance_objects"();
DROP FUNCTION IF EXISTS "public"."get_suboptimal_queries"();
DROP FUNCTION IF EXISTS "public"."get_table_structure"(text);
DROP FUNCTION IF EXISTS "public"."get_tables_to_vacuum"();

-- Content and user functions
DROP FUNCTION IF EXISTS "public"."get_latest_articles"(text[], integer);
DROP FUNCTION IF EXISTS "public"."generate_content_signature"(text);
DROP FUNCTION IF EXISTS "public"."extract_base_url"(text);
DROP FUNCTION IF EXISTS "public"."increment_field"(text, text, uuid);
DROP FUNCTION IF EXISTS "public"."update_source_visit_metrics"();

-- Error and analytics functions
DROP FUNCTION IF EXISTS "public"."get_errors_by_timerange"(timestamptz, timestamptz);
DROP FUNCTION IF EXISTS "public"."clear_ip_reputation_cache"(inet);
DROP FUNCTION IF EXISTS "public"."refresh_referral_stats"();
DROP FUNCTION IF EXISTS "public"."refresh_risk_metrics"();

-- Ad system functions
DROP FUNCTION IF EXISTS "public"."get_active_ads"();
DROP FUNCTION IF EXISTS "public"."get_active_ads"(text);
DROP FUNCTION IF EXISTS "public"."get_ad_analytics"(timestamptz);
DROP FUNCTION IF EXISTS "public"."get_ad_daily_trends"(uuid, timestamptz);
DROP FUNCTION IF EXISTS "public"."get_ad_variant_metrics"(uuid);

-- Permission system functions
DROP FUNCTION IF EXISTS "public"."get_inherited_permissions"("public"."app_role_enum");
DROP FUNCTION IF EXISTS "public"."get_inherited_roles"("public"."app_role_enum");
DROP FUNCTION IF EXISTS "public"."insert_role_permission"("public"."app_role_enum", text, jsonb, jsonb, "public"."app_role_enum"[]);
DROP FUNCTION IF EXISTS "public"."process_direct_permissions"(jsonb, text, "public"."app_role_enum"[]);
DROP FUNCTION IF EXISTS "public"."process_inherited_permissions"(jsonb, text, "public"."app_role_enum", "public"."app_role_enum"[]);
DROP FUNCTION IF EXISTS "public"."refresh_materialized_permissions"();
DROP FUNCTION IF EXISTS "public"."refresh_materialized_permissions_trigger"();
DROP FUNCTION IF EXISTS "public"."setup_role_hierarchy"();
DROP FUNCTION IF EXISTS "public"."update_role_permissions"(jsonb);

-- Job queue and legacy functions
DROP FUNCTION IF EXISTS "public"."pgboss_send"(text, jsonb, jsonb);
DROP FUNCTION IF EXISTS "public"."compute_company_relationships"();

-- ============================================================================
-- 3. TYPE CLEANUP
-- ============================================================================

-- ===================================
-- DROP ENUMS
-- ===================================

DROP TYPE IF EXISTS public.contact_type CASCADE;
DROP TYPE IF EXISTS public.content_status CASCADE;
DROP TYPE IF EXISTS public.content_status__old_version_to_be_dropped CASCADE;
DROP TYPE IF EXISTS public.discount_period CASCADE;
DROP TYPE IF EXISTS public.discount_type CASCADE;
DROP TYPE IF EXISTS public.embedding_status CASCADE;
DROP TYPE IF EXISTS public.followed_entity CASCADE;
DROP TYPE IF EXISTS public.job_priority CASCADE;
DROP TYPE IF EXISTS public.job_status CASCADE;
DROP TYPE IF EXISTS public.news_importance_level CASCADE;
DROP TYPE IF EXISTS public.news_relation_type CASCADE;
DROP TYPE IF EXISTS public.priority CASCADE;
DROP TYPE IF EXISTS public.privacy_level CASCADE;
DROP TYPE IF EXISTS public.referral_status CASCADE;
DROP TYPE IF EXISTS public.remote_status CASCADE;
DROP TYPE IF EXISTS public.scrape_frequency CASCADE;
DROP TYPE IF EXISTS public.user_status CASCADE;
DROP TYPE IF EXISTS "public"."access_level";
DROP TYPE IF EXISTS "public"."address_type";
DROP TYPE IF EXISTS "public"."complexity_level";
DROP TYPE IF EXISTS "public"."content_type";
DROP TYPE IF EXISTS "public"."error_severity";
DROP TYPE IF EXISTS "public"."error_type";
DROP TYPE IF EXISTS "public"."feedback_status";
DROP TYPE IF EXISTS "public"."feedback_type";


-- ============================================================================
-- 3. ENUM UPDATES
-- ============================================================================

-- Update content_status enum
ALTER TYPE "public"."content_status" RENAME TO "content_status__old_version_to_be_dropped";
CREATE TYPE "public"."content_status" AS ENUM (
   'pending_crawl', 'scraped', 'processing', 'indexing', 'pending_review', 
   'irrelevant', 'retracted', 'draft', 'scheduled', 'published', 
   'archived', 'failed', 'flagged', 'unpublished'
);


-- ============================================================================
-- 6. EXISTING TABLE MODIFICATIONS
-- ============================================================================

-- Update categories table
ALTER TABLE "public"."categories" 
DROP COLUMN IF EXISTS "document_id",
DROP COLUMN IF EXISTS "id_old",
ADD COLUMN IF NOT EXISTS "description" TEXT,
ADD COLUMN IF NOT EXISTS "published_at_timestamptz" TIMESTAMPTZ;

-- Modify column types and defaults
ALTER TABLE "public"."categories" 
ALTER COLUMN "body" TYPE TEXT,
ALTER COLUMN "created_at" DROP DEFAULT,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "locale" TYPE TEXT,
ALTER COLUMN "name" TYPE TEXT,
ALTER COLUMN "published_at" TYPE TEXT,
ALTER COLUMN "updated_at" DROP DEFAULT;

-- Update user_categories
ALTER TABLE "public"."user_categories" 
ALTER COLUMN "created_at" SET DEFAULT NOW();

-- ============================================================================
-- 7. FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- User interactions
ALTER TABLE "public"."user_topics" 
ADD CONSTRAINT "user_topics_topic_id_fkey" 
FOREIGN KEY ("topic_id") REFERENCES "public"."topics"("id") ON DELETE CASCADE;

ALTER TABLE "public"."user_categories" 
ADD CONSTRAINT "user_categories_category_id_fkey" 
FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;

-- ============================================================================
-- 8. TRIGGERS
-- ============================================================================


COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Drop old enum: DROP TYPE "public"."content_status__old_version_to_be_dropped";
-- 2. Update application to use new content_status values
-- 3. Consider adding indexes based on query patterns
-- 4. Validate vector dimensions match embedding model outputs
-- ============================================================================