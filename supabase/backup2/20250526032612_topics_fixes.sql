-- ============================================================================
-- DISCOVERY & CONTENT SYSTEM MIGRATION
-- ============================================================================
-- Purpose: Enhance content discovery with improved topic relationships,
--          reference types system, and user subscription management
-- Date: 2025-05-26
-- Version: v1.2.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 2. COLUMN ADDITIONS
-- ============================================================================

-- Add organization type classification
ALTER TABLE "public"."organizations" 
ADD COLUMN IF NOT EXISTS "organization_type" TEXT DEFAULT 'company';

-- Enhance user topic subscriptions with learning progression
ALTER TABLE "public"."user_topics" 
ADD COLUMN IF NOT EXISTS "subscribed_at" TIMESTAMPTZ;

-- ============================================================================
-- 3. CONSTRAINTS & VALIDATION
-- ============================================================================

-- Enum-style constraints for controlled vocabularies
ALTER TABLE "public"."news" 
ADD CONSTRAINT "chk_news_type" 
CHECK ("news_type" IN ('breaking', 'analysis', 'interview', 'press_release', 'research_summary', 'mission_update'));

ALTER TABLE "public"."opportunities" 
ADD CONSTRAINT "chk_opportunities_employment_type" 
CHECK ("employment_type" IN ('full_time', 'part_time', 'contract', 'internship', 'freelance', 'remote', 'hybrid')),

ALTER TABLE "public"."organizations" 
ADD CONSTRAINT "chk_organizations_org_type" 
CHECK ("organization_type" IN ('company', 'university', 'government', 'nonprofit', 'research_institute'));


COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 3. Review materialized view refresh frequency based on usage patterns
-- ============================================================================