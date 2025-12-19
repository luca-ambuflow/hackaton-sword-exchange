-- =====================================================
-- Migration: 012_enable_unaccent.sql
-- Description: Enable unaccent extension for accent-insensitive text processing
-- =====================================================

-- Enable the unaccent extension
-- This extension provides the unaccent() function used in generate_event_slug()
CREATE EXTENSION IF NOT EXISTS unaccent;
