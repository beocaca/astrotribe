-- ============================================================================
-- DATABASE RESET AND TOPICS SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Clean slate migration - drops legacy systems, establishes topics core
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. EXTENSIONS SETUP
-- ============================================================================
DROP EXTENSION IF EXISTS "vector" CASCADE;
CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "extensions" VERSION '0.8.0';
CREATE EXTENSION IF NOT EXISTS "btree_gin" WITH SCHEMA "extensions" VERSION '1.3';
CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "extensions" VERSION '1.6';
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions" VERSION '3.3.7';
CREATE EXTENSION IF NOT EXISTS "pgrouting" WITH SCHEMA "extensions" VERSION '3.4.1';
CREATE EXTENSION IF NOT EXISTS "unaccent" WITH SCHEMA "extensions" VERSION '1.1';
CREATE EXTENSION IF NOT EXISTS "hypopg" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "index_advisor" WITH SCHEMA "extensions";

-- ============================================================================
-- 2. COMPLETE SYSTEM CLEANUP
-- ============================================================================

-- ===================================
-- 2.1 DROP MATERIALIZED VIEWS
-- ===================================
DROP MATERIALIZED VIEW IF EXISTS public.referral_stats CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.referrer_risk_metrics CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.topic_feeds_mview CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.topic_hierarchy_mview CASCADE;

-- ===================================
-- 2.2 DROP VIEWS
-- ===================================
DROP VIEW IF EXISTS public.discovery_query_performance CASCADE;
DROP VIEW IF EXISTS public.discovery_table_stats CASCADE;
DROP VIEW IF EXISTS public.graph_routes_v1 CASCADE;
DROP VIEW IF EXISTS public.security_metrics CASCADE;
DROP VIEW IF EXISTS public.slow_query_patterns CASCADE;

-- ===================================
-- 2.3 DROP TRIGGERS
-- ===================================
DROP TRIGGER IF EXISTS insert_user_metadata_trigger ON public.user_profiles;
DROP TRIGGER IF EXISTS update_user_app_metadata_trigger ON public.user_profiles;
DROP TRIGGER IF EXISTS update_user_metadata_trigger ON public.user_profiles;

-- ===================================
-- 2.4 DROP FUNCTIONS (Grouped by Domain)
-- ===================================

-- Analytics and scoring
DROP FUNCTION IF EXISTS public.calculate_hot_score(bigint, bigint, timestamptz, double precision, double precision, double precision, double precision) CASCADE;
DROP FUNCTION IF EXISTS public.calculate_table_growth(text, timestamptz) CASCADE;
DROP FUNCTION IF EXISTS public.calculate_table_growth(text, interval, integer) CASCADE;
DROP FUNCTION IF EXISTS public.update_content_score(uuid, integer) CASCADE;
DROP FUNCTION IF EXISTS public.update_hot_score_for_content() CASCADE;
DROP FUNCTION IF EXISTS public.update_vote_accuracy(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.update_vote_metrics() CASCADE;
DROP FUNCTION IF EXISTS public.update_feature_vote_counts() CASCADE;

-- Database maintenance
DROP FUNCTION IF EXISTS public.cleanup_expired_locks() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_table_stats() CASCADE;
DROP FUNCTION IF EXISTS public.execute_weekly_maintenance() CASCADE;
DROP FUNCTION IF EXISTS public.perform_weekly_maintenance() CASCADE;
DROP FUNCTION IF EXISTS public.maintain_user_metrics() CASCADE;
DROP FUNCTION IF EXISTS public.ensure_user_metrics() CASCADE;
DROP FUNCTION IF EXISTS public.gather_database_stats() CASCADE;
DROP FUNCTION IF EXISTS public.get_autovacuum_candidates() CASCADE;
DROP FUNCTION IF EXISTS public.get_available_tables() CASCADE;
DROP FUNCTION IF EXISTS public.get_column_metadata(text) CASCADE;
DROP FUNCTION IF EXISTS public.get_connection_stats() CASCADE;
DROP FUNCTION IF EXISTS public.get_connection_usage() CASCADE;
DROP FUNCTION IF EXISTS public.get_duplicate_indexes() CASCADE;
DROP FUNCTION IF EXISTS public.get_fragmented_objects() CASCADE;
DROP FUNCTION IF EXISTS public.get_high_sequence_usage() CASCADE;
DROP FUNCTION IF EXISTS public.get_indexes_to_reindex() CASCADE;
DROP FUNCTION IF EXISTS public.get_long_running_transactions() CASCADE;
DROP FUNCTION IF EXISTS public.get_maintenance_objects() CASCADE;
DROP FUNCTION IF EXISTS public.get_suboptimal_queries() CASCADE;
DROP FUNCTION IF EXISTS public.get_table_structure(text) CASCADE;
DROP FUNCTION IF EXISTS public.get_tables_to_vacuum() CASCADE;

-- Content and user management
DROP FUNCTION IF EXISTS public.get_latest_articles(text[], integer) CASCADE;
DROP FUNCTION IF EXISTS public.generate_content_signature(text) CASCADE;
DROP FUNCTION IF EXISTS public.extract_base_url(text) CASCADE;
DROP FUNCTION IF EXISTS public.increment_field(text, text, uuid) CASCADE;
DROP FUNCTION IF EXISTS public.update_source_visit_metrics() CASCADE;
DROP FUNCTION IF EXISTS public.get_errors_by_timerange(timestamptz, timestamptz) CASCADE;
DROP FUNCTION IF EXISTS public.clear_ip_reputation_cache(inet) CASCADE;
DROP FUNCTION IF EXISTS public.refresh_referral_stats() CASCADE;
DROP FUNCTION IF EXISTS public.refresh_risk_metrics() CASCADE;

-- Ad system
DROP FUNCTION IF EXISTS public.get_active_ads() CASCADE;
DROP FUNCTION IF EXISTS public.get_active_ads(text) CASCADE;
DROP FUNCTION IF EXISTS public.get_ad_analytics(timestamptz) CASCADE;
DROP FUNCTION IF EXISTS public.get_ad_daily_trends(uuid, timestamptz) CASCADE;
DROP FUNCTION IF EXISTS public.get_ad_variant_metrics(uuid) CASCADE;

-- Permission system
DROP FUNCTION IF EXISTS public.get_inherited_permissions(public.app_role_enum) CASCADE;
DROP FUNCTION IF EXISTS public.get_inherited_roles(public.app_role_enum) CASCADE;
DROP FUNCTION IF EXISTS public.insert_role_permission(public.app_role_enum, text, jsonb, jsonb, public.app_role_enum[]) CASCADE;
DROP FUNCTION IF EXISTS public.process_direct_permissions(jsonb, text, public.app_role_enum[]) CASCADE;
DROP FUNCTION IF EXISTS public.process_inherited_permissions(jsonb, text, public.app_role_enum, public.app_role_enum[]) CASCADE;
DROP FUNCTION IF EXISTS public.refresh_materialized_permissions() CASCADE;
DROP FUNCTION IF EXISTS public.refresh_materialized_permissions_trigger() CASCADE;
DROP FUNCTION IF EXISTS public.setup_role_hierarchy() CASCADE;
DROP FUNCTION IF EXISTS public.update_role_permissions(jsonb) CASCADE;

-- User metadata and auth
DROP FUNCTION IF EXISTS public.handle_send_webhook() CASCADE;
DROP FUNCTION IF EXISTS public.set_user_plan_and_role() CASCADE;
DROP FUNCTION IF EXISTS public.should_send_webhook(text, text, record, record) CASCADE;
DROP FUNCTION IF EXISTS public.update_user_app_metadata() CASCADE;
DROP FUNCTION IF EXISTS public.update_user_metadata() CASCADE;

-- Legacy and miscellaneous
DROP FUNCTION IF EXISTS public.pgboss_send(text, jsonb, jsonb) CASCADE;
DROP FUNCTION IF EXISTS public.compute_company_relationships() CASCADE;

-- ===================================
-- 2.5 DROP ENUMS
-- ===================================
DROP TYPE IF EXISTS public.access_level CASCADE;
DROP TYPE IF EXISTS public.address_type CASCADE;
DROP TYPE IF EXISTS public.complexity_level CASCADE;
DROP TYPE IF EXISTS public.contact_type CASCADE;
DROP TYPE IF EXISTS public.content_status CASCADE;
DROP TYPE IF EXISTS public.content_status__old_version_to_be_dropped CASCADE;
DROP TYPE IF EXISTS public.content_type CASCADE;
DROP TYPE IF EXISTS public.embedding_status CASCADE;
DROP TYPE IF EXISTS public.error_severity CASCADE;
DROP TYPE IF EXISTS public.error_type CASCADE;
DROP TYPE IF EXISTS public.feedback_status CASCADE;
DROP TYPE IF EXISTS public.feedback_type CASCADE;
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

ALTER TYPE public.discount_type RENAME TO discount_type_enum;
ALTER TYPE public.discount_period RENAME TO discount_period_enum;

-- ===================================
-- 2.6 DROP TABLES (Organized by Domain)
-- ===================================

-- Content system
DROP TABLE IF EXISTS public.category_topics CASCADE;
DROP TABLE IF EXISTS public.content_categories CASCADE;
DROP TABLE IF EXISTS public.content_embeddings CASCADE;
DROP TABLE IF EXISTS public.content_interactions CASCADE;
DROP TABLE IF EXISTS public.content_topics CASCADE;
DROP TABLE IF EXISTS public.content_types CASCADE;
DROP TABLE IF EXISTS public.contents CASCADE;
DROP TABLE IF EXISTS public.content_tags CASCADE;
DROP TABLE IF EXISTS public.domain_documents CASCADE;
DROP TABLE IF EXISTS public.domain_relationships CASCADE;
DROP TABLE IF EXISTS public.organization_contents CASCADE;
DROP TABLE IF EXISTS public.people_contents CASCADE;
DROP TABLE IF EXISTS public.role_permissions_materialized CASCADE;

-- User interactions
DROP TABLE IF EXISTS public.bookmarks CASCADE;
DROP TABLE IF EXISTS public.bookmark_folders CASCADE;
DROP TABLE IF EXISTS public.comments CASCADE;
DROP TABLE IF EXISTS public.feature_engagements CASCADE;
DROP TABLE IF EXISTS public.topic_comments CASCADE;
DROP TABLE IF EXISTS public.votes CASCADE;

-- Topics and graph
DROP TABLE IF EXISTS public.graph_node_mapping CASCADE;
DROP TABLE IF EXISTS public.people_topics CASCADE;
DROP TABLE IF EXISTS public.topic_graph_embeddings CASCADE;
DROP TABLE IF EXISTS public.topic_mentions CASCADE;
DROP TABLE IF EXISTS public.topic_relations CASCADE;

-- Legacy content management
DROP TABLE IF EXISTS public.feed_categories CASCADE;
DROP TABLE IF EXISTS public.feed_sources CASCADE;
DROP TABLE IF EXISTS public.feeds CASCADE;
DROP TABLE IF EXISTS public.tags CASCADE;
DROP TABLE IF EXISTS public.user_tags CASCADE;

-- Ad system
DROP TABLE IF EXISTS public.ad_daily_metrics CASCADE;
DROP TABLE IF EXISTS public.ad_packages CASCADE;
DROP TABLE IF EXISTS public.ad_variants CASCADE;
DROP TABLE IF EXISTS public.ads CASCADE;

-- Company/organization legacy
DROP TABLE IF EXISTS public.companies CASCADE;
DROP TABLE IF EXISTS public.company_employees CASCADE;
DROP TABLE IF EXISTS public.company_contacts CASCADE;
DROP TABLE IF EXISTS public.company_extras CASCADE;
DROP TABLE IF EXISTS public.company_metrics CASCADE;
DROP TABLE IF EXISTS public.contacts CASCADE;
DROP TABLE IF EXISTS public.newsletters CASCADE;
DROP TABLE IF EXISTS public.social_media CASCADE;

-- Security and moderation
DROP TABLE IF EXISTS public.domain_whitelist CASCADE;
DROP TABLE IF EXISTS public.domain_blacklist CASCADE;
DROP TABLE IF EXISTS public.business_domains CASCADE;
DROP TABLE IF EXISTS public.blocked_ips CASCADE;
DROP TABLE IF EXISTS public.referrals CASCADE;
DROP TABLE IF EXISTS public.referrer_blocks CASCADE;

-- Permission system
DROP TABLE IF EXISTS public.plan_permissions CASCADE;
DROP TABLE IF EXISTS public.role_hierarchy CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;

-- Analytics and metrics
DROP TABLE IF EXISTS public.scoring_weights CASCADE;
DROP TABLE IF EXISTS public.spider_metrics CASCADE;
DROP TABLE IF EXISTS public.table_maintenance_log CASCADE;
DROP TABLE IF EXISTS public.table_query_performance CASCADE;
DROP TABLE IF EXISTS public.table_sequence_usage CASCADE;
DROP TABLE IF EXISTS public.table_statistics CASCADE;
DROP TABLE IF EXISTS public.user_metrics CASCADE;
DROP TABLE IF EXISTS public.metric_definitions CASCADE;

-- Query and workflow systems
DROP TABLE IF EXISTS public.query_user CASCADE;
DROP TABLE IF EXISTS public.queries CASCADE;
DROP TABLE IF EXISTS public.workflows CASCADE;

-- Legacy domain content
DROP TABLE IF EXISTS public.domain_content CASCADE;
DROP TABLE IF EXISTS public.domain_content_sources CASCADE;

-- Miscellaneous
DROP TABLE IF EXISTS public.follows CASCADE;

-- ============================================================================
-- 4. UPDATE EXISTING TABLES
-- ============================================================================

-- Categories table updates
ALTER TABLE public.categories 
    DROP COLUMN IF EXISTS document_id,
    DROP COLUMN IF EXISTS id_old,
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS published_at_timestamptz TIMESTAMPTZ,
    ALTER COLUMN body TYPE TEXT,
    ALTER COLUMN created_at DROP DEFAULT,
    ALTER COLUMN id DROP DEFAULT,
    ALTER COLUMN locale TYPE TEXT,
    ALTER COLUMN name TYPE TEXT,
    ALTER COLUMN published_at TYPE TEXT,
    ALTER COLUMN updated_at DROP DEFAULT;

-- User categories updates
ALTER TABLE public.user_categories 
    ALTER COLUMN created_at SET DEFAULT NOW();


COMMIT;

-- ============================================================================
-- POST-MIGRATION CLEANUP
-- ============================================================================
-- 1. Validate all foreign keys are working
-- 2. Add performance indexes based on query patterns
-- 3. Update application code to use new schemas
-- 4. Run VACUUM ANALYZE on modified tables
-- ============================================================================