-- ============================================================================
-- MIGRATION: graph_cleanup
-- Generated: 2025-06-26
-- Purpose: Major schema refactoring - graph cleanup and computed columns
-- ============================================================================


-- =============================================================================
-- SECTION 3: DROP LEGACY CONSTRAINTS
-- =============================================================================

-- Drop foreign key constraints
alter table "public"."news" drop constraint if exists "news_content_id_fkey";
alter table "public"."opportunities" drop constraint if exists "opportunities_content_id_fkey";
alter table "public"."research" drop constraint if exists "research_content_id_fkey";

-- =============================================================================
-- SECTION 5: SCHEMA UPDATES - ADD BIGINT IDS AND COMPUTED COLUMNS
-- =============================================================================

-- Core content tables - add bigint_id using BIGSERIAL
alter table "public"."astronomy_events" 
    add column "bigint_id" bigserial not null,
    add column "is_indexed" boolean default false,
    add column "organization_id" uuid,
    add column "person_id" uuid,
    add column "processing_status" text default 'queued',
    add column "url" text,
    drop column if exists "is_public",
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."categories" 
    add column "bigint_id" bigserial not null,
    add column "domain" text not null,
    drop column if exists "is_approved",
    drop column if exists "is_flagged", 
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_flagged_computed" boolean generated always as (
        (moderation_status = any(array['flagged'::text, 'suspended'::text, 'banned'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."news" 
    add column "bigint_id" bigserial not null,
    add column "is_indexed" boolean default false,
    add column "organization_id" uuid,
    add column "person_id" uuid,
    drop column if exists "content_id",
    drop column if exists "graph_migrated_at",
    drop column if exists "is_approved",
    drop column if exists "is_processing",
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."opportunities" 
    add column "bigint_id" bigserial not null,
    add column "is_indexed" boolean default false,
    add column "organization_id" uuid,
    add column "person_id" uuid,
    drop column if exists "content_id",
    drop column if exists "is_active_opportunity",
    drop column if exists "is_approved",
    drop column if exists "is_processing",
    drop column if exists "is_public",
    add column "is_active_opportunity_computed" boolean generated always as (
        ((visibility_status = 'published'::text) and 
         (review_status = 'approved'::text) and 
         (moderation_status = 'safe'::text))
    ) stored,
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."organizations" 
    add column "bigint_id" bigserial not null,
    add column "processing_status" varchar(50) default 'queued',
    drop column if exists "is_approved",
    drop column if exists "is_directory_ready",
    drop column if exists "is_flagged",
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_directory_ready_computed" boolean generated always as (
        ((visibility_status = 'published'::text) and 
         (review_status = 'approved'::text) and 
         (moderation_status = 'safe'::text) and 
         (url is not null))
    ) stored,
    add column "is_flagged_computed" boolean generated always as (
        (moderation_status = any(array['flagged'::text, 'suspended'::text, 'banned'::text]))
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        ((processing_status)::text = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."people" 
    add column "bigint_id" bigserial not null,
    drop column if exists "is_approved",
    drop column if exists "is_directory_ready",
    drop column if exists "is_flagged",
    drop column if exists "is_public",
    drop column if exists "user_id",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_directory_ready_computed" boolean generated always as (
        ((visibility_status = 'published'::text) and 
         (review_status = 'approved'::text) and 
         (moderation_status = 'safe'::text) and 
         (name is not null))
    ) stored,
    add column "is_flagged_computed" boolean generated always as (
        (moderation_status = any(array['flagged'::text, 'suspended'::text, 'banned'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."research" 
    add column "bigint_id" bigserial not null,
    add column "is_indexed" boolean default false,
    add column "person_id" uuid,
    drop column if exists "content_id",
    drop column if exists "graph_migrated_at",
    drop column if exists "is_approved",
    drop column if exists "is_processing",
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;

alter table "public"."topics" 
    add column "bigint_id" bigserial not null,
    drop column if exists "is_approved",
    drop column if exists "is_flagged",
    drop column if exists "is_indexed",
    drop column if exists "is_processing",
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_flagged_computed" boolean generated always as (
        (moderation_status = any(array['flagged'::text, 'suspended'::text, 'banned'::text]))
    ) stored,
    add column "is_indexed_computed" boolean generated always as (
        (indexing_status = 'indexed'::text)
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;


-- =============================================================================
-- SECTION 6: DOMAIN TABLES - COMPUTED COLUMNS AND OPTIMIZATIONS
-- =============================================================================

-- Content sources optimizations
alter table "public"."content_sources" 
    add column "review_status" text default 'pending_review',
    add column "priority_status" text not null,
    add column "last_extracted_urls" jsonb default '[]'::jsonb,
    alter column "organization_id" set not null,
    drop column if exists "has_failures",
    drop column if exists "is_processing",
    drop column if exists "is_source_healthy",
    drop column if exists "is_workflow_active",
    drop column if exists "priority",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_healthy_computed" boolean generated always as (
        ((processing_status = 'completed'::text) and 
         (workflow_status = 'completed'::text) and 
         (review_status = 'approved'::text) and 
         ((failed_count is null) or (failed_count < 3)))
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored,
    add column "is_workflow_active_computed" boolean generated always as (
        (workflow_status = any(array['scheduled'::text, 'queued'::text, 'running'::text]))
    ) stored;

-- Domain tables computed columns
alter table "public"."domain_assets" 
    add column "created_at" timestamp without time zone not null default now(),
    add column "updated_at" timestamp without time zone not null default now(),
    alter column "domain_root_id" set not null,
    alter column "organization_id" set not null,
    drop column if exists "is_approved",
    drop column if exists "is_available",
    drop column if exists "is_processing",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_available_computed" boolean generated always as (
        ((processing_status = 'completed'::text) and 
         (review_status = 'approved'::text) and 
         (asset_url is not null))
    ) stored,
    add column "is_processing_computed" boolean generated always as (
        (processing_status = any(array['queued'::text, 'processing'::text, 'retrying'::text]))
    ) stored;


-- =============================================================================
-- SECTION 7: USER AND SYSTEM TABLES - COMPUTED COLUMNS
-- =============================================================================

-- User profiles computed columns
alter table "public"."user_profiles" 
    drop column if exists "can_interact",
    drop column if exists "is_banned",
    drop column if exists "is_flagged",
    drop column if exists "is_suspended",
    add column "can_interact_computed" boolean generated always as (
        ((moderation_status = any(array['safe'::text, 'flagged'::text])) and (is_active = true))
    ) stored,
    add column "is_banned_computed" boolean generated always as (
        (moderation_status = 'banned'::text)
    ) stored,
    add column "is_flagged_computed" boolean generated always as (
        (moderation_status = any(array['flagged'::text, 'suspended'::text, 'banned'::text]))
    ) stored,
    add column "is_suspended_computed" boolean generated always as (
        (moderation_status = 'suspended'::text)
    ) stored;

-- Graph edges optimization - rename UUID columns, add BIGINT as primary IDs
alter table "public"."graph_edges" 
    drop column if exists "phase1_int_source",
    drop column if exists "phase1_int_target";

-- Rename existing UUID columns to preserve data (separate statements required)
alter table "public"."graph_edges" 
    rename column "source_id" to "source_uuid_id";

alter table "public"."graph_edges" 
    rename column "target_id" to "target_uuid_id";

-- Add new BIGINT columns and modify constraints
alter table "public"."graph_edges"
    add column "source_id" bigint,
    add column "target_id" bigint,
    alter column "source_uuid_id" drop not null,
    alter column "target_uuid_id" drop not null;



-- =============================================================================
-- SECTION 8: CREATE OPTIMIZED INDEXES
-- =============================================================================

-- Primary key constraints (only add if not exists)
alter table "public"."topic_clusters" add constraint "topic_clusters_pkey" primary key ("topic_id");

-- Check if permission_configs already has a primary key, if not add it
do $$
begin
    if not exists (
        select 1 from information_schema.table_constraints 
        where table_name = 'permission_configs' 
        and constraint_type = 'PRIMARY KEY'
        and table_schema = 'public'
    ) then
        alter table "public"."permission_configs" add constraint "permissions_config_pkey" primary key ("id");
    end if;
end $$;

-- Unique constraints for bigint_id columns
alter table "public"."astronomy_events" add constraint "idx_uniq_astronomy_events_bigint_id" unique ("bigint_id");
alter table "public"."categories" add constraint "idx_uniq_categories_bigint_id" unique ("bigint_id");
alter table "public"."news" add constraint "idx_uniq_news_bigint_id" unique ("bigint_id");
alter table "public"."opportunities" add constraint "idx_uniq_opportunities_bigint_id" unique ("bigint_id");
alter table "public"."organizations" add constraint "idx_uniq_organizations_bigint_id" unique ("bigint_id");
alter table "public"."people" add constraint "idx_uniq_people_bigint_id" unique ("bigint_id");
alter table "public"."research" add constraint "idx_uniq_research_bigint_id" unique ("bigint_id");
alter table "public"."topics" add constraint "idx_uniq_topics_bigint_id" unique ("bigint_id");
alter table "public"."topic_clusters" add constraint "idx_uniq_topic_clusters_topic_bigint_id" unique ("topic_bigint_id");

-- Performance indexes for content discovery
create index "idx_content_discovery_news" on "public"."news" using btree (
    "is_public_computed", "is_approved_computed", "moderation_status"
) where (
    ("is_public_computed" = true) and 
    ("is_approved_computed" = true) and 
    ("moderation_status" = 'safe'::text)
);

create index "idx_content_discovery_research" on "public"."research" using btree (
    "is_public_computed", "is_approved_computed", "moderation_status"
) where (
    ("is_public_computed" = true) and 
    ("is_approved_computed" = true) and 
    ("moderation_status" = 'safe'::text)
);

create index "idx_content_discovery_topics" on "public"."topics" using btree (
    "is_public_computed", "is_approved_computed", "moderation_status"
) where (
    ("is_public_computed" = true) and 
    ("is_approved_computed" = true) and 
    ("moderation_status" = 'safe'::text)
);

-- Directory indexes
create index "idx_directory_organizations" on "public"."organizations" using btree (
    "is_directory_ready_computed", "is_flagged_computed"
) where (
    ("is_directory_ready_computed" = true) and 
    ("is_flagged_computed" = false)
);

create index "idx_directory_people" on "public"."people" using btree (
    "is_directory_ready_computed", "is_flagged_computed"
) where (
    ("is_directory_ready_computed" = true) and 
    ("is_flagged_computed" = false)
);

-- Topic cluster performance indexes
create index "idx_topic_clusters_lookup" on "public"."topic_clusters" using btree ("topic_bigint_id");
create index "idx_topic_clusters_entities" on "public"."topic_clusters" using gin (
    "people_bigint_ids", "research_bigint_ids", "news_bigint_ids", "organization_bigint_ids"
);

-- Graph edge performance indexes
create index if not exists "idx_graph_edges_pgr_native" on only "public"."graph_edges" using btree (
    "source_id", "target_id", "edge_type"
);
create index if not exists "idx_graph_edges_source" on only "public"."graph_edges" using btree (
    "source_id", "source_type"
);
create index if not exists "idx_graph_edges_target" on only "public"."graph_edges" using btree (
    "target_id", "target_type"
);

-- UUID to bigint mapping indexes for performance
create index "idx_astronomy_events_uuid_bigint" on "public"."astronomy_events" using btree ("id", "bigint_id");
create index "idx_categories_uuid_bigint" on "public"."categories" using btree ("id", "bigint_id");
create index "idx_news_uuid_bigint" on "public"."news" using btree ("id", "bigint_id");
create index "idx_opportunities_uuid_bigint" on "public"."opportunities" using btree ("id", "bigint_id");
create index "idx_organizations_uuid_bigint" on "public"."organizations" using btree ("id", "bigint_id");
create index "idx_people_uuid_bigint" on "public"."people" using btree ("id", "bigint_id");
create index "idx_research_uuid_bigint" on "public"."research" using btree ("id", "bigint_id");
create index "idx_topics_uuid_bigint" on "public"."topics" using btree ("id", "bigint_id");

-- Payment history queries (user + status + chronological)
CREATE INDEX idx_customer_payments_user_status_date 
ON "public"."customer_payments" 
USING btree (user_id, status, created_at DESC);


-- =============================================================================
-- SECTION 9: FOREIGN KEY CONSTRAINTS AND VALIDATION
-- =============================================================================

-- Content table relationships
alter table "public"."astronomy_events" 
    drop constraint if exists "astronomy_events_organization_id_fkey";
alter table "public"."astronomy_events" 
    add constraint "fk_astronomy_events_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") not valid;
alter table "public"."astronomy_events" validate constraint "fk_astronomy_events_organization_id";

alter table "public"."astronomy_events" 
    drop constraint if exists "astronomy_events_person_id_fkey";
alter table "public"."astronomy_events" 
    add constraint "fk_astronomy_events_person_id" 
    foreign key ("person_id") references "public"."people"("id") not valid;
alter table "public"."astronomy_events" validate constraint "fk_astronomy_events_person_id";

alter table "public"."news" 
    drop constraint if exists "news_organization_id_fkey";
alter table "public"."news" 
    add constraint "fk_news_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") not valid;
alter table "public"."news" validate constraint "fk_news_organization_id";

alter table "public"."news" 
    drop constraint if exists "news_person_id_fkey";
alter table "public"."news" 
    add constraint "fk_news_person_id" 
    foreign key ("person_id") references "public"."people"("id") not valid;
alter table "public"."news" validate constraint "fk_news_person_id";

alter table "public"."opportunities" 
    drop constraint if exists "opportunities_organization_id_fkey";
alter table "public"."opportunities" 
    add constraint "fk_opportunities_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") not valid;
alter table "public"."opportunities" validate constraint "fk_opportunities_organization_id";

alter table "public"."opportunities" 
    drop constraint if exists "opportunities_person_id_fkey";
alter table "public"."opportunities" 
    add constraint "fk_opportunities_person_id" 
    foreign key ("person_id") references "public"."people"("id") not valid;
alter table "public"."opportunities" validate constraint "fk_opportunities_person_id";

alter table "public"."research" 
    drop constraint if exists "research_person_id_fkey";
alter table "public"."research" 
    add constraint "fk_research_person_id" 
    foreign key ("person_id") references "public"."people"("id") not valid;
alter table "public"."research" validate constraint "fk_research_person_id";

-- Topic cluster relationships
alter table "public"."topic_clusters" 
    drop constraint if exists "topic_clusters_topic_id_fkey";
alter table "public"."topic_clusters" 
    add constraint "fk_topic_clusters_topic_id" 
    foreign key ("topic_id") references "public"."topics"("id") not valid;
alter table "public"."topic_clusters" validate constraint "fk_topic_clusters_topic_id";

-- Domain table cascade relationships
alter table "public"."content_sources" 
    drop constraint if exists "content_sources_organization_id_fkey";
alter table "public"."content_sources" 
    add constraint "fk_content_sources_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") 
    on update cascade on delete cascade not valid;
alter table "public"."content_sources" validate constraint "fk_content_sources_organization_id";

alter table "public"."crawl_stats" 
    drop constraint if exists "crawl_stats_organization_id_fkey";
alter table "public"."crawl_stats" 
    add constraint "fk_crawl_stats_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") 
    on update cascade on delete cascade not valid;
alter table "public"."crawl_stats" validate constraint "fk_crawl_stats_organization_id";

alter table "public"."domain_assets" 
    drop constraint if exists "domain_assets_organization_id_fkey";
alter table "public"."domain_assets" 
    add constraint "fk_domain_assets_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") 
    on update cascade on delete cascade not valid;
alter table "public"."domain_assets" validate constraint "fk_domain_assets_organization_id";

alter table "public"."domain_contacts" 
    drop constraint if exists "domain_contacts_organization_id_fkey";
alter table "public"."domain_contacts" 
    add constraint "fk_domain_contacts_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") 
    on update cascade on delete cascade not valid;
alter table "public"."domain_contacts" validate constraint "fk_domain_contacts_organization_id";

alter table "public"."domain_urls" 
    drop constraint if exists "domain_urls_organization_id_fkey";
alter table "public"."domain_urls" 
    add constraint "fk_domain_urls_organization_id" 
    foreign key ("organization_id") references "public"."organizations"("id") 
    on update cascade on delete set null not valid;
alter table "public"."domain_urls" validate constraint "fk_domain_urls_organization_id";


-- =============================================================================
-- SECTION 10: CHECK CONSTRAINTS AND VALIDATION
-- =============================================================================

-- Categories domain validation
alter table "public"."categories" 
    add constraint "chk_categories_domain" 
    check (("domain" = any (array['astronomy'::text, 'space_tech'::text]))) not valid;
alter table "public"."categories" validate constraint "chk_categories_domain";

-- Content sources validation
alter table "public"."content_sources" 
    drop constraint if exists "chk_priority_status";
alter table "public"."content_sources" 
    add constraint "chk_content_sources_priority_status" 
    check (("priority_status" = any (array[
        'very_low'::text, 'low'::text, 'medium'::text, 'high'::text, 'critical'::text
    ]))) not valid;
alter table "public"."content_sources" validate constraint "chk_content_sources_priority_status";

alter table "public"."content_sources" 
    drop constraint if exists "chk_processing_status";
alter table "public"."content_sources" 
    add constraint "chk_content_sources_processing_status" 
    check (("processing_status" = any (array[
        'queued'::text, 'processing'::text, 'completed'::text, 
        'errored'::text, 'retrying'::text, 'timed_out'::text, 'skipped'::text
    ]))) not valid;
alter table "public"."content_sources" validate constraint "chk_content_sources_processing_status";

alter table "public"."content_sources" 
    drop constraint if exists "chk_review_status";
alter table "public"."content_sources" 
    add constraint "chk_content_sources_review_status" 
    check (("review_status" = any (array[
        'pending_review'::text, 'under_review'::text, 'approved'::text, 
        'rejected'::text, 'needs_changes'::text, 'deferred'::text
    ]))) not valid;
alter table "public"."content_sources" validate constraint "chk_content_sources_review_status";

alter table "public"."content_sources" 
    drop constraint if exists "chk_workflow_status";
alter table "public"."content_sources" 
    add constraint "chk_content_sources_workflow_status" 
    check (("workflow_status" = any (array[
        'scheduled'::text, 'queued'::text, 'running'::text, 
        'completed'::text, 'errored'::text, 'paused'::text, 'cancelled'::text
    ]))) not valid;
alter table "public"."content_sources" validate constraint "chk_content_sources_workflow_status";



-- =============================================================================
-- SECTION 12: ADDITIONAL MISSING COLUMNS AND TIMESTAMPS
-- =============================================================================

-- Add missing timestamps and system columns

alter table "public"."customer_payments" 
    add column if not exists "updated_at" timestamp without time zone not null default now();

alter table "public"."customer_processed_webhooks" 
    add column if not exists "created_at" timestamp without time zone not null default now(),
    add column if not exists "updated_at" timestamp without time zone not null default now();

alter table "public"."customer_refunds" 
    add column if not exists "updated_at" timestamp without time zone not null default now();

alter table "public"."user_categories" 
    add column if not exists "updated_at" timestamp with time zone not null default now();

alter table "public"."user_topics" 
    add column if not exists "created_at" timestamp with time zone not null default now(),
    add column if not exists "updated_at" timestamp with time zone not null default now();


-- =============================================================================
-- SECTION 13: ADDITIONAL COMPUTED COLUMNS FOR REMAINING TABLES
-- =============================================================================



-- =============================================================================
-- SECTION 14: PERFORMANCE AND FUNCTIONAL INDEXES
-- =============================================================================

-- Standard created_at and id indexes for all tables
create index if not exists "idx_addresses_created_at" on "public"."addresses" using btree ("created_at" desc);
create index if not exists "idx_addresses_id_created_at" on "public"."addresses" using btree ("id", "created_at" desc);
create index if not exists "idx_astronomy_events_created_at" on "public"."astronomy_events" using btree ("created_at" desc);
create index if not exists "idx_astronomy_events_id_created_at" on "public"."astronomy_events" using btree ("id", "created_at" desc);
create index if not exists "idx_categories_created_at" on "public"."categories" using btree ("created_at" desc);
create index if not exists "idx_categories_id_created_at" on "public"."categories" using btree ("id", "created_at" desc);
create index if not exists "idx_news_created_at" on "public"."news" using btree ("created_at" desc);
create index if not exists "idx_opportunities_created_at" on "public"."opportunities" using btree ("created_at" desc);
create index if not exists "idx_organizations_created_at" on "public"."organizations" using btree ("created_at" desc);
create index if not exists "idx_people_created_at" on "public"."people" using btree ("created_at" desc);
create index if not exists "idx_research_created_at" on "public"."research" using btree ("created_at" desc);
create index if not exists "idx_topics_created_at" on "public"."topics" using btree ("created_at" desc);
create index if not exists "idx_topic_clusters_created_at" on "public"."topic_clusters" using btree ("created_at" desc);

-- Foreign key relationship indexes
create index if not exists "idx_astronomy_events_organization_id" on "public"."astronomy_events" using btree ("organization_id");
create index if not exists "idx_astronomy_events_person_id" on "public"."astronomy_events" using btree ("person_id");
create index if not exists "idx_news_organization_id" on "public"."news" using btree ("organization_id");
create index if not exists "idx_news_person_id" on "public"."news" using btree ("person_id");
create index if not exists "idx_opportunities_organization_id" on "public"."opportunities" using btree ("organization_id");
create index if not exists "idx_opportunities_person_id" on "public"."opportunities" using btree ("person_id");
create index if not exists "idx_research_person_id" on "public"."research" using btree ("person_id");

-- Computed column indexes for fast filtering
create index if not exists "idx_astronomy_events_published" on "public"."astronomy_events" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_categories_published" on "public"."categories" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_news_published" on "public"."news" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_opportunities_published" on "public"."opportunities" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_organizations_published" on "public"."organizations" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_people_published" on "public"."people" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_research_published" on "public"."research" 
using btree ("is_public_computed") where ("is_public_computed" = true);

create index if not exists "idx_topics_published" on "public"."topics" 
using btree ("is_public_computed") where ("is_public_computed" = true);

-- Processing status indexes
create index if not exists "idx_news_processing" on "public"."news" 
using btree ("is_processing_computed") where ("is_processing_computed" = true);

create index if not exists "idx_opportunities_processing" on "public"."opportunities" 
using btree ("is_processing_computed") where ("is_processing_computed" = true);

create index if not exists "idx_research_processing" on "public"."research" 
using btree ("is_processing_computed") where ("is_processing_computed" = true);

create index if not exists "idx_topics_processing" on "public"."topics" 
using btree ("is_processing_computed") where ("is_processing_computed" = true);


-- ===================================
-- 12. OPTIMIZED INDEXES
-- ===================================

-- Status History indexes (audit and performance)
CREATE INDEX IF NOT EXISTS idx_status_history_recent ON public.status_history USING btree (transitioned_at DESC);
CREATE INDEX IF NOT EXISTS idx_status_history_record_table ON public.status_history USING btree (record_id, source_table);
CREATE INDEX IF NOT EXISTS idx_status_history_track ON public.status_history USING btree (track, to_status);

-- News indexes
CREATE INDEX IF NOT EXISTS idx_news_visibility ON public.news USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_news_published ON public.news USING btree (is_public) WHERE (is_public = true);
CREATE INDEX IF NOT EXISTS idx_news_needs_review ON public.news USING btree (processing_status, review_status) WHERE ((processing_status = 'completed'::text) AND (review_status = 'pending_review'::text));

-- Research indexes  
CREATE INDEX IF NOT EXISTS idx_research_visibility ON public.research USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_research_published ON public.research USING btree (is_public) WHERE (is_public = true);
CREATE INDEX IF NOT EXISTS idx_research_peer_reviewed ON public.research USING btree (is_peer_reviewed, is_public) WHERE ((is_peer_reviewed = true) AND (is_public = true));

-- Topics indexes
CREATE INDEX IF NOT EXISTS idx_topics_visibility ON public.topics USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_topics_processing ON public.topics USING btree (processing_status);
CREATE INDEX IF NOT EXISTS idx_topics_review ON public.topics USING btree (review_status);
CREATE INDEX IF NOT EXISTS idx_topics_moderation ON public.topics USING btree (moderation_status);
CREATE INDEX IF NOT EXISTS idx_topics_indexing ON public.topics USING btree (indexing_status);
CREATE INDEX IF NOT EXISTS idx_topics_published ON public.topics USING btree (is_public) WHERE (is_public = true);
CREATE INDEX IF NOT EXISTS idx_topics_needs_processing ON public.topics USING btree (processing_status) WHERE (processing_status = ANY (ARRAY['queued'::text, 'retrying'::text]));

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_visibility ON public.categories USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_categories_review ON public.categories USING btree (review_status);
CREATE INDEX IF NOT EXISTS idx_categories_published ON public.categories USING btree (is_public) WHERE (is_public = true);

-- Newsletter indexes
CREATE INDEX IF NOT EXISTS idx_newsletters_visibility ON public.newsletters USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_newsletters_review ON public.newsletters USING btree (review_status);

-- Organization indexes
CREATE INDEX IF NOT EXISTS idx_organizations_visibility ON public.organizations USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_organizations_review ON public.organizations USING btree (review_status);
CREATE INDEX IF NOT EXISTS idx_organizations_moderation ON public.organizations USING btree (moderation_status);
CREATE INDEX IF NOT EXISTS idx_organizations_public ON public.organizations USING btree (is_public) WHERE (is_public = true);
CREATE INDEX IF NOT EXISTS idx_organizations_directory_ready ON public.organizations USING btree (is_directory_ready) WHERE (is_directory_ready = true);

-- People indexes
CREATE INDEX IF NOT EXISTS idx_people_visibility ON public.people USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_people_directory_ready ON public.people USING btree (is_directory_ready) WHERE (is_directory_ready = true);

-- Opportunities indexes
CREATE INDEX IF NOT EXISTS idx_opportunities_visibility ON public.opportunities USING btree (visibility_status);
CREATE INDEX IF NOT EXISTS idx_opportunities_active ON public.opportunities USING btree (is_active_opportunity) WHERE (is_active_opportunity = true);
CREATE INDEX IF NOT EXISTS idx_opportunities_expiry ON public.opportunities USING btree (expires_at) WHERE (expires_at IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_opportunities_active_with_expiry ON public.opportunities USING btree (is_active_opportunity, expires_at) WHERE (is_active_opportunity = true);
CREATE INDEX IF NOT EXISTS idx_opportunities_active_no_expiry ON public.opportunities USING btree (is_active_opportunity) WHERE ((is_active_opportunity = true) AND (expires_at IS NULL));

-- User profile indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_moderation ON public.user_profiles USING btree (moderation_status);
CREATE INDEX IF NOT EXISTS idx_user_profiles_flagged ON public.user_profiles USING btree (moderation_status) WHERE (moderation_status = ANY (ARRAY['flagged'::text, 'suspended'::text, 'banned'::text]));
CREATE INDEX IF NOT EXISTS idx_user_profiles_can_interact ON public.user_profiles USING btree (can_interact) WHERE (can_interact = true);

-- Content Sources indexes
CREATE INDEX IF NOT EXISTS idx_content_sources_processing ON public.content_sources USING btree (processing_status);
CREATE INDEX IF NOT EXISTS idx_content_sources_workflow ON public.content_sources USING btree (workflow_status);
CREATE INDEX IF NOT EXISTS idx_content_sources_healthy ON public.content_sources USING btree (is_source_healthy) WHERE (is_source_healthy = true);
CREATE INDEX IF NOT EXISTS idx_content_sources_failures ON public.content_sources USING btree (failed_count) WHERE (failed_count > 0);

-- Domain URLs indexes
CREATE INDEX IF NOT EXISTS idx_domain_urls_processing ON public.domain_urls USING btree (processing_status);
CREATE INDEX IF NOT EXISTS idx_domain_urls_review ON public.domain_urls USING btree (review_status);
CREATE INDEX IF NOT EXISTS idx_domain_urls_priority_status ON public.domain_urls USING btree (priority_status);
CREATE INDEX IF NOT EXISTS idx_domain_urls_ready_to_process ON public.domain_urls USING btree (is_ready_to_process) WHERE (is_ready_to_process = true);
CREATE INDEX IF NOT EXISTS idx_domain_urls_high_priority ON public.domain_urls USING btree (is_high_priority) WHERE (is_high_priority = true);
CREATE INDEX IF NOT EXISTS idx_domain_urls_errors ON public.domain_urls USING btree (error_count) WHERE (error_count > 0);

-- Domain Contacts indexes
CREATE INDEX IF NOT EXISTS idx_domain_contacts_processing ON public.domain_contacts USING btree (processing_status);
CREATE INDEX IF NOT EXISTS idx_domain_contacts_verified ON public.domain_contacts USING btree (is_verified_contact) WHERE (is_verified_contact = true);
CREATE INDEX IF NOT EXISTS idx_domain_contacts_confidence ON public.domain_contacts USING btree (confidence DESC);
CREATE INDEX IF NOT EXISTS idx_domain_contacts_by_domain ON public.domain_contacts USING btree (domain_root_id, is_verified_contact);

-- Domain Assets indexes
CREATE INDEX IF NOT EXISTS idx_domain_assets_processing ON public.domain_assets USING btree (processing_status);
CREATE INDEX IF NOT EXISTS idx_domain_assets_available ON public.domain_assets USING btree (is_available) WHERE (is_available = true);
CREATE INDEX IF NOT EXISTS idx_domain_assets_by_type ON public.domain_assets USING btree (asset_type, is_available) WHERE (is_available = true);


-- Profile links indexes
CREATE INDEX IF NOT EXISTS idx_profile_links_entity ON public.profile_links(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_profile_links_type ON public.profile_links(link_type);
CREATE INDEX IF NOT EXISTS idx_profile_links_primary ON public.profile_links(entity_type, entity_id, link_type) WHERE is_primary = true;


CREATE INDEX idx_permission_configs_enabled ON public.permission_configs USING btree (enabled, table_name) WHERE (enabled = true);

CREATE INDEX idx_permission_configs_role_plan ON public.permission_configs USING btree (required_role, required_plan) WHERE (enabled = true);

CREATE INDEX idx_permission_configs_table_action ON public.permission_configs USING btree (table_name, action, required_role) WHERE (enabled = true);

CREATE UNIQUE INDEX permission_configs_pkey ON public.permission_configs USING btree (id);

CREATE UNIQUE INDEX unique_permission_per_table ON public.permission_configs USING btree (table_name, permission_name);


-- =============================================================================
-- SECTION 11: SPECIALIZED GRAPH EDGE INDEXES
-- =============================================================================

-- Graph edges authorship optimization
create unique index "graph_edges_authorship_unique_edge" on "public"."graph_edges_authorship" 
using btree ("source_type", "source_id", "target_type", "target_id", "edge_type");

create index "graph_edges_authorship_source_id_source_type_idx" on "public"."graph_edges_authorship" 
using btree ("source_id", "source_type");

create index "graph_edges_authorship_target_id_target_type_idx" on "public"."graph_edges_authorship" 
using btree ("target_id", "target_type");

create index "idx_authorship_topic_cluster_critical" on "public"."graph_edges_authorship" 
using btree ("target_id", "source_type", "confidence", "source_id") 
where (("target_type" = 'topic'::text) and ("confidence" >= 0.7));

-- Graph edges citation optimization
create unique index "graph_edges_citation_unique_edge" on "public"."graph_edges_citation" 
using btree ("source_type", "source_id", "target_type", "target_id", "edge_type");

create index "graph_edges_citation_source_id_source_type_idx" on "public"."graph_edges_citation" 
using btree ("source_id", "source_type");

create index "graph_edges_citation_target_id_target_type_idx" on "public"."graph_edges_citation" 
using btree ("target_id", "target_type");

create index "idx_citation_topic_cluster_critical" on "public"."graph_edges_citation" 
using btree ("target_id", "source_type", "confidence", "source_id") 
where (("target_type" = 'topic'::text) and ("confidence" >= 0.7));

-- Graph edges experimental optimization
create unique index "graph_edges_experimental_unique_edge" on "public"."graph_edges_experimental" 
using btree ("source_type", "source_id", "target_type", "target_id", "edge_type");

create index "graph_edges_experimental_source_id_source_type_idx" on "public"."graph_edges_experimental" 
using btree ("source_id", "source_type");

create index "graph_edges_experimental_target_id_target_type_idx" on "public"."graph_edges_experimental" 
using btree ("target_id", "target_type");

create index "idx_experimental_topic_cluster_critical" on "public"."graph_edges_experimental" 
using btree ("target_id", "source_type", "confidence", "source_id") 
where (("target_type" = 'topic'::text) and ("confidence" >= 0.7));

-- Graph edges organizational optimization
create unique index "graph_edges_organizational_unique_edge" on "public"."graph_edges_organizational" 
using btree ("source_type", "source_id", "target_type", "target_id", "edge_type");

create index "graph_edges_organizational_source_id_source_type_idx" on "public"."graph_edges_organizational" 
using btree ("source_id", "source_type");

create index "graph_edges_organizational_target_id_target_type_idx" on "public"."graph_edges_organizational" 
using btree ("target_id", "target_type");

create index "idx_organizational_topic_cluster_critical" on "public"."graph_edges_organizational" 
using btree ("target_id", "source_type", "confidence", "source_id") 
where (("target_type" = 'topic'::text) and ("confidence" >= 0.7));

-- Graph edges semantic optimization
create unique index "graph_edges_semantic_unique_edge" on "public"."graph_edges_semantic" 
using btree ("source_type", "source_id", "target_type", "target_id", "edge_type");

create index "graph_edges_semantic_source_id_source_type_idx" on "public"."graph_edges_semantic" 
using btree ("source_id", "source_type");

create index "graph_edges_semantic_target_id_target_type_idx" on "public"."graph_edges_semantic" 
using btree ("target_id", "target_type");

create index "idx_semantic_topic_cluster_critical" on "public"."graph_edges_semantic" 
using btree ("target_id", "source_type", "confidence", "source_id") 
where (("target_type" = 'topic'::text) and ("confidence" >= 0.7));

create index "idx_graph_edges_semantic_insert_perf" on "public"."graph_edges_semantic" 
using btree ("source_type", "target_type", "edge_type", "source_id", "target_id");





-- ============================================================================
-- INDEXES - PERFORMANCE OPTIMIZED
-- ============================================================================

-- Core graph indexes (applied to parent and all partitions)
DO $$ BEGIN
    -- Main relationship lookup indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_graph_edges_source') THEN
        CREATE INDEX idx_graph_edges_source ON public.graph_edges(source_type, source_id) 
            INCLUDE (target_type, target_id, weight, confidence);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_graph_edges_target') THEN
        CREATE INDEX idx_graph_edges_target ON public.graph_edges(target_type, target_id) 
            INCLUDE (source_type, source_id, weight, confidence);
    END IF;
    
    -- Unique constraint for preventing duplicate edges
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_graph_edges_unique_relationship') THEN
        CREATE UNIQUE INDEX idx_graph_edges_unique_relationship ON public.graph_edges(source_type, source_id, target_type, target_id, edge_type);
    END IF;
    
    -- High-confidence edges for graph algorithms
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_graph_edges_confidence') THEN
        CREATE INDEX idx_graph_edges_confidence ON public.graph_edges(confidence DESC) 
            WHERE confidence > 0.7;
    END IF;
END $$;



-- People table indexes
CREATE INDEX IF NOT EXISTS idx_people_user_id ON public.people(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_people_birth_year ON public.people(birth_year) WHERE birth_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_people_career_level ON public.people(career_level) WHERE career_level IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_people_nationality ON public.people(nationality) WHERE nationality IS NOT NULL;


-- Topics embedding index (only for rows with embeddings)
CREATE INDEX topics_embedding_hnsw_idx 
ON "public"."topics" 
USING hnsw (embedding extensions.vector_cosine_ops) 
WITH (m='16', ef_construction='64') 
WHERE (embedding IS NOT NULL);

-- ============================================================================
-- STEP 4: PERFORMANCE INDEXES
-- Purpose: Optimize common query patterns and user interactions
-- ============================================================================

-- Crawl statistics by organization
CREATE INDEX idx_crawl_stats_organization_id 
ON "public"."crawl_stats" 
USING btree (organization_id);


-- Active subscription queries
CREATE INDEX idx_customer_subscriptions_user_active 
ON "public"."customer_subscriptions" 
USING btree (user_id, status, current_end) 
WHERE (status IN ('active', 'trialing'));

-- Domain URLs by organization
CREATE INDEX idx_domain_urls_organization_id 
ON "public"."domain_urls" 
USING btree (organization_id);

-- Organization directory queries (approved organizations by type)
CREATE INDEX idx_organizations_type_approved 
ON "public"."organizations" 
USING btree (organization_type, is_approved) 
WHERE (is_approved = true);

-- Status history queries (recent changes by table)
CREATE INDEX idx_status_history_recent_by_table 
ON "public"."status_history" 
USING btree (source_table, record_id, transitioned_at DESC);

-- User topic subscriptions (notification preferences)
CREATE INDEX idx_user_topics_subscribed_frequency 
ON "public"."user_topics" 
USING btree (user_id, notification_frequency) 
WHERE (subscribed_at IS NOT NULL);


-- User subscription indexes
CREATE INDEX "idx_user_topics_subscriptions" 
ON "public"."user_topics" ("user_id", "subscribed_at") 
WHERE "subscribed_at" IS NOT NULL;

-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================