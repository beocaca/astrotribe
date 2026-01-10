-- ============================================================================
-- PERMISSION SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Permission configuration table and custom access token hook
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. PERMISSION CONFIGS TABLE
-- ============================================================================

CREATE TABLE public.permission_configs (
   id UUID NOT NULL DEFAULT extensions.gen_random_uuid() PRIMARY KEY,
   table_name TEXT NOT NULL,
   permission_name TEXT NOT NULL,
   action TEXT NOT NULL,
   required_role public.app_role_enum NOT NULL,
   required_plan public.app_plan_enum,
   requires_ownership BOOLEAN DEFAULT false,
   requires_org_membership BOOLEAN DEFAULT false,
   condition_template TEXT,
   enabled BOOLEAN DEFAULT true,
   priority INTEGER DEFAULT 0,
   notes TEXT,
   created_at TIMESTAMPTZ DEFAULT NOW(),
   updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 2. TABLE CONSTRAINTS
-- ============================================================================

-- Action validation
ALTER TABLE public.permission_configs 
   ADD CONSTRAINT chk_permission_configs_action 
   CHECK (action = ANY (ARRAY['select', 'insert', 'update', 'delete', 'all']));

-- Condition template validation
ALTER TABLE public.permission_configs 
   ADD CONSTRAINT chk_permission_configs_condition_template 
   CHECK (condition_template = ANY (ARRAY[
       'public_content', 'active_content', 'user_owned', 'org_scoped', 
       'user_and_org', 'premium_content', 'published_and_safe', 'directory_ready'
   ]));

-- Unique constraints
ALTER TABLE public.permission_configs 
   ADD CONSTRAINT unq_permission_configs_table_permission_role 
   UNIQUE (table_name, permission_name, required_role);

-- Role-plan combination validation
ALTER TABLE public.permission_configs 
   ADD CONSTRAINT valid_role_plan_combo 
   CHECK ((required_plan IS NULL) OR (required_role = ANY (ARRAY[
       'user'::public.app_role_enum, 'tenant_admin'::public.app_role_enum, 
       'admin'::public.app_role_enum, 'super_admin'::public.app_role_enum
   ])));

-- ============================================================================
-- 3. CUSTOM ACCESS TOKEN HOOK FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
   original_claims JSONB;
   new_claims JSONB;
   user_id UUID;
   user_role TEXT;
   user_plan TEXT;
BEGIN
   original_claims := event->'claims';
   user_id := (event->>'user_id')::UUID;

   -- Fetch user role and plan from user_profiles table
   SELECT
       user_profiles.role::TEXT,
       user_profiles.plan::TEXT
   INTO
       user_role,
       user_plan
   FROM public.user_profiles
   WHERE id = user_id;

   -- Preserve original claims and append custom ones
   new_claims := original_claims;
   new_claims := jsonb_set(new_claims, '{user_role}', to_jsonb(user_role), true);
   new_claims := jsonb_set(new_claims, '{user_plan}', to_jsonb(user_plan), true);

   RETURN jsonb_build_object('claims', new_claims);
END
$$;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Configure Supabase Auth to use custom_access_token_hook
-- 2. Test JWT token generation includes user_role and user_plan claims
-- 3. Validate constraint performance on permission_configs table
-- ============================================================================