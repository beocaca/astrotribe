-- ============================================================================
-- CONTENTS LAYER MIGRATION
-- ============================================================================
-- Purpose: Content management system with embeddings, organizations,
--          people relationships, and specialized content types
-- Date: 2025-05-26
-- Version: v1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. ENUMS
-- ============================================================================

CREATE TYPE "public"."embedding_status" AS ENUM ('pending', 'ready', 'stale', 'error');



-- ============================================================================
-- 4. CORE TOPICS TABLES
-- ============================================================================

-- Main topics table
CREATE TABLE "public"."topics" (
   "id" UUID NOT NULL DEFAULT extensions.gen_random_uuid(),
   "title" TEXT NOT NULL,
   "slug" TEXT NOT NULL,
   "summary" TEXT,
   "status_id" TEXT,
   "embedding" extensions.vector(768),
   "embedding_model" TEXT,
   "embedding_version" TEXT,
   "last_embedded_at" TIMESTAMPTZ,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "updated_at" TIMESTAMPTZ DEFAULT NOW(),
   "title_vector" tsvector,
   "version" TEXT,
   
   CONSTRAINT "topics_pkey" PRIMARY KEY ("id"),
   CONSTRAINT "topics_slug_key" UNIQUE ("slug")
);


-- User topic interactions and progress tracking
CREATE TABLE "public"."user_topics" (
   "user_id" UUID NOT NULL,
   "topic_id" UUID NOT NULL,
   "bookmarked" BOOLEAN DEFAULT false,
   "progress" DOUBLE PRECISION DEFAULT 0.0,
   "started_at" TIMESTAMPTZ,
   "completed_at" TIMESTAMPTZ,
   "xp_earned" INTEGER DEFAULT 0,
   "reflections" TEXT,
   
   CONSTRAINT "user_topics_pkey" PRIMARY KEY ("user_id", "topic_id")
);

-- ============================================================================
-- 3. SPECIALIZED CONTENT TYPES
-- ============================================================================

-- Job opportunities and positions
DROP TABLE IF EXISTS "public"."opportunities" CASCADE;
CREATE TABLE "public"."opportunities" (
   "id" UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
   "title" TEXT,
   "location" TEXT,
   "description" TEXT,
   "expires_at" TIMESTAMPTZ,
   "checked_at" TIMESTAMPTZ,
   "updated_at" TIMESTAMPTZ,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "content_status" TEXT,
   "url" TEXT,
   "metadata" JSONB,
   "employment_type" TEXT,
   "source_id" UUID,
   "uri" TEXT,
   "requirements" JSONB,
   "benefits" JSONB,
   "application_url" TEXT,
   "change_hash" TEXT,
   "removed_at" TIMESTAMPTZ,
   "published_at" TIMESTAMPTZ,
   "featured" BOOLEAN
);

-- News articles and updates
DROP TABLE IF EXISTS "public"."news" CASCADE;
CREATE TABLE "public"."news" (
   "id" UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
   "source_id" UUID,
   "title" TEXT,
   "description" TEXT,
   "url" TEXT,
   "author_name_fallback" TEXT,
   "published_at" TIMESTAMPTZ,
   "featured_image" TEXT,
   "news_type" TEXT,
   "is_featured" BOOLEAN,
   "is_active" BOOLEAN,
   "primary_category_id" UUID REFERENCES "public"."categories"("id") ON DELETE SET NULL,
   "content_text" TEXT,
   "title_vector" tsvector,
   "language_code" TEXT,
   "change_hash" TEXT,
   "graph_migrated_at" TIMESTAMPTZ,
   "removed_at" TIMESTAMPTZ,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "updated_at" TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 4. ORGANIZATIONS AND PEOPLE
-- ============================================================================

-- Organizations and institutions
DROP TABLE IF EXISTS "public"."organizations" CASCADE;
CREATE TABLE "public"."organizations" (
   "id" UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
   "name" TEXT NOT NULL,
   "description" TEXT,
   "logo_url" TEXT,
   "url" TEXT NOT NULL,
   "domain_root_id" UUID REFERENCES "public"."domain_roots"("id") ON DELETE SET NULL,
   "scrape_frequency" TEXT,
   "founding_year" SMALLINT,
   "is_government" BOOLEAN DEFAULT false,
   "category_id" UUID,
   "scraped_at" TIMESTAMPTZ,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "updated_at" TIMESTAMPTZ DEFAULT NOW(),
   "content_status" TEXT
);

-- Content source configuration
DROP TABLE IF EXISTS "public"."content_sources" CASCADE;
CREATE TABLE "public"."content_sources" (
   "id" UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
   "name" TEXT,
   "url" TEXT NOT NULL,
   "content_type" TEXT NOT NULL,
   "scrape_frequency" TEXT NOT NULL,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "updated_at" TIMESTAMPTZ,
   "has_failed" BOOLEAN,
   "failed_count" INTEGER,
   "priority" TEXT NOT NULL,
   "organization_id" UUID REFERENCES "public"."organizations"("id") ON DELETE SET NULL,
   "item_count" INTEGER,
   "parser_type" TEXT NOT NULL,
   "scraped_at" TIMESTAMPTZ
);

-- People and authors
DROP TABLE IF EXISTS "public"."people" CASCADE;
CREATE TABLE "public"."people" (
   "id" UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
   "name" TEXT,
   "affiliation" TEXT,
   "role" TEXT,
   "email" TEXT,
   "orcid" TEXT,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   "updated_at" TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 5. RELATIONSHIP TABLES
-- ============================================================================

-- Organization-people relationships
CREATE TABLE "public"."organization_people" (
   "organization_id" UUID NOT NULL REFERENCES "public"."organizations"("id") ON DELETE CASCADE,
   "person_id" UUID NOT NULL REFERENCES "public"."people"("id") ON DELETE CASCADE,
   "role" TEXT,
   "created_at" TIMESTAMPTZ DEFAULT NOW(),
   
   PRIMARY KEY ("organization_id", "person_id")
);


CREATE TABLE public.contacts (
  id UUID PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  title VARCHAR,
  is_primary BOOLEAN DEFAULT FALSE,
  email VARCHAR,
  contact_type public.contact_type,
  privacy_level public.privacy_level,
  user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  phone VARCHAR,
  company_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Polymorphic profile links (social media, websites, etc.)
CREATE TABLE IF NOT EXISTS public.profile_links (
    id uuid NOT NULL DEFAULT extensions.gen_random_uuid() PRIMARY KEY,
    entity_type text NOT NULL CHECK (entity_type = ANY (ARRAY['person', 'organization', 'user'])),
    entity_id uuid NOT NULL,
    link_type text NOT NULL,
    url text NOT NULL,
    display_name text,
    is_verified boolean DEFAULT false,
    is_primary boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);



COMMIT;

-- ============================================================================
-- POST-MIGRATION NOTES
-- ============================================================================
-- 1. Consider adding indexes for embedding vector searches
-- 2. Set up content source scraping schedules
-- 3. Implement embedding refresh workflows
-- 4. Add validation constraints for content types and statuses
-- ============================================================================