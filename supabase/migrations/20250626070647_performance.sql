-- ============================================================================
-- GRAPH CLEANUP AND COMPUTED COLUMNS MIGRATION - STANDARDS COMPLIANT
-- ============================================================================
-- Purpose: Major schema refactoring - add bigint IDs and computed columns
-- Date: 2025-06-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. DROP EXISTING NON-COMPLIANT INDEXES
-- ============================================================================

-- Drop indexes that don't follow naming conventions
DROP INDEX IF EXISTS idx_content_discovery_news;
DROP INDEX IF EXISTS idx_content_discovery_research; 
DROP INDEX IF EXISTS idx_content_discovery_topics;
DROP INDEX IF EXISTS idx_directory_organizations;
DROP INDEX IF EXISTS idx_directory_people;
DROP INDEX IF EXISTS idx_topic_clusters_lookup;
DROP INDEX IF EXISTS idx_topic_clusters_entities;
DROP INDEX IF EXISTS idx_graph_edges_pgr_native;
DROP INDEX IF EXISTS idx_graph_edges_source;
DROP INDEX IF EXISTS idx_graph_edges_target;
DROP INDEX IF EXISTS graph_edges_authorship_unique_edge;
DROP INDEX IF EXISTS graph_edges_authorship_source_id_source_type_idx;
DROP INDEX IF EXISTS graph_edges_authorship_target_id_target_type_idx;
DROP INDEX IF EXISTS idx_authorship_topic_cluster_critical;
DROP INDEX IF EXISTS graph_edges_citation_unique_edge;
DROP INDEX IF EXISTS graph_edges_citation_source_id_source_type_idx;
DROP INDEX IF EXISTS graph_edges_citation_target_id_target_type_idx;
DROP INDEX IF EXISTS graph_edges_semantic_unique_edge;
DROP INDEX IF EXISTS graph_edges_semantic_source_id_source_type_idx;
DROP INDEX IF EXISTS graph_edges_semantic_target_id_target_type_idx;
DROP INDEX IF EXISTS graph_edges_organizational_unique_edge;
DROP INDEX IF EXISTS graph_edges_organizational_source_id_source_type_idx;
DROP INDEX IF EXISTS graph_edges_organizational_target_id_target_type_idx;
DROP INDEX IF EXISTS graph_edges_experimental_unique_edge;
DROP INDEX IF EXISTS graph_edges_experimental_source_id_source_type_idx;
DROP INDEX IF EXISTS graph_edges_experimental_target_id_target_type_idx;
DROP INDEX IF EXISTS topics_embedding_hnsw_idx;
DROP INDEX IF EXISTS idx_user_topics_subscriptions;
DROP INDEX IF EXISTS idx_permission_configs_enabled;
DROP INDEX IF EXISTS idx_permission_configs_role_plan;

-- ============================================================================
-- 2. CONTENT DISCOVERY INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- Content discovery indexes with proper naming
CREATE INDEX idx_news_content_discovery 
ON public.news (is_public_computed, is_approved_computed, moderation_status) 
WHERE (is_public_computed = true) AND (is_approved_computed = true) AND (moderation_status = 'safe');

CREATE INDEX idx_research_content_discovery 
ON public.research (is_public_computed, is_approved_computed, moderation_status) 
WHERE (is_public_computed = true) AND (is_approved_computed = true) AND (moderation_status = 'safe');

CREATE INDEX idx_topics_content_discovery 
ON public.topics (is_public_computed, is_approved_computed, moderation_status) 
WHERE (is_public_computed = true) AND (is_approved_computed = true) AND (moderation_status = 'safe');

-- Directory indexes with proper naming
CREATE INDEX idx_organizations_directory_ready 
ON public.organizations (is_directory_ready_computed, is_flagged_computed) 
WHERE (is_directory_ready_computed = true) AND (is_flagged_computed = false);

CREATE INDEX idx_people_directory_ready 
ON public.people (is_directory_ready_computed, is_flagged_computed) 
WHERE (is_directory_ready_computed = true) AND (is_flagged_computed = false);

-- ============================================================================
-- 3. TOPIC CLUSTERS AND GRAPH INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- Topic cluster performance indexes
CREATE INDEX idx_topic_clusters_topic_bigint_id 
ON public.topic_clusters (topic_bigint_id);

CREATE INDEX idx_topic_clusters_entity_arrays 
ON public.topic_clusters 
USING gin (people_bigint_ids, research_bigint_ids, news_bigint_ids, organization_bigint_ids);

-- Graph edge performance indexes
CREATE INDEX idx_graph_edges_source_target_type 
ON public.graph_edges (source_id, target_id, edge_type);

CREATE INDEX idx_graph_edges_source_lookup 
ON public.graph_edges (source_id, source_type);

CREATE INDEX idx_graph_edges_target_lookup 
ON public.graph_edges (target_id, target_type);

-- ============================================================================
-- 4. UUID TO BIGINT MAPPING INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- UUID to bigint mapping indexes for performance
CREATE INDEX idx_astronomy_events_id_bigint_id ON public.astronomy_events (id, bigint_id);
CREATE INDEX idx_categories_id_bigint_id ON public.categories (id, bigint_id);
CREATE INDEX idx_news_id_bigint_id ON public.news (id, bigint_id);
CREATE INDEX idx_opportunities_id_bigint_id ON public.opportunities (id, bigint_id);
CREATE INDEX idx_organizations_id_bigint_id ON public.organizations (id, bigint_id);
CREATE INDEX idx_people_id_bigint_id ON public.people (id, bigint_id);
CREATE INDEX idx_research_id_bigint_id ON public.research (id, bigint_id);
CREATE INDEX idx_topics_id_bigint_id ON public.topics (id, bigint_id);

-- ============================================================================
-- 5. SPECIALIZED INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- Payment history queries
CREATE INDEX idx_customer_payments_user_status_created_at 
ON public.customer_payments (user_id, status, created_at DESC);

-- Standard created_at indexes for pagination
CREATE INDEX IF NOT EXISTS idx_astronomy_events_created_at ON public.astronomy_events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_categories_created_at ON public.categories (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_created_at ON public.news (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_opportunities_created_at ON public.opportunities (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_organizations_created_at ON public.organizations (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_people_created_at ON public.people (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_research_created_at ON public.research (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_topics_created_at ON public.topics (created_at DESC);

-- Foreign key relationship indexes
CREATE INDEX IF NOT EXISTS idx_astronomy_events_organization_id ON public.astronomy_events (organization_id);
CREATE INDEX IF NOT EXISTS idx_astronomy_events_person_id ON public.astronomy_events (person_id);
CREATE INDEX IF NOT EXISTS idx_news_organization_id ON public.news (organization_id);
CREATE INDEX IF NOT EXISTS idx_news_person_id ON public.news (person_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_organization_id ON public.opportunities (organization_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_person_id ON public.opportunities (person_id);
CREATE INDEX IF NOT EXISTS idx_research_person_id ON public.research (person_id);

-- ============================================================================
-- 6. GRAPH EDGE PARTITION INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- Authorship partition indexes
CREATE UNIQUE INDEX idx_uniq_graph_edges_authorship_edge 
ON public.graph_edges_authorship (source_type, source_id, target_type, target_id, edge_type);

CREATE INDEX idx_graph_edges_authorship_source 
ON public.graph_edges_authorship (source_id, source_type);

CREATE INDEX idx_graph_edges_authorship_target 
ON public.graph_edges_authorship (target_id, target_type);

CREATE INDEX idx_graph_edges_authorship_topic_clusters 
ON public.graph_edges_authorship (target_id, source_type, confidence, source_id) 
WHERE (target_type = 'topic') AND (confidence >= 0.7);

-- Citation partition indexes
CREATE UNIQUE INDEX idx_uniq_graph_edges_citation_edge 
ON public.graph_edges_citation (source_type, source_id, target_type, target_id, edge_type);

CREATE INDEX idx_graph_edges_citation_source 
ON public.graph_edges_citation (source_id, source_type);

CREATE INDEX idx_graph_edges_citation_target 
ON public.graph_edges_citation (target_id, target_type);

-- Semantic partition indexes
CREATE UNIQUE INDEX idx_uniq_graph_edges_semantic_edge 
ON public.graph_edges_semantic (source_type, source_id, target_type, target_id, edge_type);

CREATE INDEX idx_graph_edges_semantic_source 
ON public.graph_edges_semantic (source_id, source_type);

CREATE INDEX idx_graph_edges_semantic_target 
ON public.graph_edges_semantic (target_id, target_type);

-- Organizational partition indexes
CREATE UNIQUE INDEX idx_uniq_graph_edges_organizational_edge 
ON public.graph_edges_organizational (source_type, source_id, target_type, target_id, edge_type);

CREATE INDEX idx_graph_edges_organizational_source 
ON public.graph_edges_organizational (source_id, source_type);

CREATE INDEX idx_graph_edges_organizational_target 
ON public.graph_edges_organizational (target_id, target_type);

-- Experimental partition indexes
CREATE UNIQUE INDEX idx_uniq_graph_edges_experimental_edge 
ON public.graph_edges_experimental (source_type, source_id, target_type, target_id, edge_type);

CREATE INDEX idx_graph_edges_experimental_source 
ON public.graph_edges_experimental (source_id, source_type);

CREATE INDEX idx_graph_edges_experimental_target 
ON public.graph_edges_experimental (target_id, target_type);

-- ============================================================================
-- 7. STATUS AND PERFORMANCE INDEXES - STANDARDS COMPLIANT
-- ============================================================================

-- Status History indexes
CREATE INDEX IF NOT EXISTS idx_status_history_transitioned_at 
ON public.status_history (transitioned_at DESC);

CREATE INDEX IF NOT EXISTS idx_status_history_record_id_source_table 
ON public.status_history (record_id, source_table);

CREATE INDEX IF NOT EXISTS idx_status_history_track_to_status 
ON public.status_history (track, to_status);

-- Topics embedding index
CREATE INDEX idx_topics_embedding_vector 
ON public.topics 
USING hnsw (embedding extensions.vector_cosine_ops) 
WITH (m='16', ef_construction='64') 
WHERE (embedding IS NOT NULL);

-- User subscription indexes
CREATE INDEX idx_user_topics_user_id_subscribed_at 
ON public.user_topics (user_id, subscribed_at) 
WHERE subscribed_at IS NOT NULL;

-- Permission configs indexes
CREATE INDEX idx_permission_configs_enabled_table_name 
ON public.permission_configs (enabled, table_name) 
WHERE enabled = true;

CREATE INDEX idx_permission_configs_required_role_plan 
ON public.permission_configs (required_role, required_plan) 
WHERE enabled = true;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. All indexes now follow naming standards: idx_ prefix, idx_uniq_ for unique
-- 2. Index names describe table_column_purpose pattern
-- 3. Dropped non-compliant indexes before recreating
-- 4. Monitor performance impact and adjust as needed
-- ============================================================================