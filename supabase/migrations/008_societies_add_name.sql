-- =====================================================
-- Migration: 008_societies_add_name.sql
-- Description: Add display name column to societies and backfill
-- Phase: 1 - Society Directory
-- =====================================================

-- Add the new column as nullable first to avoid failures on existing rows
ALTER TABLE public.societies
  ADD COLUMN name TEXT;

-- Backfill from existing official name field
UPDATE public.societies
SET name = COALESCE(name, ragione_sociale);

-- Enforce NOT NULL after data is populated
ALTER TABLE public.societies
  ALTER COLUMN name SET NOT NULL;

-- Optional: a simple index can help case-insensitive searches if needed later
-- CREATE INDEX IF NOT EXISTS idx_societies_name ON public.societies(name);

-- Documentation
COMMENT ON COLUMN public.societies.name IS 'Display name of the society (human-friendly); initially backfilled from ragione_sociale';
