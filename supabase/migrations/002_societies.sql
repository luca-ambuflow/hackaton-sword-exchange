-- =====================================================
-- Migration: 002_societies.sql
-- Description: Societies directory and administrator management
-- Phase: 1 - Society Directory
-- =====================================================

-- =====================================================
-- TABLE: societies
-- Description: Society/school directory with full details
-- =====================================================
CREATE TABLE public.societies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL, -- SEO-friendly URL

  -- Required fields
  ragione_sociale TEXT NOT NULL, -- Official name
  codice_fiscale TEXT NOT NULL UNIQUE, -- Tax code
  sede TEXT NOT NULL, -- Headquarters

  -- Optional fields
  partita_iva TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  disciplines TEXT, -- Free text description of taught disciplines
  description TEXT,

  -- Location (text-based, no coordinates in MVP)
  region TEXT,
  province TEXT,
  city TEXT,
  address TEXT,
  postal_code TEXT,

  -- Metadata
  logo_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE, -- Admin verified
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ -- Soft delete
);

-- =====================================================
-- TABLE: society_administrators
-- Description: Many-to-many relationship between users and societies
-- =====================================================
CREATE TABLE public.society_administrators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'admin', -- Future: 'owner', 'admin', 'editor'
  approved_by UUID REFERENCES public.profiles(id), -- Platform admin who approved
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(society_id, user_id)
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.societies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.society_administrators ENABLE ROW LEVEL SECURITY;

-- Societies Policies
CREATE POLICY "Societies are viewable by everyone"
  ON public.societies FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "Authenticated users can create societies"
  ON public.societies FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Society admins can update their society"
  ON public.societies FOR UPDATE
  USING (
    id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Platform admins can soft delete societies"
  ON public.societies FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Society Administrators Policies
CREATE POLICY "Society admins can view their own admin records"
  ON public.society_administrators FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Platform admins can view all admin records"
  ON public.society_administrators FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

CREATE POLICY "Platform admins can manage society administrators"
  ON public.society_administrators FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- =====================================================
-- INDEXES (SEO & Performance)
-- =====================================================

-- Primary lookups
CREATE INDEX idx_societies_slug ON public.societies(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_codice_fiscale ON public.societies(codice_fiscale) WHERE deleted_at IS NULL;

-- Filtering & sorting
CREATE INDEX idx_societies_region_province ON public.societies(region, province) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_verified ON public.societies(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_created_at ON public.societies(created_at DESC) WHERE deleted_at IS NULL;

-- Full-text search (Italian language)
CREATE INDEX idx_societies_search ON public.societies
  USING GIN(to_tsvector('italian', ragione_sociale || ' ' || COALESCE(description, '') || ' ' || COALESCE(city, '')));

-- Administrators lookup
CREATE INDEX idx_society_administrators_society ON public.society_administrators(society_id);
CREATE INDEX idx_society_administrators_user ON public.society_administrators(user_id);
CREATE INDEX idx_society_administrators_approved ON public.society_administrators(approved_at) WHERE approved_at IS NOT NULL;

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Trigger: Update societies updated_at
CREATE TRIGGER update_societies_updated_at
  BEFORE UPDATE ON public.societies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Generate unique slug from ragione_sociale
CREATE OR REPLACE FUNCTION public.generate_society_slug(ragione_sociale TEXT)
RETURNS TEXT AS $$
DECLARE
  base_slug TEXT;
  final_slug TEXT;
  counter INTEGER := 1;
BEGIN
  -- Normalize and slugify
  base_slug := lower(regexp_replace(
    unaccent(ragione_sociale),
    '[^a-z0-9]+',
    '-',
    'g'
  ));
  base_slug := trim(both '-' from base_slug);
  
  final_slug := base_slug;
  
  -- Check for uniqueness and append counter if needed
  WHILE EXISTS (SELECT 1 FROM public.societies WHERE slug = final_slug) LOOP
    final_slug := base_slug || '-' || counter;
    counter := counter + 1;
  END LOOP;
  
  RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-generate slug before insert
CREATE OR REPLACE FUNCTION public.society_slug_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := public.generate_society_slug(NEW.ragione_sociale);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_society_slug
  BEFORE INSERT ON public.societies
  FOR EACH ROW EXECUTE FUNCTION public.society_slug_trigger();

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.societies IS 'Directory of historical fencing societies/schools';
COMMENT ON TABLE public.society_administrators IS 'Users who can manage a society (many-to-many)';

COMMENT ON COLUMN public.societies.slug IS 'SEO-friendly URL identifier (auto-generated from ragione_sociale)';
COMMENT ON COLUMN public.societies.ragione_sociale IS 'Official legal name of the society';
COMMENT ON COLUMN public.societies.codice_fiscale IS 'Italian tax code (unique identifier)';
COMMENT ON COLUMN public.societies.is_verified IS 'Verified by platform admin';
COMMENT ON COLUMN public.societies.deleted_at IS 'Soft delete timestamp (NULL = active)';

COMMENT ON COLUMN public.society_administrators.role IS 'Admin role (currently: admin, future: owner/editor)';
COMMENT ON COLUMN public.society_administrators.approved_by IS 'Platform admin who approved this administrator';
