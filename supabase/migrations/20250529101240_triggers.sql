-- ============================================================================
-- TRIGGERS MIGRATION
-- ============================================================================
-- Purpose: Updated timestamp triggers for all tables with updated_at columns
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. CONDITIONAL TRIGGERS (Graph System)
-- ============================================================================

DO $$ 
BEGIN
   -- Graph edges updated timestamp trigger
   IF NOT EXISTS (
       SELECT 1 FROM information_schema.triggers 
       WHERE trigger_name = 'update_graph_edges_timestamp' 
       AND event_object_table = 'graph_edges'
   ) THEN
       CREATE TRIGGER update_graph_edges_timestamp 
           BEFORE UPDATE ON public.graph_edges 
           FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
   END IF;
   
   -- Edge type validation trigger
   IF NOT EXISTS (
       SELECT 1 FROM information_schema.triggers 
       WHERE trigger_name = 'validate_edge_type_trigger' 
       AND event_object_table = 'graph_edges'
   ) THEN
       CREATE TRIGGER validate_edge_type_trigger 
           BEFORE INSERT ON public.graph_edges 
           FOR EACH ROW EXECUTE FUNCTION public.validate_edge_type();
   END IF;
   
   -- Profile links updated timestamp trigger
   IF NOT EXISTS (
       SELECT 1 FROM information_schema.triggers 
       WHERE trigger_name = 'update_profile_links_timestamp' 
       AND event_object_table = 'profile_links'
   ) THEN
       CREATE TRIGGER update_profile_links_timestamp 
           BEFORE UPDATE ON public.profile_links 
           FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
   END IF;
END $$;

-- ============================================================================
-- 2. STANDARD UPDATED_AT TRIGGERS
-- ============================================================================

-- Core system tables
CREATE TRIGGER update_allowed_edge_types_timestamp 
   BEFORE UPDATE ON public.allowed_edge_types 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_permission_configs_timestamp 
   BEFORE UPDATE ON public.permission_configs 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_statuses_timestamp 
   BEFORE UPDATE ON public.statuses 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_status_history_timestamp 
   BEFORE UPDATE ON public.status_history 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Content system tables
CREATE TRIGGER update_content_sources_timestamp 
   BEFORE UPDATE ON public.content_sources 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_news_timestamp 
   BEFORE UPDATE ON public.news 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_opportunities_timestamp 
   BEFORE UPDATE ON public.opportunities 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_topics_timestamp 
   BEFORE UPDATE ON public.topics 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Organization and people tables
CREATE TRIGGER update_organizations_timestamp 
   BEFORE UPDATE ON public.organizations 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_people_timestamp 
   BEFORE UPDATE ON public.people 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_organization_people_timestamp 
   BEFORE UPDATE ON public.organization_people 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_contacts_timestamp 
   BEFORE UPDATE ON public.contacts 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Domain processing tables
CREATE TRIGGER update_domain_assets_timestamp 
   BEFORE UPDATE ON public.domain_assets 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_domain_contacts_timestamp 
   BEFORE UPDATE ON public.domain_contacts 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_domain_roots_timestamp 
   BEFORE UPDATE ON public.domain_roots 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- User interaction tables
CREATE TRIGGER update_user_categories_timestamp 
   BEFORE UPDATE ON public.user_categories 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_topics_timestamp 
   BEFORE UPDATE ON public.user_topics 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Customer/payment tables
CREATE TRIGGER update_customer_payments_timestamp 
   BEFORE UPDATE ON public.customer_payments 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_customer_processed_webhooks_timestamp 
   BEFORE UPDATE ON public.customer_processed_webhooks 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_customer_refunds_timestamp 
   BEFORE UPDATE ON public.customer_refunds 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Graph edges partition tables
CREATE TRIGGER update_graph_edges_authorship_timestamp 
   BEFORE UPDATE ON public.graph_edges_authorship 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_graph_edges_citation_timestamp 
   BEFORE UPDATE ON public.graph_edges_citation 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_graph_edges_experimental_timestamp 
   BEFORE UPDATE ON public.graph_edges_experimental 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_graph_edges_organizational_timestamp 
   BEFORE UPDATE ON public.graph_edges_organizational 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_graph_edges_semantic_timestamp 
   BEFORE UPDATE ON public.graph_edges_semantic 
   FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Verify update_updated_at_column() function exists before applying
-- 2. Check that all tables have updated_at columns where triggers are applied
-- 3. Test trigger functionality with sample updates
-- ============================================================================