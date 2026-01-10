-- ============================================================================
-- TABLE COMMENTS
-- Generated: 2025-06-26T07:06:28.272Z
-- Purpose: Single source of truth for table comments
-- ============================================================================

COMMENT ON TABLE public.addresses IS 'domain:user | purpose:User and organization addresses with verification workflow | access:internal | frequency:low | status:review';
COMMENT ON TABLE public.allowed_edge_types IS 'domain:system | purpose:Configuration defining valid graph edge types and constraints | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.astronomy_events IS 'domain:content | purpose:Astronomy events and calendar entries for community | access:public | frequency:low | status:visibility,moderation,review';
COMMENT ON TABLE public.bookmark_folders IS 'domain:user | purpose:User bookmark organization and folder structure | access:internal | frequency:medium | status:moderation';
COMMENT ON TABLE public.bookmarks IS 'domain:user | purpose:User content bookmarks and personal collections | access:internal | frequency:medium | status:moderation';
COMMENT ON TABLE public.categories IS 'domain:content | purpose:Content categorization taxonomy with editorial review | access:public | frequency:medium | status:visibility,review,moderation';
COMMENT ON TABLE public.comments IS 'domain:user | purpose:User comments on content with moderation pipeline | access:internal | frequency:medium | status:review,moderation';
COMMENT ON TABLE public.contacts IS 'domain:user | purpose:Contact information with verification and privacy workflow | access:internal | frequency:medium | status:review,moderation';
COMMENT ON TABLE public.content_sources IS 'domain:content | purpose:tracks content sources for crawler discovery and validation | status:processing,workflow,priority,review';
COMMENT ON TABLE public.crawl_stats IS 'domain:analytics | purpose:Immutable metrics and performance data from crawling operations | access:protected | frequency:medium | status:null';
COMMENT ON TABLE public.customer_payments IS 'domain:commerce | purpose:Payment transaction processing and reconciliation tracking | access:critical | frequency:medium | status:processing,workflow';
COMMENT ON TABLE public.customer_processed_webhooks IS 'domain:system | purpose:Processing log for webhook event deduplication and tracking | access:protected | frequency:medium | status:null';
COMMENT ON TABLE public.customer_refunds IS 'domain:commerce | purpose:Immutable financial records of customer refund transactions | access:critical | frequency:low | status:null';
COMMENT ON TABLE public.customer_subscription_offers IS 'domain:commerce | purpose:Marketing configuration for subscription promotions and discounts | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.customer_subscription_plans IS 'domain:commerce | purpose:Business configuration for subscription tiers and pricing | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.customer_subscriptions IS 'domain:commerce | purpose:Customer subscription lifecycle and billing status tracking | access:critical | frequency:medium | status:workflow,processing';
COMMENT ON TABLE public.document_queue IS 'domain:content | purpose:Staging table for extracted documents awaiting LLM classification and quality assessment | access:protected | frequency:high | status:processing,priority';
COMMENT ON TABLE public.domain_assets IS 'domain:system | purpose:Media assets extracted from domain crawling | access:protected | frequency:low | status:processing,review';
COMMENT ON TABLE public.domain_blacklist IS 'domain:system | purpose:Security blacklist for blocked domains and content sources | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.domain_contacts IS 'domain:system | purpose:Extracted contact information from domain crawling | access:protected | frequency:medium | status:processing,review,moderation';
COMMENT ON TABLE public.domain_documents IS 'domain:system | purpose:Documents extracted from domain crawling for analysis | access:protected | frequency:medium | status:processing,review,indexing';
COMMENT ON TABLE public.domain_roots IS 'domain:system | purpose:Root domain discovery and crawling approval workflow | access:protected | frequency:low | status:processing,review';
COMMENT ON TABLE public.domain_urls IS 'domain:system | purpose:URL crawling queue with processing priority and status tracking | access:protected | frequency:high | status:processing,review,priority';
COMMENT ON TABLE public.feature_engagements IS 'domain:analytics | purpose:User feature usage analytics and engagement metrics | access:internal | frequency:high | status:null';
COMMENT ON TABLE public.feature_requests IS 'domain:user | purpose:User feature requests and product feedback with triage workflow | access:internal | frequency:medium | status:review,workflow,priority';
COMMENT ON TABLE public.features IS 'domain:system | purpose:Feature flags and toggles for deployment control and A/B testing | access:protected | frequency:medium | status:visibility,workflow';
COMMENT ON TABLE public.graph_edges IS 'domain:system | purpose:Knowledge graph relationships with AI confidence validation | access:internal | frequency:high | status:review,processing';
COMMENT ON TABLE public.graph_edges_authorship IS 'domain:system | purpose:Partitioned graph edges for authorship relationships | access:internal | frequency:medium | status:null';
COMMENT ON TABLE public.graph_edges_citation IS 'domain:system | purpose:Partitioned graph edges for citation relationships | access:internal | frequency:medium | status:null';
COMMENT ON TABLE public.graph_edges_experimental IS 'domain:system | purpose:Partitioned graph edges for experimental relationship types | access:internal | frequency:low | status:null';
COMMENT ON TABLE public.graph_edges_organizational IS 'domain:system | purpose:Partitioned graph edges for organizational relationships | access:internal | frequency:medium | status:null';
COMMENT ON TABLE public.graph_edges_semantic IS 'domain:system | purpose:Partitioned graph edges for semantic relationships | access:internal | frequency:high | status:null';
COMMENT ON TABLE public.news IS 'domain:content | purpose:News articles with real-time updates and content processing | access:public | frequency:high | status:visibility,processing,review,moderation,indexing';
COMMENT ON TABLE public.newsletters IS 'domain:content | purpose:Newsletter content generation and distribution | access:public | frequency:low | status:visibility,review,moderation';
COMMENT ON TABLE public.opportunities IS 'domain:directory | purpose:Job postings and career opportunities with approval workflow | access:public | frequency:medium | status:visibility,processing,review,moderation';
COMMENT ON TABLE public.organization_people IS 'domain:directory | purpose:Junction table linking organizations to people with roles | access:internal | frequency:medium | status:null';
COMMENT ON TABLE public.organizations IS 'domain:directory | purpose:Organization profiles for public directory | access:public | frequency:medium | status:visibility,review,moderation,processing';
COMMENT ON TABLE public.payment_providers IS 'domain:commerce | purpose:Configuration for payment gateway providers and credentials | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.people IS 'domain:directory | purpose:People profiles for academic and professional directory | access:public | frequency:medium | status:visibility,review,moderation';
COMMENT ON TABLE public.permission_configs IS 'domain:system | purpose:Security configuration for table permissions and RLS policies | access:critical | frequency:low | status:null';
COMMENT ON TABLE public.profile_links IS 'domain:user | purpose:External profile links with verification and spam prevention | access:internal | frequency:medium | status:review,moderation';
COMMENT ON TABLE public.queries IS 'domain:analytics | purpose:Search query registry for analytics and performance tracking | access:internal | frequency:high | status:null';
COMMENT ON TABLE public.research IS 'domain:content | purpose:Academic research papers and publications with peer review workflow | access:public | frequency:medium | status:visibility,processing,review,moderation,indexing';
COMMENT ON TABLE public.status_history IS 'domain:system | purpose:Immutable audit trail of all status transitions across tables | access:protected | frequency:high | status:null';
COMMENT ON TABLE public.statuses IS 'domain:system | purpose:Registry of all available status values and workflow definitions | access:protected | frequency:low | status:null';
COMMENT ON TABLE public.topic_comments IS 'domain:user | purpose:User discussions on topics with community moderation | access:internal | frequency:medium | status:review,moderation';
COMMENT ON TABLE public.topic_documents IS 'domain:content | purpose:AI-generated comprehensive topic documentation | access:internal | frequency:low | status:processing,review,moderation';
COMMENT ON TABLE public.topic_facts IS 'domain:content | purpose:Verified facts about topics with source attribution | access:internal | frequency:medium | status:review,moderation';
COMMENT ON TABLE public.topics IS 'domain:content | purpose:Knowledge graph topics for content categorization and discovery | access:public | frequency:high | status:visibility,processing,review,moderation,indexing';
COMMENT ON TABLE public.user_categories IS 'domain:user | purpose:Junction table for user category preferences and subscriptions | access:internal | frequency:medium | status:null';
COMMENT ON TABLE public.user_profiles IS 'domain:user | purpose:User account profiles and authentication data | access:critical | frequency:high | status:moderation';
COMMENT ON TABLE public.user_queries IS 'domain:analytics | purpose:User search behavior analytics and query frequency tracking | access:internal | frequency:high | status:null';
COMMENT ON TABLE public.user_topics IS 'domain:user | purpose:User topic subscriptions with abuse prevention monitoring | access:internal | frequency:medium | status:moderation';
COMMENT ON TABLE public.votes IS 'domain:user | purpose:User voting records on content with simple up/down tracking | access:internal | frequency:medium | status:null';

