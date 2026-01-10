-- Domain contacts complete migration
alter table "public"."domain_contacts" 
    add column if not exists "created_at" timestamp without time zone not null default now(),
    add column if not exists "updated_at" timestamp without time zone not null default now(),
    alter column "domain_root_id" set not null,
    alter column "organization_id" set not null,
    drop column if exists "is_approved",
    drop column if exists "is_high_confidence",
    drop column if exists "is_processing",
    drop column if exists "is_verified_contact",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_high_confidence_computed" boolean generated always as (
        (confidence >= 0.8)
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_verified_contact_computed" boolean generated always as (
        ((processing_status = 'completed'::text) and 
         (review_status = 'approved'::text) and 
         (moderation_status = 'safe'::text) and 
         (confidence >= 0.7))
    ) stored;


-- Domain urls complete migration
alter table "public"."domain_urls" 
    alter column "domain_root_id" set not null,
    drop column if exists "has_errors",
    drop column if exists "is_approved",
    drop column if exists "is_high_priority",
    drop column if exists "is_low_priority",
    drop column if exists "is_processing",
    drop column if exists "is_ready_to_process",
    add column "has_errors_computed" boolean generated always as (
        (error_count > 0)
    ) stored,
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_high_priority_computed" boolean generated always as (
        (priority_status = any(array['high'::text, 'critical'::text]))
    ) stored,
    add column "is_low_priority_computed" boolean generated always as (
        (priority_status = any(array['very_low'::text, 'low'::text]))
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_ready_to_process_computed" boolean generated always as (
        ((processing_status = 'queued'::text) and (error_count < 3))
    ) stored;



alter table "public"."domain_roots" 
    add column if not exists "created_at" timestamp without time zone not null default now(),
    add column if not exists "updated_at" timestamp without time zone not null default now();




set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_sites_to_crawl(fetch_limit integer)
 RETURNS SETOF public.organizations
 LANGUAGE sql
AS $function$
  SELECT *
  FROM public.organizations o
  WHERE
    o.url IS NOT NULL
    AND o.url != ''
    AND o.visibility_status = 'published'
    AND o.review_status = 'approved'
    AND public.should_rescrape(o.scrape_frequency, o.scraped_at)
  ORDER BY COALESCE(o.scraped_at, '1970-01-01'::timestamp) ASC
  LIMIT fetch_limit
$function$
;