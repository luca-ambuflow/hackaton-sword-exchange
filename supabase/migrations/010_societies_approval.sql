-- =====================================================
-- Migration: 010_societies_approval.sql
-- Description: Add approval flag for societies requiring admin approval
-- =====================================================

-- =====================================================
-- ALTER TABLE: societies
-- Add approved flag (separate from is_verified)
-- =====================================================
ALTER TABLE public.societies
ADD COLUMN approved BOOLEAN DEFAULT FALSE,
ADD COLUMN approved_by UUID REFERENCES public.profiles(id),
ADD COLUMN approved_at TIMESTAMPTZ;

-- Create index for filtering approved societies
CREATE INDEX idx_societies_approved ON public.societies(approved) WHERE deleted_at IS NULL;

-- =====================================================
-- UPDATE RLS POLICIES
-- =====================================================

-- Drop old policy for viewing societies
DROP POLICY IF EXISTS "Societies are viewable by everyone" ON public.societies;

-- New policy: Only approved societies are viewable by everyone
CREATE POLICY "Approved societies are viewable by everyone"
  ON public.societies FOR SELECT
  USING (deleted_at IS NULL AND approved = TRUE);

-- Platform admins can view all societies (including unapproved)
CREATE POLICY "Platform admins can view all societies"
  ON public.societies FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Society admins can view their own society even if not approved
CREATE POLICY "Society admins can view their own society"
  ON public.societies FOR SELECT
  USING (
    id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Platform admins can approve societies
CREATE POLICY "Platform admins can approve societies"
  ON public.societies FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function: Approve a society
CREATE OR REPLACE FUNCTION public.approve_society(
  society_id_param UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  admin_id UUID;
BEGIN
  -- Get current user ID
  admin_id := auth.uid();

  -- Check if user is platform admin
  IF NOT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = admin_id AND role = 'platform_admin'
  ) THEN
    RAISE EXCEPTION 'Only platform admins can approve societies';
  END IF;

  -- Update society
  UPDATE public.societies
  SET
    approved = TRUE,
    approved_by = admin_id,
    approved_at = NOW()
  WHERE id = society_id_param;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Reject/unapprove a society
CREATE OR REPLACE FUNCTION public.unapprove_society(
  society_id_param UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  admin_id UUID;
BEGIN
  -- Get current user ID
  admin_id := auth.uid();

  -- Check if user is platform admin
  IF NOT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = admin_id AND role = 'platform_admin'
  ) THEN
    RAISE EXCEPTION 'Only platform admins can unapprove societies';
  END IF;

  -- Update society
  UPDATE public.societies
  SET
    approved = FALSE,
    approved_by = NULL,
    approved_at = NULL
  WHERE id = society_id_param;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VIEWS
-- =====================================================

-- View: Pending society approvals
CREATE OR REPLACE VIEW public.pending_society_approvals AS
SELECT
  s.id,
  s.slug,
  s.ragione_sociale,
  s.codice_fiscale,
  s.city,
  s.region,
  s.email,
  s.website,
  s.created_at,
  p.email AS creator_email,
  p.full_name AS creator_name
FROM public.societies s
LEFT JOIN public.society_administrators sa ON s.id = sa.society_id
LEFT JOIN public.profiles p ON sa.user_id = p.id
WHERE s.approved = FALSE AND s.deleted_at IS NULL
ORDER BY s.created_at ASC;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON COLUMN public.societies.approved IS 'Whether society has been approved by platform admin (required for public visibility)';
COMMENT ON COLUMN public.societies.approved_by IS 'Platform admin who approved the society';
COMMENT ON COLUMN public.societies.approved_at IS 'Timestamp when society was approved';
COMMENT ON VIEW public.pending_society_approvals IS 'Societies awaiting admin approval';
