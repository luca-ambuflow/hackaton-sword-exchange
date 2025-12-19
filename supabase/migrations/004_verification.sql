-- =====================================================
-- Migration: 004_verification.sql
-- Description: User verification and society affiliation attestation system
-- Phase: 3 - Verification System
-- =====================================================

-- =====================================================
-- TABLE: society_affiliations
-- Description: User verification and membership attestation
-- =====================================================
CREATE TYPE affiliation_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');

CREATE TABLE public.society_affiliations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,

  -- Status
  status affiliation_status DEFAULT 'pending',

  -- Membership card attestation
  eps TEXT, -- EPS organization code (e.g., 'csen', 'asi', etc.)
  membership_number TEXT,
  membership_expiry_date DATE,

  -- Medical certificate attestation
  certificate_type TEXT CHECK (certificate_type IN ('agonistico', 'non_agonistico')),
  certificate_expiry_date DATE,

  -- Audit trail
  approved_by UUID REFERENCES public.profiles(id), -- Society manager who approved
  approved_at TIMESTAMPTZ,
  attestation_legal_accepted BOOLEAN DEFAULT FALSE, -- User accepted legal disclaimer

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- One affiliation per user per society
  UNIQUE(user_id, society_id)
);

-- =====================================================
-- TABLE: attestation_audit_log
-- Description: Audit trail for attestation changes (legal requirement)
-- =====================================================
CREATE TABLE public.attestation_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  affiliation_id UUID NOT NULL REFERENCES public.society_affiliations(id) ON DELETE CASCADE,
  changed_by UUID NOT NULL REFERENCES public.profiles(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  field_name TEXT NOT NULL, -- Field that was changed
  old_value TEXT, -- Previous value (as string)
  new_value TEXT, -- New value (as string)
  ip_address INET -- IP address of the change
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.society_affiliations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attestation_audit_log ENABLE ROW LEVEL SECURITY;

-- Society Affiliations Policies

-- Users can view their own affiliation
CREATE POLICY "Users can view their own affiliation"
  ON public.society_affiliations FOR SELECT
  USING (user_id = auth.uid());

-- Society managers can view their members
CREATE POLICY "Society managers can view their members"
  ON public.society_affiliations FOR SELECT
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Host society can view affiliation ONLY when active booking exists
-- This is critical for privacy: attestation data is visible only during active bookings
-- Moved to 005_erasmus.sql to avoid forward reference to Erasmus tables

-- Users can request affiliation (insert)
CREATE POLICY "Authenticated users can request affiliation"
  ON public.society_affiliations FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
    AND user_id = auth.uid()
  );

-- Users can update their own pending affiliation
CREATE POLICY "Users can update their pending affiliation"
  ON public.society_affiliations FOR UPDATE
  USING (user_id = auth.uid() AND status = 'pending')
  WITH CHECK (status = 'pending'); -- Cannot change status themselves

-- Society managers can update their members' affiliations
CREATE POLICY "Society managers can update their members"
  ON public.society_affiliations FOR UPDATE
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Attestation Audit Log Policies

-- Society managers can view audit log for their affiliations
CREATE POLICY "Society managers can view audit log for their affiliations"
  ON public.attestation_audit_log FOR SELECT
  USING (
    affiliation_id IN (
      SELECT id FROM public.society_affiliations
      WHERE society_id IN (
        SELECT society_id FROM public.society_administrators
        WHERE user_id = auth.uid()
      )
    )
  );

-- System can insert audit log (via trigger)
CREATE POLICY "System can insert audit log"
  ON public.attestation_audit_log FOR INSERT
  WITH CHECK (true);

-- =====================================================
-- INDEXES (Performance)
-- =====================================================

-- Society Affiliations
CREATE INDEX idx_affiliations_user ON public.society_affiliations(user_id);
CREATE INDEX idx_affiliations_society ON public.society_affiliations(society_id);
CREATE INDEX idx_affiliations_status ON public.society_affiliations(status);
CREATE INDEX idx_affiliations_expiry ON public.society_affiliations(membership_expiry_date, certificate_expiry_date)
  WHERE status = 'approved';

-- Attestation Audit Log
CREATE INDEX idx_attestation_audit_affiliation ON public.attestation_audit_log(affiliation_id);
CREATE INDEX idx_attestation_audit_changed_at ON public.attestation_audit_log(changed_at DESC);
CREATE INDEX idx_attestation_audit_changed_by ON public.attestation_audit_log(changed_by);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Trigger: Update society_affiliations updated_at
CREATE TRIGGER update_society_affiliations_updated_at
  BEFORE UPDATE ON public.society_affiliations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Log attestation changes to audit log
CREATE OR REPLACE FUNCTION public.log_attestation_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Log membership_number changes
  IF OLD.membership_number IS DISTINCT FROM NEW.membership_number THEN
    INSERT INTO public.attestation_audit_log (
      affiliation_id, changed_by, field_name, old_value, new_value
    ) VALUES (
      NEW.id,
      auth.uid(),
      'membership_number',
      OLD.membership_number,
      NEW.membership_number
    );
  END IF;

  -- Log membership_expiry_date changes
  IF OLD.membership_expiry_date IS DISTINCT FROM NEW.membership_expiry_date THEN
    INSERT INTO public.attestation_audit_log (
      affiliation_id, changed_by, field_name, old_value, new_value
    ) VALUES (
      NEW.id,
      auth.uid(),
      'membership_expiry_date',
      OLD.membership_expiry_date::TEXT,
      NEW.membership_expiry_date::TEXT
    );
  END IF;

  -- Log certificate_type changes
  IF OLD.certificate_type IS DISTINCT FROM NEW.certificate_type THEN
    INSERT INTO public.attestation_audit_log (
      affiliation_id, changed_by, field_name, old_value, new_value
    ) VALUES (
      NEW.id,
      auth.uid(),
      'certificate_type',
      OLD.certificate_type,
      NEW.certificate_type
    );
  END IF;

  -- Log certificate_expiry_date changes
  IF OLD.certificate_expiry_date IS DISTINCT FROM NEW.certificate_expiry_date THEN
    INSERT INTO public.attestation_audit_log (
      affiliation_id, changed_by, field_name, old_value, new_value
    ) VALUES (
      NEW.id,
      auth.uid(),
      'certificate_expiry_date',
      OLD.certificate_expiry_date::TEXT,
      NEW.certificate_expiry_date::TEXT
    );
  END IF;

  -- Log status changes
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.attestation_audit_log (
      affiliation_id, changed_by, field_name, old_value, new_value
    ) VALUES (
      NEW.id,
      auth.uid(),
      'status',
      OLD.status::TEXT,
      NEW.status::TEXT
    );

    -- Set approved_by and approved_at when status changes to approved
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
      NEW.approved_by := auth.uid();
      NEW.approved_at := NOW();
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER log_attestation_change_trigger
  BEFORE UPDATE ON public.society_affiliations
  FOR EACH ROW EXECUTE FUNCTION public.log_attestation_change();

-- Function: Check if user has valid verification
CREATE OR REPLACE FUNCTION public.user_is_verified(user_id_param UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.society_affiliations
    WHERE user_id = user_id_param
      AND status = 'approved'
      AND membership_expiry_date > CURRENT_DATE
      AND certificate_expiry_date > CURRENT_DATE
  );
END;
$$ LANGUAGE plpgsql;

-- Function: Get user verification status with details
CREATE OR REPLACE FUNCTION public.get_user_verification_status(user_id_param UUID)
RETURNS TABLE (
  is_verified BOOLEAN,
  society_name TEXT,
  membership_expiry DATE,
  certificate_expiry DATE,
  days_until_expiry INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (sa.status = 'approved'
     AND sa.membership_expiry_date > CURRENT_DATE
     AND sa.certificate_expiry_date > CURRENT_DATE) AS is_verified,
    s.ragione_sociale AS society_name,
    sa.membership_expiry_date AS membership_expiry,
    sa.certificate_expiry_date AS certificate_expiry,
    LEAST(
      sa.membership_expiry_date - CURRENT_DATE,
      sa.certificate_expiry_date - CURRENT_DATE
    ) AS days_until_expiry
  FROM public.society_affiliations sa
  JOIN public.societies s ON sa.society_id = s.id
  WHERE sa.user_id = user_id_param
    AND sa.status = 'approved'
  ORDER BY days_until_expiry ASC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.society_affiliations IS 'User verification and society membership attestation system';
COMMENT ON TABLE public.attestation_audit_log IS 'Audit trail for attestation changes (legal requirement for liability)';

COMMENT ON COLUMN public.society_affiliations.eps IS 'EPS organization code (e.g., csen, asi, aics)';
COMMENT ON COLUMN public.society_affiliations.membership_number IS 'Membership card number';
COMMENT ON COLUMN public.society_affiliations.membership_expiry_date IS 'Membership card expiry date';
COMMENT ON COLUMN public.society_affiliations.certificate_type IS 'Medical certificate type (agonistico/non_agonistico)';
COMMENT ON COLUMN public.society_affiliations.certificate_expiry_date IS 'Medical certificate expiry date';
COMMENT ON COLUMN public.society_affiliations.attestation_legal_accepted IS 'User accepted legal disclaimer about attestation responsibility';

COMMENT ON COLUMN public.attestation_audit_log.field_name IS 'Name of the field that was changed';
COMMENT ON COLUMN public.attestation_audit_log.old_value IS 'Previous value (stored as text)';
COMMENT ON COLUMN public.attestation_audit_log.new_value IS 'New value (stored as text)';
