


ALTER TABLE public.user_profiles
ADD COLUMN organization_id uuid NULL;

-- Step 2: Add the foreign key constraint
ALTER TABLE public.user_profiles
ADD CONSTRAINT fk_user_profiles_organization
FOREIGN KEY (organization_id)
REFERENCES public.organizations(id)
ON DELETE SET NULL;


  
alter table "public"."organization_people" 
    add column if not exists "updated_at" timestamp with time zone not null default now();

-- Complete remaining computed column migrations
alter table "public"."newsletters" 
    drop column if exists "is_approved",
    drop column if exists "is_public",
    add column "is_approved_computed" boolean generated always as (
        (review_status = 'approved'::text)
    ) stored,
    add column "is_public_computed" boolean generated always as (
        (visibility_status = 'published'::text)
    ) stored;
