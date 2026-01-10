-- ============================================================================
-- CLEANUP AND ORGANIZATION RELATIONSHIPS MIGRATION
-- ============================================================================
-- Purpose: Clean up legacy functions/types and establish organization
--          relationships replacing company-based domain relationships
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================


create table "public"."permission_configs" (
    "id" uuid not null default extensions.gen_random_uuid(),
    "table_name" text not null,
    "permission_name" text not null,
    "action" text not null,
    "required_role" public.app_role_enum not null,
    "required_plan" public.app_plan_enum,
    "requires_ownership" boolean default false,
    "requires_org_membership" boolean default false,
    "condition_template" text,
    "enabled" boolean default true,
    "priority" integer default 0,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


-- Permission configs validation
alter table "public"."permission_configs" 
    drop constraint if exists "permissions_config_action_check";
alter table "public"."permission_configs" 
    add constraint "chk_permission_configs_action" 
    check (("action" = any (array[
        'select'::text, 'insert'::text, 'update'::text, 'delete'::text, 'all'::text
    ]))) not valid;
alter table "public"."permission_configs" validate constraint "chk_permission_configs_action";

alter table "public"."permission_configs" 
    drop constraint if exists "permissions_config_condition_template_check";
alter table "public"."permission_configs" 
    add constraint "chk_permission_configs_condition_template" 
    check (("condition_template" = any (array[
        'public_content'::text, 'active_content'::text, 'user_owned'::text, 
        'org_scoped'::text, 'user_and_org'::text, 'premium_content'::text, 
        'published_and_safe'::text, 'directory_ready'::text
    ]))) not valid;
alter table "public"."permission_configs" validate constraint "chk_permission_configs_condition_template";

alter table "public"."permission_configs" 
    drop constraint if exists "unq_permission_configs_table_permission_role";
alter table "public"."permission_configs" 
    add constraint "unq_permission_configs_table_permission_role" 
    unique ("table_name", "permission_name", "required_role");




alter table "public"."permission_configs" add constraint "permission_configs_pkey" PRIMARY KEY using index "permission_configs_pkey";

alter table "public"."permission_configs" add constraint "permission_configs_action_check" CHECK ((action = ANY (ARRAY['select'::text, 'insert'::text, 'update'::text, 'delete'::text, 'all'::text]))) not valid;

alter table "public"."permission_configs" validate constraint "permission_configs_action_check";

alter table "public"."permission_configs" add constraint "permission_configs_condition_template_check" CHECK ((condition_template = ANY (ARRAY['public_content'::text, 'active_content'::text, 'user_owned'::text, 'org_scoped'::text, 'user_and_org'::text, 'premium_content'::text, 'published_and_safe'::text, 'directory_ready'::text]))) not valid;

alter table "public"."permission_configs" validate constraint "permission_configs_condition_template_check";

alter table "public"."permission_configs" add constraint "unique_permission_per_table" UNIQUE using index "unique_permission_per_table";

alter table "public"."permission_configs" add constraint "valid_role_plan_combo" CHECK (((required_plan IS NULL) OR (required_role = ANY (ARRAY['user'::public.app_role_enum, 'tenant_admin'::public.app_role_enum, 'admin'::public.app_role_enum, 'super_admin'::public.app_role_enum])))) not valid;

alter table "public"."permission_configs" validate constraint "valid_role_plan_combo";



SET check_function_bodies = off;

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
security definer
as $$
declare
  original_claims jsonb;
  new_claims jsonb;
  user_id uuid;
  user_role text;
  user_plan text;
begin
  original_claims := event->'claims';
  user_id := (event->>'user_id')::uuid;

  -- Fetch user role and plan from your user_profiles table
  select
    user_profiles.role::text,
    user_profiles.plan::text
  into
    user_role,
    user_plan
  from public.user_profiles
  where id = user_id;

  -- Preserve original claims and append custom ones
  -- This can be refined for performance gains in the future
  new_claims := original_claims;
  -- Add custom claims  
  new_claims := jsonb_set(new_claims, '{user_role}', to_jsonb(user_role), true);
  new_claims := jsonb_set(new_claims, '{user_plan}', to_jsonb(user_plan), true);

  return jsonb_build_object('claims', new_claims);
end
$$;

