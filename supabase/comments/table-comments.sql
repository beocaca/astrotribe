-- ============================================================================
-- TABLE COMMENTS
-- Generated: 2025-06-26T08:27:19.745Z
-- Purpose: Single source of truth for table comments
-- ============================================================================

COMMENT ON TABLE public.addresses IS 'domain:auth | purpose:User and organization address management for business operations | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.allowed_edge_types IS 'domain:graph | purpose:edge type validation | access:internal | frequency:low';
COMMENT ON TABLE public.astronomy_events IS 'domain:content | purpose:Astronomical events and celestial calendar management | access:public | frequency:low-read,low-write';
COMMENT ON TABLE public.categories IS 'domain:taxonomy | purpose:Hierarchical content categories and classification system | access:public | frequency:medium-read,low-write';
COMMENT ON TABLE public.contacts IS 'domain:auth | purpose:User contact information and communication preferences | access:critical | frequency:medium-read,low-write';
COMMENT ON TABLE public.content_sources IS 'domain:content | purpose:Content source definitions and scraping configuration | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.crawl_stats IS 'domain:crawling | purpose:Web crawling performance metrics and statistics | access:internal | frequency:low-read,medium-write';
COMMENT ON TABLE public.customer_payments IS 'domain:payments | purpose:Payment transaction records and financial processing | access:critical | frequency:medium-read,medium-write';
COMMENT ON TABLE public.customer_processed_webhooks IS 'domain:payments | purpose:Payment webhook processing and deduplication tracking | access:internal | frequency:low-read,high-write';
COMMENT ON TABLE public.customer_refunds IS 'domain:payments | purpose:Refund processing and financial transaction reversals | access:critical | frequency:low-read,low-write';
COMMENT ON TABLE public.customer_subscription_offers IS 'domain:payments | purpose:Special offers and discount management for subscriptions | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.customer_subscription_plans IS 'domain:payments | purpose:Subscription plan definitions and pricing structure | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.customer_subscriptions IS 'domain:payments | purpose:User subscription lifecycle and billing management | access:critical | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_assets IS 'domain:crawling | purpose:Digital asset discovery and classification from domains | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_blacklist IS 'domain:crawling | purpose:Blocked domain management for crawling operations | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.domain_contacts IS 'domain:crawling | purpose:Contact information extraction from web domains | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_documents IS 'domain:crawling | purpose:Document discovery and indexing from web sources | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_roots IS 'domain:crawling | purpose:Domain root tracking for web crawling operations | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_urls IS 'domain:crawling | purpose:URL inventory and crawling status management | access:internal | frequency:high-read,high-write';
COMMENT ON TABLE public.feature_requests IS 'domain:feature-management | purpose:User feature requests and product feedback collection | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.features IS 'domain:feature-management | purpose:Product feature definitions and development tracking | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.graph_edges IS 'domain:graph | purpose:knowledge graph relationships | access:internal | frequency:high';
COMMENT ON TABLE public.news IS 'domain:content | purpose:News article content and metadata management | access:public | frequency:high-read,medium-write';
COMMENT ON TABLE public.newsletters IS 'domain:content | purpose:Newsletter generation and content curation management | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.opportunities IS 'domain:content | purpose:Job and career opportunity listings management | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.organization_people IS 'domain:org | purpose:Organization-people relationship and affiliation mapping | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.organizations IS 'domain:org | purpose:External organizations, companies, and institutional entities | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.payment_providers IS 'domain:payments | purpose:Payment provider configuration and integration management | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.people IS 'domain:org | purpose:People profiles and professional information directory | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.profile_links IS 'domain:people,organizations | purpose:social media and web presence links | access:internal | frequency:medium';
COMMENT ON TABLE public.queries IS 'domain:search,engagement | purpose:User search queries and behavior analytics | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.research IS 'domain:content | purpose:Academic research papers and scientific content management | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.status_history IS 'domain:workflow | purpose:Audit trail for status changes and workflow transitions | access:internal | frequency:low-read,high-write';
COMMENT ON TABLE public.statuses IS 'domain:workflow | purpose:Status definitions and state transition rules for workflows | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.topic_documents IS 'domain:content,taxonomy | purpose:Generated topic documentation and knowledge synthesis | access:public | frequency:medium-read,low-write';
COMMENT ON TABLE public.topic_facts IS 'domain:content,taxonomy | purpose:Verified facts and claims associated with topics | access:public | frequency:medium-read,low-write';
COMMENT ON TABLE public.topics IS 'domain:taxonomy | purpose:Knowledge graph nodes for content categorization and discovery | access:public | frequency:high-read,medium-write';
COMMENT ON TABLE public.user_categories IS 'domain:taxonomy,engagement | purpose:User category preferences and interest mapping | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.user_profiles IS 'domain:auth | purpose:Core user identity, authentication, and profile management | access:critical | frequency:high-read,medium-write';
COMMENT ON TABLE public.user_topics IS 'domain:taxonomy,engagement | purpose:User topic subscriptions and learning progress tracking | access:internal | frequency:medium-read,medium-write';

