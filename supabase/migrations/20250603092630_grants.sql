-- ============================================================================
-- GRANTS AND PERMISSIONS MIGRATION
-- ============================================================================
-- Purpose: Grant appropriate permissions to database roles
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. STATUS SYSTEM PERMISSIONS
-- ============================================================================

-- Status History permissions
GRANT SELECT, INSERT ON public.status_history TO anon, authenticated;
GRANT ALL ON public.status_history TO service_role;

-- Status Registry permissions  
GRANT SELECT ON public.statuses TO anon, authenticated;
GRANT ALL ON public.statuses TO service_role;

-- Function permissions
GRANT EXECUTE ON FUNCTION public.update_status(text, uuid, text, text, jsonb) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.update_status_batch(text, uuid[], text, text, jsonb) TO authenticated, service_role;

-- ============================================================================
-- 2. TOPICS SYSTEM PERMISSIONS
-- ============================================================================

GRANT ALL ON TABLE public.topics TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.user_topics TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.topic_clusters TO anon, authenticated, service_role;

-- ============================================================================
-- 3. CONTENT SYSTEM PERMISSIONS
-- ============================================================================

GRANT ALL ON TABLE public.opportunities TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.news TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.organizations TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.content_sources TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.people TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.organization_people TO anon, authenticated, service_role;

-- ============================================================================
-- 4. PERMISSION CONFIGURATION SYSTEM
-- ============================================================================

GRANT ALL ON TABLE public.permission_configs TO anon, authenticated, service_role;

COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Review permissions for production environment security
-- 2. Consider restricting anon permissions for sensitive tables
-- 3. Implement RLS policies to control row-level access
-- ============================================================================