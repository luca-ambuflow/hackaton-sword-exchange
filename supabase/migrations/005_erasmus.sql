-- =====================================================
-- Migration: 005_erasmus.sql
-- Description: Erasmus program with slots and bookings management
-- Phase: 4 - Erasmus Program
-- =====================================================

-- =====================================================
-- TABLE: erasmus_programs
-- Description: Erasmus program configuration per society
-- =====================================================
CREATE TABLE public.erasmus_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  society_id UUID NOT NULL UNIQUE REFERENCES public.societies(id) ON DELETE CASCADE,

  -- Program settings
  description TEXT,
  general_rules TEXT, -- Program-specific rules
  required_certificate_type TEXT CHECK (required_certificate_type IN ('any', 'agonistico', 'non_agonistico')),

  -- Booking settings
  auto_confirm BOOLEAN DEFAULT FALSE, -- Auto-confirm bookings or require manual approval
  general_capacity INTEGER DEFAULT 10, -- Default capacity for all slots

  -- Status
  is_active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: erasmus_slots
-- Description: Individual training slots for Erasmus program
-- =====================================================
CREATE TABLE public.erasmus_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.erasmus_programs(id) ON DELETE CASCADE,

  -- Date/time (UTC storage + original timezone)
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,
  timezone TEXT NOT NULL DEFAULT 'Europe/Rome',

  -- Capacity override (NULL = use program default)
  capacity_override INTEGER,

  -- Status
  is_available BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraint: end_datetime must be after start_datetime
  CONSTRAINT valid_slot_times CHECK (end_datetime > start_datetime)
);

-- =====================================================
-- TABLE: erasmus_bookings
-- Description: Booking requests for Erasmus slots
-- =====================================================
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'rejected', 'cancelled');

CREATE TABLE public.erasmus_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id UUID NOT NULL REFERENCES public.erasmus_slots(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Status
  status booking_status DEFAULT 'pending',
  rejection_reason TEXT, -- Reason if rejected

  -- Waitlist (when capacity is full)
  waitlist BOOLEAN DEFAULT FALSE,
  waitlist_position INTEGER,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ,

  -- One booking per user per slot
  UNIQUE(slot_id, user_id)
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE public.erasmus_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.erasmus_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.erasmus_bookings ENABLE ROW LEVEL SECURITY;

-- Erasmus Programs Policies
CREATE POLICY "Active programs are viewable by everyone"
  ON public.erasmus_programs FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Society admins can view their program"
  ON public.erasmus_programs FOR SELECT
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Society admins can manage their program"
  ON public.erasmus_programs FOR ALL
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Erasmus Slots Policies
CREATE POLICY "Available slots are viewable by everyone"
  ON public.erasmus_slots FOR SELECT
  USING (
    is_available = TRUE
    AND program_id IN (
      SELECT id FROM public.erasmus_programs WHERE is_active = TRUE
    )
  );

CREATE POLICY "Society admins can view their slots"
  ON public.erasmus_slots FOR SELECT
  USING (
    program_id IN (
      SELECT id FROM public.erasmus_programs
      WHERE society_id IN (
        SELECT society_id FROM public.society_administrators
        WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Society admins can manage their slots"
  ON public.erasmus_slots FOR ALL
  USING (
    program_id IN (
      SELECT id FROM public.erasmus_programs
      WHERE society_id IN (
        SELECT society_id FROM public.society_administrators
        WHERE user_id = auth.uid()
      )
    )
  );

-- Erasmus Bookings Policies
CREATE POLICY "Users can view their own bookings"
  ON public.erasmus_bookings FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Society admins can view bookings for their slots"
  ON public.erasmus_bookings FOR SELECT
  USING (
    slot_id IN (
      SELECT es.id FROM public.erasmus_slots es
      JOIN public.erasmus_programs ep ON es.program_id = ep.id
      JOIN public.society_administrators sa ON ep.society_id = sa.society_id
      WHERE sa.user_id = auth.uid()
    )
  );

-- Cross-module policy: allow host society to view attestation during active bookings
-- This policy targets public.society_affiliations but depends on Erasmus tables,
-- so it is created here after those tables exist.
CREATE POLICY "Host society can view affiliation when booking exists"
  ON public.society_affiliations FOR SELECT
  USING (
    user_id IN (
      SELECT eb.user_id FROM public.erasmus_bookings eb
      JOIN public.erasmus_slots es ON eb.slot_id = es.id
      JOIN public.erasmus_programs ep ON es.program_id = ep.id
      JOIN public.society_administrators sa ON ep.society_id = sa.society_id
      WHERE sa.user_id = auth.uid()
        AND eb.status IN ('confirmed', 'pending')
        AND es.start_datetime >= NOW() - INTERVAL '7 days' -- Active within 7 days
    )
  );

CREATE POLICY "Verified users can create bookings"
  ON public.erasmus_bookings FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.society_affiliations
      WHERE user_id = auth.uid()
        AND status = 'approved'
        AND membership_expiry_date > CURRENT_DATE
        AND certificate_expiry_date > CURRENT_DATE
    )
  );

CREATE POLICY "Users can cancel their own bookings"
  ON public.erasmus_bookings FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (status = 'cancelled');

CREATE POLICY "Society admins can update booking status"
  ON public.erasmus_bookings FOR UPDATE
  USING (
    slot_id IN (
      SELECT es.id FROM public.erasmus_slots es
      JOIN public.erasmus_programs ep ON es.program_id = ep.id
      JOIN public.society_administrators sa ON ep.society_id = sa.society_id
      WHERE sa.user_id = auth.uid()
    )
  );

-- =====================================================
-- INDEXES (Performance)
-- =====================================================

-- Erasmus Programs
CREATE INDEX idx_erasmus_programs_society ON public.erasmus_programs(society_id);
CREATE INDEX idx_erasmus_programs_active ON public.erasmus_programs(is_active);

-- Erasmus Slots
CREATE INDEX idx_erasmus_slots_program ON public.erasmus_slots(program_id);
CREATE INDEX idx_erasmus_slots_datetime ON public.erasmus_slots(start_datetime, end_datetime)
  WHERE is_available = TRUE;
CREATE INDEX idx_erasmus_slots_available ON public.erasmus_slots(is_available);

-- Erasmus Bookings
CREATE INDEX idx_erasmus_bookings_user ON public.erasmus_bookings(user_id);
CREATE INDEX idx_erasmus_bookings_slot ON public.erasmus_bookings(slot_id);
CREATE INDEX idx_erasmus_bookings_status ON public.erasmus_bookings(status);
CREATE INDEX idx_erasmus_bookings_waitlist ON public.erasmus_bookings(waitlist, waitlist_position)
  WHERE waitlist = TRUE;

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Trigger: Update erasmus_programs updated_at
CREATE TRIGGER update_erasmus_programs_updated_at
  BEFORE UPDATE ON public.erasmus_programs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Update erasmus_slots updated_at
CREATE TRIGGER update_erasmus_slots_updated_at
  BEFORE UPDATE ON public.erasmus_slots
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Update erasmus_bookings updated_at
CREATE TRIGGER update_erasmus_bookings_updated_at
  BEFORE UPDATE ON public.erasmus_bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Get slot capacity (with override logic)
CREATE OR REPLACE FUNCTION public.get_slot_capacity(slot_id UUID)
RETURNS INTEGER AS $$
DECLARE
  slot_capacity INTEGER;
  program_capacity INTEGER;
BEGIN
  SELECT es.capacity_override, ep.general_capacity
  INTO slot_capacity, program_capacity
  FROM public.erasmus_slots es
  JOIN public.erasmus_programs ep ON es.program_id = ep.id
  WHERE es.id = slot_id;

  RETURN COALESCE(slot_capacity, program_capacity);
END;
$$ LANGUAGE plpgsql;

-- Function: Get confirmed bookings count for a slot
CREATE OR REPLACE FUNCTION public.get_confirmed_bookings_count(slot_id UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM public.erasmus_bookings
    WHERE erasmus_bookings.slot_id = get_confirmed_bookings_count.slot_id
      AND status = 'confirmed'
  );
END;
$$ LANGUAGE plpgsql;

-- Function: Check if slot has available capacity
CREATE OR REPLACE FUNCTION public.slot_has_capacity(slot_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  capacity INTEGER;
  confirmed INTEGER;
BEGIN
  capacity := public.get_slot_capacity(slot_id);
  confirmed := public.get_confirmed_bookings_count(slot_id);

  RETURN confirmed < capacity;
END;
$$ LANGUAGE plpgsql;

-- Function: Auto-confirm booking if auto_confirm is enabled
CREATE OR REPLACE FUNCTION public.auto_confirm_booking()
RETURNS TRIGGER AS $$
DECLARE
  auto_confirm_enabled BOOLEAN;
  has_capacity BOOLEAN;
BEGIN
  -- Check if auto_confirm is enabled for this program
  SELECT ep.auto_confirm
  INTO auto_confirm_enabled
  FROM public.erasmus_slots es
  JOIN public.erasmus_programs ep ON es.program_id = ep.id
  WHERE es.id = NEW.slot_id;

  -- Check if slot has capacity
  has_capacity := public.slot_has_capacity(NEW.slot_id);

  IF auto_confirm_enabled AND has_capacity THEN
    NEW.status := 'confirmed';
    NEW.confirmed_at := NOW();
  ELSIF NOT has_capacity THEN
    -- Add to waitlist
    NEW.waitlist := TRUE;
    NEW.waitlist_position := (
      SELECT COALESCE(MAX(waitlist_position), 0) + 1
      FROM public.erasmus_bookings
      WHERE slot_id = NEW.slot_id AND waitlist = TRUE
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_confirm_booking_trigger
  BEFORE INSERT ON public.erasmus_bookings
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_booking();

-- =====================================================
-- COMMENTS (Documentation)
-- =====================================================

COMMENT ON TABLE public.erasmus_programs IS 'Erasmus program configuration (one per society)';
COMMENT ON TABLE public.erasmus_slots IS 'Individual training slots available for booking';
COMMENT ON TABLE public.erasmus_bookings IS 'User bookings for Erasmus slots';

COMMENT ON COLUMN public.erasmus_programs.auto_confirm IS 'Automatically confirm bookings (true) or require manual approval (false)';
COMMENT ON COLUMN public.erasmus_programs.general_capacity IS 'Default capacity for all slots (can be overridden per slot)';
COMMENT ON COLUMN public.erasmus_programs.required_certificate_type IS 'Required medical certificate type (any/agonistico/non_agonistico)';

COMMENT ON COLUMN public.erasmus_slots.capacity_override IS 'Override general_capacity for this specific slot (NULL = use program default)';
COMMENT ON COLUMN public.erasmus_bookings.waitlist IS 'True if booking is on waitlist (capacity full)';
COMMENT ON COLUMN public.erasmus_bookings.waitlist_position IS 'Position in waitlist queue';
