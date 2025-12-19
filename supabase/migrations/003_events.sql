-- =====================================================
-- Migration: 003_events.sql
-- Description: Events calendar and moderation system
-- Phase: 2 - Events Calendar
-- =====================================================

-- =====================================================
-- TABLE: events
-- Description: Global events calendar (tournaments, sparring, seminars, open training)
-- =====================================================
CREATE TYPE event_type AS ENUM ('gara', 'sparring', 'seminario', 'allenamento_aperto');

CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL, -- SEO-friendly URL

  -- Core fields
  title TEXT NOT NULL,
  description TEXT,
  event_type event_type NOT NULL,
  external_link TEXT, -- Link to external event page/registration

  -- Date/time (stored in UTC + original timezone)
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ,
  timezone TEXT NOT NULL DEFAULT 'Europe/Rome',

  -- Location (text-based for MVP)
  region TEXT,
  province TEXT,
  city TEXT,
  location_name TEXT, -- Venue name
  address TEXT,

  -- Organizer
  creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID REFERENCES public.societies(id) ON DELETE SET NULL, -- Optional

  -- Disciplines (array of codes from disciplines table)
  disciplines TEXT[], -- e.g., ['spada_lunga', 'daga', ...]

  -- Moderation
  is_published BOOLEAN DEFAULT TRUE,
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES public.profiles(id),
  deletion_reason TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: event_moderation_log
-- Description: Audit trail for event deletions by admins
-- =====================================================
CREATE TABLE public.event_moderation_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL, -- Not FK (event might be soft deleted)
  event_title TEXT NOT NULL, -- Store title for reference
  deleted_by UUID NOT NULL REFERENCES public.profiles(id),
  reason TEXT NOT NULL,
  deleted_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_moderation_log ENABLE ROW LEVEL SECURITY;

-- Events Policies
CREATE POLICY "Published events are viewable by everyone"
  ON public.events FOR SELECT
  USING (deleted_at IS NULL AND is_published = TRUE);

CREATE POLICY "Event creator can view their own unpublished events"
  ON public.events FOR SELECT
  USING (creator_id = auth.uid());

CREATE POLICY "Platform admins can view all events"
  ON public.events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

CREATE POLICY "Authenticated users can create events"
  ON public.events FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' AND creator_id = auth.uid());

CREATE POLICY "Event creator can update their own event"
  ON public.events FOR UPDATE
  USING (creator_id = auth.uid());

CREATE POLICY "Platform admins can update any event (moderation)"
  ON public.events FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Event Moderation Log Policies
CREATE POLICY "Platform admins can view moderation log"
  ON public.event_moderation_log FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

CREATE POLICY "Platform admins can insert moderation log"
  ON public.event_moderation_log FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- =====================================================
-- INDEXES (SEO & Performance)
-- =====================================================

-- Primary lookups
CREATE INDEX idx_events_slug ON public.events(slug) WHERE deleted_at IS NULL;

-- Date-based queries (most common)
CREATE INDEX idx_events_start_datetime ON public.events(start_datetime DESC)
  WHERE deleted_at IS NULL AND is_published = TRUE;

CREATE INDEX idx_events_date_range ON public.events(start_datetime, end_datetime)
  WHERE deleted_at IS NULL AND is_published = TRUE;

-- Filtering
CREATE INDEX idx_events_region_province ON public.events(region, province)
  WHERE deleted_at IS NULL AND is_published = TRUE;

CREATE INDEX idx_events_society_id ON public.events(society_id)
  WHERE deleted_at IS NULL;

CREATE INDEX idx_events_type ON public.events(event_type)
  WHERE deleted_at IS NULL AND is_published = TRUE;

CREATE INDEX idx_events_creator ON public.events(creator_id);

-- Disciplines (GIN index for array search)
CREATE INDEX idx_events_disciplines ON public.events USING GIN(disciplines)
  WHERE deleted_at IS NULL AND is_published = TRUE;

-- Full-text search (Italian language)
CREATE INDEX idx_events_search ON public.events
  USING GIN(to_tsvector('italian', title || ' ' || COALESCE(description, '') || ' ' || COALESCE(location_name, '')));

-- Moderation
CREATE INDEX idx_events_published ON public.events(is_published) WHERE deleted_at IS NULL;
CREATE INDEX idx_events_deleted ON public.events(deleted_at) WHERE deleted_at IS NOT NULL;

-- Event Moderation Log
CREATE INDEX idx_event_moderation_log_event_id ON public.event_moderation_log(event_id);
CREATE INDEX idx_event_moderation_log_deleted_at ON public.event_moderation_log(deleted_at DESC);
CREATE INDEX idx_event_moderation_log_deleted_by ON public.event_moderation_log(deleted_by);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Trigger: Update events updated_at
CREATE TRIGGER update_events_updated_at
  BEFORE UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Generate unique slug from event title
CREATE OR REPLACE FUNCTION public.generate_event_slug(title TEXT, start_datetime TIMESTAMPTZ)
RETURNS TEXT AS $$
DECLARE
  base_slug TEXT;
  date_suffix TEXT;
  final_slug TEXT;
  counter INTEGER := 1;
BEGIN
  -- Normalize title
  base_slug := lower(regexp_replace(
    unaccent(title),
    '[^a-z0-9]+',
    '-',
    'g'
  ));
  base_slug := trim(both '-' from base_slug);
  
  -- Add date suffix (YYYY-MM)
  date_suffix := to_char(start_datetime, 'YYYY-MM');
  final_slug := base_slug || '-' || date_suffix;
  
  -- Check for uniqueness and append counter if needed
  WHILE EXISTS (SELECT 1 FROM public.events WHERE slug = final_slug) LOOP
    final_slug := base_slug || '-' || date_suffix || '-' || counter;
    counter := counter + 1;
  END LOOP;
  
  RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-generate slug before insert
CREATE OR REPLACE FUNCTION public.event_slug_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := public.generate_event_slug(NEW.title, NEW.start_datetime);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_event_slug
  BEFORE INSERT ON public.events
  FOR EACH ROW EXECUTE FUNCTION public.event_slug_trigger();

-- Function: Log event deletion to moderation log
CREATE OR REPLACE FUNCTION public.log_event_deletion()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    INSERT INTO public.event_moderation_log (
      event_id,
      event_title,
      deleted_by,
      reason,
      deleted_at
    ) VALUES (
      NEW.id,
      NEW.title,
      NEW.deleted_by,
      NEW.deletion_reason,
      NEW.deleted_at
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_event_deletion_trigger
  AFTER UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION public.log_event_deletion();

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.events IS 'Global events calendar (tournaments, seminars, sparring sessions, open training)';
COMMENT ON TABLE public.event_moderation_log IS 'Audit trail for admin deletions of events';

COMMENT ON COLUMN public.events.slug IS 'SEO-friendly URL (auto-generated: title-YYYY-MM)';
COMMENT ON COLUMN public.events.start_datetime IS 'Event start time in UTC (convert from timezone)';
COMMENT ON COLUMN public.events.timezone IS 'Original timezone for display purposes';
COMMENT ON COLUMN public.events.disciplines IS 'Array of discipline codes (e.g., [spada_lunga, daga])';
COMMENT ON COLUMN public.events.is_published IS 'Visibility control (unpublished = draft)';
COMMENT ON COLUMN public.events.deleted_at IS 'Soft delete timestamp by admin moderation';
COMMENT ON COLUMN public.events.deletion_reason IS 'Reason for deletion by admin';
