create policy "tenant_admin_manage_addresses_addresses_all"
on "public"."addresses"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "admin_only_allowed_edge_types"
on "public"."allowed_edge_types"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum])));


create policy "default_public_user_astronomy_events_select"
on "public"."astronomy_events"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));

create policy "admin_manage_categories_categories_all"
on "public"."categories"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "auto_critical_service_role_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "auto_critical_super_admin_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "user_manage_own_contacts_contacts_all"
on "public"."contacts"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "tenant_admin_manage_sources_content_sources_all"
on "public"."content_sources"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "tenant_admin_view_crawl_stats_crawl_stats_select"
on "public"."crawl_stats"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "auto_critical_service_role_customer_payments_all"
on "public"."customer_payments"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "super_admin_view_payments_customer_payments_select"
on "public"."customer_payments"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "default_internal_admin_customer_processed_webhooks_all"
on "public"."customer_processed_webhooks"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "default_internal_user_customer_processed_webhooks_select"
on "public"."customer_processed_webhooks"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_critical_service_role_customer_refunds_all"
on "public"."customer_refunds"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "default_critical_super_admin_customer_refunds_all"
on "public"."customer_refunds"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "user_view_subscription_offers_customer_subscription_offers_sele"
on "public"."customer_subscription_offers"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "admin_manage_plans_customer_subscription_plans_all"
on "public"."customer_subscription_plans"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "auto_critical_service_role_customer_subscriptions_all"
on "public"."customer_subscriptions"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "super_admin_manage_subscriptions_customer_subscriptions_all"
on "public"."customer_subscriptions"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "default_internal_tenant_admin_domain_assets_all"
on "public"."domain_assets"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "default_internal_user_domain_assets_select"
on "public"."domain_assets"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_internal_admin_domain_blacklist_all"
on "public"."domain_blacklist"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "default_internal_user_domain_blacklist_select"
on "public"."domain_blacklist"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_internal_tenant_admin_domain_contacts_all"
on "public"."domain_contacts"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "default_internal_user_domain_contacts_select"
on "public"."domain_contacts"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_internal_tenant_admin_domain_documents_all"
on "public"."domain_documents"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "default_internal_user_domain_documents_select"
on "public"."domain_documents"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_internal_admin_domain_roots_all"
on "public"."domain_roots"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "default_internal_user_domain_roots_select"
on "public"."domain_roots"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "tenant_admin_manage_crawling_domain_urls_all"
on "public"."domain_urls"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "admin_manage_feature_requests_feature_requests_all"
on "public"."feature_requests"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "admin_manage_features_features_all"
on "public"."features"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "public_read_newsletters"
on "public"."newsletters"
as permissive
for select
to authenticated
using (((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text)));


create policy "user_read_newsletters_newsletters_select"
on "public"."newsletters"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "premium_read_opportunities_opportunities_select"
on "public"."opportunities"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (((auth.jwt() ->> 'plan'::text))::app_plan_enum = ANY (ARRAY['custom'::app_plan_enum, 'enterprise'::app_plan_enum, 'premium'::app_plan_enum])) AND ((is_active = true) AND (deleted_at IS NULL))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['tenant_super_admin'::app_role_enum, 'tenant_admin'::app_role_enum])) AND (organization_id = ((auth.jwt() ->> 'organization_id'::text))::uuid)) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "default_internal_user_organization_people_select"
on "public"."organization_people"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "admin_manage_organizations_organizations_all"
on "public"."organizations"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((is_directory_ready_computed = true) AND (is_approved_computed = true))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "user_view_payment_providers_payment_providers_select"
on "public"."payment_providers"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((is_directory_ready_computed = true) AND (is_approved_computed = true))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "admin_manage_permissions_permissions_config_all"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "service_role_permission_configs"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "super_admin_permission_configs"
on "public"."permission_configs"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "admin_manage_profile_links"
on "public"."profile_links"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum])));


create policy "user_manage_own_profile_links"
on "public"."profile_links"
as permissive
for all
to authenticated
using (((entity_id = auth.uid()) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum]))))
with check (((entity_id = auth.uid()) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['admin'::app_role_enum, 'super_admin'::app_role_enum]))));


create policy "user_read_profile_links"
on "public"."profile_links"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['user'::app_role_enum, 'astroguide'::app_role_enum, 'mentor'::app_role_enum, 'moderator'::app_role_enum, 'tenant_member'::app_role_enum, 'tenant_admin'::app_role_enum, 'tenant_super_admin'::app_role_enum, 'admin'::app_role_enum, 'super_admin'::app_role_enum])));


create policy "default_internal_admin_queries_all"
on "public"."queries"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "default_internal_user_queries_select"
on "public"."queries"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "premium_read_all_research_research_select"
on "public"."research"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (((auth.jwt() ->> 'plan'::text))::app_plan_enum = ANY (ARRAY['custom'::app_plan_enum, 'enterprise'::app_plan_enum, 'premium'::app_plan_enum])) AND ((is_active = true) AND (deleted_at IS NULL))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "super_admin_view_audit_trail_status_history_select"
on "public"."status_history"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "default_internal_admin_statuses_all"
on "public"."statuses"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "default_internal_user_statuses_select"
on "public"."statuses"
as permissive
for select
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])));


create policy "default_public_user_topic_documents_select"
on "public"."topic_documents"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "default_public_user_topic_facts_select"
on "public"."topic_facts"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (review_status = 'approved'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "admin_manage_topics_topics_all"
on "public"."topics"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


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
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND ((visibility_status = 'published'::text) AND (moderation_status = 'safe'::text))) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "user_manage_category_prefs_user_categories_all"
on "public"."user_categories"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "admin_manage_users_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum])));


create policy "auto_critical_service_role_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'service_role'::app_role_enum));


create policy "auto_critical_super_admin_user_profiles_all"
on "public"."user_profiles"
as permissive
for all
to authenticated
using ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum))
with check ((((auth.jwt() ->> 'user_role'::text))::app_role_enum = 'super_admin'::app_role_enum));


create policy "user_read_own_profile_user_profiles_select"
on "public"."user_profiles"
as permissive
for select
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "user_update_own_profile_user_profiles_update"
on "public"."user_profiles"
as permissive
for update
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "user_manage_queries_query_user_all"
on "public"."user_queries"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


create policy "user_manage_topic_subscriptions_user_topics_all"
on "public"."user_topics"
as permissive
for all
to authenticated
using ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))))
with check ((((((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['astroguide'::app_role_enum, 'mentor'::app_role_enum, 'user'::app_role_enum])) AND (user_id = auth.uid())) OR (((auth.jwt() ->> 'user_role'::text))::app_role_enum = ANY (ARRAY['super_admin'::app_role_enum, 'admin'::app_role_enum]))));


