-- =====================================================
-- Migration: 009_auto_add_society_creator_as_admin.sql
-- Description: Add created_by column and automatically add society creator as admin
-- Phase: 1 - Society Directory
-- =====================================================

-- Add created_by column to societies table
ALTER TABLE public.societies
  ADD COLUMN created_by UUID REFERENCES public.profiles(id);

-- Create index for created_by lookups
CREATE INDEX idx_societies_created_by ON public.societies(created_by)
  WHERE created_by IS NOT NULL;

-- Add comment
COMMENT ON COLUMN public.societies.created_by IS 'User who created this society';

-- Function: Auto-add creator as society administrator
CREATE OR REPLACE FUNCTION public.auto_add_society_creator_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert the creator as an administrator of the newly created society
  INSERT INTO public.society_administrators (
    society_id,
    user_id,
    role,
    approved_by,
    approved_at
  ) VALUES (
    NEW.id,
    NEW.created_by,
    'admin',
    NEW.created_by, -- Self-approved as creator
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Add creator as admin after society insert
CREATE TRIGGER add_society_creator_as_admin
  AFTER INSERT ON public.societies
  FOR EACH ROW
  WHEN (NEW.created_by IS NOT NULL)
  EXECUTE FUNCTION public.auto_add_society_creator_as_admin();

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON FUNCTION public.auto_add_society_creator_as_admin() IS 'Automatically adds the society creator as an administrator when a new society is created';
