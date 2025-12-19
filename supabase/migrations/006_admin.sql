-- =====================================================
-- Migration: 006_admin.sql
-- Description: Society manager requests and admin approval queue
-- Phase: 5 - Admin Features
-- =====================================================

-- =====================================================
-- TABLE: society_manager_requests
-- Description: Approval queue for society manager requests
-- =====================================================
CREATE TABLE public.society_manager_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
  
  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  
  -- Request details
  notes TEXT, -- User's explanation/justification
  
  -- Review details
  reviewed_by UUID REFERENCES public.profiles(id), -- Platform admin who reviewed
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT, -- Reason if rejected
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- One pending request per user per society
  UNIQUE(user_id, society_id)
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.society_manager_requests ENABLE ROW LEVEL SECURITY;

-- Society Manager Requests Policies

-- Users can view their own requests
CREATE POLICY "Users can view their own requests"
  ON public.society_manager_requests FOR SELECT
  USING (user_id = auth.uid());

-- Platform admins can view all requests
CREATE POLICY "Platform admins can view all requests"
  ON public.society_manager_requests FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Authenticated users can create requests
CREATE POLICY "Authenticated users can create requests"
  ON public.society_manager_requests FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' 
    AND user_id = auth.uid()
  );

-- Platform admins can update requests (approve/reject)
CREATE POLICY "Platform admins can update requests"
  ON public.society_manager_requests FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- =====================================================
-- INDEXES (Performance)
-- =====================================================

CREATE INDEX idx_manager_requests_status ON public.society_manager_requests(status);
CREATE INDEX idx_manager_requests_created ON public.society_manager_requests(created_at DESC);
CREATE INDEX idx_manager_requests_user ON public.society_manager_requests(user_id);
CREATE INDEX idx_manager_requests_society ON public.society_manager_requests(society_id);
CREATE INDEX idx_manager_requests_reviewed_by ON public.society_manager_requests(reviewed_by)
  WHERE reviewed_by IS NOT NULL;

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function: Auto-approve manager and assign role when request is approved
CREATE OR REPLACE FUNCTION public.handle_manager_request_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Only process when status changes from pending to approved
  IF OLD.status = 'pending' AND NEW.status = 'approved' THEN
    -- Set reviewed metadata
    NEW.reviewed_by := auth.uid();
    NEW.reviewed_at := NOW();
    
    -- Add user as society administrator
    INSERT INTO public.society_administrators (
      society_id,
      user_id,
      approved_by,
      approved_at
    ) VALUES (
      NEW.society_id,
      NEW.user_id,
      auth.uid(),
      NOW()
    )
    ON CONFLICT (society_id, user_id) DO NOTHING;
    
    -- Grant society_manager role if not already present
    INSERT INTO public.user_roles (user_id, role)
    VALUES (NEW.user_id, 'society_manager')
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;
  
  -- Set reviewed metadata for rejections
  IF OLD.status = 'pending' AND NEW.status = 'rejected' THEN
    NEW.reviewed_by := auth.uid();
    NEW.reviewed_at := NOW();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER handle_manager_request_approval_trigger
  BEFORE UPDATE ON public.society_manager_requests
  FOR EACH ROW EXECUTE FUNCTION public.handle_manager_request_approval();

-- Function: Check if user can request manager role for a society
CREATE OR REPLACE FUNCTION public.can_request_manager_role(
  user_id_param UUID,
  society_id_param UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if user already has a pending request
  IF EXISTS (
    SELECT 1 FROM public.society_manager_requests
    WHERE user_id = user_id_param
      AND society_id = society_id_param
      AND status = 'pending'
  ) THEN
    RETURN FALSE;
  END IF;
  
  -- Check if user is already a manager of this society
  IF EXISTS (
    SELECT 1 FROM public.society_administrators
    WHERE user_id = user_id_param
      AND society_id = society_id_param
  ) THEN
    RETURN FALSE;
  END IF;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS (Convenience)
-- =====================================================

-- View: Pending manager requests with user and society details
CREATE OR REPLACE VIEW public.pending_manager_requests AS
SELECT
  smr.id,
  smr.user_id,
  smr.society_id,
  smr.notes,
  smr.created_at,
  p.email AS user_email,
  p.full_name AS user_name,
  s.ragione_sociale AS society_name,
  s.city AS society_city,
  s.region AS society_region
FROM public.society_manager_requests smr
JOIN public.profiles p ON smr.user_id = p.id
JOIN public.societies s ON smr.society_id = s.id
WHERE smr.status = 'pending'
ORDER BY smr.created_at ASC;

-- Grant select permission on view to platform admins
-- Note: RLS still applies via the underlying tables

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.society_manager_requests IS 'Approval queue for users requesting to become society managers';
COMMENT ON VIEW public.pending_manager_requests IS 'Convenience view for platform admins showing pending manager requests with details';

COMMENT ON COLUMN public.society_manager_requests.status IS 'Request status: pending (awaiting review), approved, rejected';
COMMENT ON COLUMN public.society_manager_requests.notes IS 'User explanation for why they should be granted manager role';
COMMENT ON COLUMN public.society_manager_requests.reviewed_by IS 'Platform admin who reviewed the request';
COMMENT ON COLUMN public.society_manager_requests.rejection_reason IS 'Admin explanation if request was rejected';
