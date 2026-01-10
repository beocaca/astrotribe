
-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Apply triggers to main table (inherited by partitions)
DO $$ BEGIN
    -- Updated timestamp trigger
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_graph_edges_timestamp' AND event_object_table = 'graph_edges') THEN
        CREATE TRIGGER update_graph_edges_timestamp 
            BEFORE UPDATE ON public.graph_edges 
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
    END IF;
    
    -- Edge type validation trigger
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'validate_edge_type_trigger' AND event_object_table = 'graph_edges') THEN
        CREATE TRIGGER validate_edge_type_trigger 
            BEFORE INSERT ON public.graph_edges 
            FOR EACH ROW EXECUTE FUNCTION public.validate_edge_type();
    END IF;
END $$;

-- Triggers for relationship tables
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_profile_links_timestamp' AND event_object_table = 'profile_links') THEN
        CREATE TRIGGER update_profile_links_timestamp 
            BEFORE UPDATE ON public.profile_links 
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
    END IF;
END $$;

-- =============================================================================
-- SECTION 16: ADD TRIGGERS
-- =============================================================================

CREATE TRIGGER update_allowed_edge_types_timestamp BEFORE UPDATE ON public.allowed_edge_types FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_customer_payments_timestamp BEFORE UPDATE ON public.customer_payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_customer_processed_webhooks_timestamp BEFORE UPDATE ON public.customer_processed_webhooks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_customer_refunds_timestamp BEFORE UPDATE ON public.customer_refunds FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_domain_assets_timestamp BEFORE UPDATE ON public.domain_assets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_domain_contacts_timestamp BEFORE UPDATE ON public.domain_contacts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_domain_roots_timestamp BEFORE UPDATE ON public.domain_roots FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_graph_edges_authorship_timestamp BEFORE UPDATE ON public.graph_edges_authorship FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_graph_edges_citation_timestamp BEFORE UPDATE ON public.graph_edges_citation FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_graph_edges_experimental_timestamp BEFORE UPDATE ON public.graph_edges_experimental FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_graph_edges_organizational_timestamp BEFORE UPDATE ON public.graph_edges_organizational FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_graph_edges_semantic_timestamp BEFORE UPDATE ON public.graph_edges_semantic FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_organization_people_timestamp BEFORE UPDATE ON public.organization_people FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_status_history_timestamp BEFORE UPDATE ON public.status_history FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_user_categories_timestamp BEFORE UPDATE ON public.user_categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_user_topics_timestamp BEFORE UPDATE ON public.user_topics FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_content_sources_timestamp 
  BEFORE UPDATE ON public.content_sources 
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_news_timestamp 
  BEFORE UPDATE ON public.news 
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_opportunities_timestamp 
  BEFORE UPDATE ON public.opportunities 
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- Update timestamp trigger for status registry
CREATE TRIGGER update_statuses_timestamp 
    BEFORE UPDATE ON public.statuses 
    FOR EACH ROW 
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_contacts_timestamp 
BEFORE UPDATE ON "public"."contacts" 
FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER update_permission_configs_timestamp BEFORE UPDATE ON public.permission_configs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


CREATE TRIGGER update_organizations_timestamp 
BEFORE UPDATE ON "public"."organizations" 
FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();

CREATE TRIGGER update_people_timestamp 
BEFORE UPDATE ON "public"."people" 
FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();


CREATE TRIGGER update_topics_timestamp 
BEFORE UPDATE ON "public"."topics" 
FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();
