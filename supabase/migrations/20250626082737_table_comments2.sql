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
COMMENT ON TABLE public.domain_contacts IS 'domain:crawling | purpose:Contact information extraction from web domains | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_roots IS 'domain:crawling | purpose:Domain root tracking for web crawling operations | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.domain_urls IS 'domain:crawling | purpose:URL inventory and crawling status management | access:internal | frequency:high-read,high-write';
COMMENT ON TABLE public.feature_requests IS 'domain:feature-management | purpose:User feature requests and product feedback collection | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.features IS 'domain:feature-management | purpose:Product feature definitions and development tracking | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.graph_edges IS 'domain:graph | purpose:knowledge graph relationships | access:internal | frequency:high';
COMMENT ON TABLE public.news IS 'domain:content | purpose:News article content and metadata management | access:public | frequency:high-read,medium-write';
COMMENT ON TABLE public.opportunities IS 'domain:content | purpose:Job and career opportunity listings management | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.organization_people IS 'domain:org | purpose:Organization-people relationship and affiliation mapping | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.organizations IS 'domain:org | purpose:External organizations, companies, and institutional entities | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.payment_providers IS 'domain:payments | purpose:Payment provider configuration and integration management | access:internal | frequency:low-read,low-write';
COMMENT ON TABLE public.people IS 'domain:org | purpose:People profiles and professional information directory | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.profile_links IS 'domain:people,organizations | purpose:social media and web presence links | access:internal | frequency:medium';
COMMENT ON TABLE public.research IS 'domain:content | purpose:Academic research papers and scientific content management | access:public | frequency:medium-read,medium-write';
COMMENT ON TABLE public.status_history IS 'domain:workflow | purpose:Audit trail for status changes and workflow transitions | access:internal | frequency:low-read,high-write';
COMMENT ON TABLE public.statuses IS 'domain:workflow | purpose:Status definitions and state transition rules for workflows | access:internal | frequency:medium-read,low-write';
COMMENT ON TABLE public.topics IS 'domain:taxonomy | purpose:Knowledge graph nodes for content categorization and discovery | access:public | frequency:high-read,medium-write';
COMMENT ON TABLE public.user_categories IS 'domain:taxonomy,engagement | purpose:User category preferences and interest mapping | access:internal | frequency:medium-read,medium-write';
COMMENT ON TABLE public.user_profiles IS 'domain:auth | purpose:Core user identity, authentication, and profile management | access:critical | frequency:high-read,medium-write';
COMMENT ON TABLE public.user_topics IS 'domain:taxonomy,engagement | purpose:User topic subscriptions and learning progress tracking | access:internal | frequency:medium-read,medium-write';


-- =============================================================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on all tables
alter table "public"."addresses" enable row level security;
alter table "public"."astronomy_events" enable row level security;
alter table "public"."categories" enable row level security;
alter table "public"."contacts" enable row level security;
alter table "public"."content_sources" enable row level security;
alter table "public"."crawl_stats" enable row level security;
alter table "public"."customer_payments" enable row level security;
alter table "public"."customer_processed_webhooks" enable row level security;
alter table "public"."customer_refunds" enable row level security;
alter table "public"."customer_subscription_offers" enable row level security;
alter table "public"."customer_subscription_plans" enable row level security;
alter table "public"."customer_subscriptions" enable row level security;
alter table "public"."domain_assets" enable row level security;
alter table "public"."domain_contacts" enable row level security;
alter table "public"."domain_roots" enable row level security;
alter table "public"."domain_urls" enable row level security;
alter table "public"."feature_requests" enable row level security;
alter table "public"."features" enable row level security;
alter table "public"."news" enable row level security;
alter table "public"."opportunities" enable row level security;
alter table "public"."organization_people" enable row level security;
alter table "public"."organizations" enable row level security;
alter table "public"."payment_providers" enable row level security;
alter table "public"."people" enable row level security;
alter table "public"."permission_configs" enable row level security;
alter table "public"."research" enable row level security;
alter table "public"."status_history" enable row level security;
alter table "public"."statuses" enable row level security;
alter table "public"."topics" enable row level security;
alter table "public"."user_categories" enable row level security;
alter table "public"."user_profiles" enable row level security;
alter table "public"."user_topics" enable row level security;
ALTER TABLE public.allowed_edge_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.graph_edges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_links ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================


create policy "tenant_admin_manage_addresses_addresses_all"
on "public"."addresses"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "admin_only_allowed_edge_types"
on "public"."allowed_edge_types"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])));


create policy "default_public_user_astronomy_events_select"
on "public"."astronomy_events"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));

create policy "admin_manage_categories_categories_all"
on "public"."categories"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "public_read_categories"
on "public"."categories"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_categories_categories_select"
on "public"."categories"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((visibility_status = 'published'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "auto_critical_service_role_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "auto_critical_super_admin_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "user_manage_own_contacts_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "tenant_admin_manage_sources_content_sources_all"
on "public"."content_sources"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "tenant_admin_view_crawl_stats_crawl_stats_select"
on "public"."crawl_stats"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "auto_critical_service_role_customer_payments_all"
on "public"."customer_payments"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "super_admin_view_payments_customer_payments_select"
on "public"."customer_payments"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "default_internal_admin_customer_processed_webhooks_all"
on "public"."customer_processed_webhooks"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "default_internal_user_customer_processed_webhooks_select"
on "public"."customer_processed_webhooks"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "default_critical_service_role_customer_refunds_all"
on "public"."customer_refunds"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "default_critical_super_admin_customer_refunds_all"
on "public"."customer_refunds"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "user_view_subscription_offers_customer_subscription_offers_sele"
on "public"."customer_subscription_offers"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "admin_manage_plans_customer_subscription_plans_all"
on "public"."customer_subscription_plans"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "auto_critical_service_role_customer_subscriptions_all"
on "public"."customer_subscriptions"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "super_admin_manage_subscriptions_customer_subscriptions_all"
on "public"."customer_subscriptions"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "default_internal_tenant_admin_domain_assets_all"
on "public"."domain_assets"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "default_internal_user_domain_assets_select"
on "public"."domain_assets"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "default_internal_tenant_admin_domain_contacts_all"
on "public"."domain_contacts"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "default_internal_user_domain_contacts_select"
on "public"."domain_contacts"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "default_internal_admin_domain_roots_all"
on "public"."domain_roots"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "default_internal_user_domain_roots_select"
on "public"."domain_roots"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "tenant_admin_manage_crawling_domain_urls_all"
on "public"."domain_urls"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "admin_manage_feature_requests_feature_requests_all"
on "public"."feature_requests"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "admin_manage_features_features_all"
on "public"."features"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "public_read_news"
on "public"."news"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_published_news_news_select"
on "public"."news"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "premium_read_opportunities_opportunities_select"
on "public"."opportunities"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (((auth.jwt() ->> 'plan'::text))::public.app_plan_enum = ANY (ARRAY['custom'::public.app_plan_enum, 'enterprise'::public.app_plan_enum, 'premium'::public.app_plan_enum])) AND ((is_active = true) AND (deleted_at IS NULL))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "public_read_opportunities"
on "public"."opportunities"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "default_internal_tenant_admin_organization_people_all"
on "public"."organization_people"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['tenant_super_admin'::public.app_role_enum, 'tenant_admin'::public.app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "default_internal_user_organization_people_select"
on "public"."organization_people"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "admin_manage_organizations_organizations_all"
on "public"."organizations"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "public_read_organizations"
on "public"."organizations"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_directory_organizations_select"
on "public"."organizations"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((is_directory_ready_computed = true) AND (is_approved_computed = true))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "user_view_payment_providers_payment_providers_select"
on "public"."payment_providers"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "public_read_people"
on "public"."people"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_people_directory_people_select"
on "public"."people"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((is_directory_ready_computed = true) AND (is_approved_computed = true))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "admin_manage_permissions_permissions_config_all"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "service_role_permission_configs"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "super_admin_permission_configs"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "admin_manage_profile_links"
on "public"."profile_links"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])));


create policy "user_manage_own_profile_links"
on "public"."profile_links"
as permissive
for all
to authenticated
using (((entity_id = auth.uid()) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum]))))
with check (((entity_id = auth.uid()) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['admin'::public.app_role_enum, 'super_admin'::public.app_role_enum]))));


create policy "user_read_profile_links"
on "public"."profile_links"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['user'::public.app_role_enum, 'astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'moderator'::public.app_role_enum, 'tenant_member'::public.app_role_enum, 'tenant_admin'::public.app_role_enum, 'tenant_super_admin'::public.app_role_enum, 'admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])));


create policy "premium_read_all_research_research_select"
on "public"."research"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (((auth.jwt() ->> 'plan'::text))::public.app_plan_enum = ANY (ARRAY['custom'::public.app_plan_enum, 'enterprise'::public.app_plan_enum, 'premium'::public.app_plan_enum])) AND ((is_active = true) AND (deleted_at IS NULL))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "public_read_research"
on "public"."research"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_published_research_research_select"
on "public"."research"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "super_admin_view_audit_trail_status_history_select"
on "public"."status_history"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "default_internal_admin_statuses_all"
on "public"."statuses"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "default_internal_user_statuses_select"
on "public"."statuses"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])));


create policy "admin_manage_topics_topics_all"
on "public"."topics"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "public_read_topics"
on "public"."topics"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_topics_topics_select"
on "public"."topics"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND ((visibility_status = 'published'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "user_manage_category_prefs_user_categories_all"
on "public"."user_categories"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "admin_manage_users_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum])));


create policy "auto_critical_service_role_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'service_role'::public.app_role_enum));


create policy "auto_critical_super_admin_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = 'super_admin'::public.app_role_enum));


create policy "user_read_own_profile_user_profiles_select"
on "public"."user_profiles"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


create policy "user_update_own_profile_user_profiles_update"
on "public"."user_profiles"
as permissive
for update
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));

create policy "user_manage_topic_subscriptions_user_topics_all"
on "public"."user_topics"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['astroguide'::public.app_role_enum, 'mentor'::public.app_role_enum, 'user'::public.app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::public.app_role_enum = ANY (ARRAY['super_admin'::public.app_role_enum, 'admin'::public.app_role_enum]))));


