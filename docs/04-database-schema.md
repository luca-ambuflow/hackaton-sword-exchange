# Database Schema

## Overview

PostgreSQL database hosted on Supabase with focus on:
- **Row Level Security (RLS)** for data protection
- **Indexes** optimized for SEO and performance
- **Audit trails** for sensitive operations
- **Soft deletes** for data retention
- **UUIDs** for primary keys

---

## Entity Relationship Diagram

```
┌─────────────────┐
│   auth.users    │ (Supabase managed)
│  (built-in)     │
└────────┬────────┘
         │
         │ 1:1
         ↓
┌─────────────────┐         ┌──────────────────┐
│    profiles     │←────────│   user_roles     │
│                 │  1:many │                  │
└────────┬────────┘         └──────────────────┘
         │
         │ 1:many
         ↓
┌─────────────────────────────────────────────┐
│  society_affiliations (verification)        │
└────────┬────────────────────────────────────┘
         │
         │ many:1
         ↓
┌─────────────────┐         ┌───────────────────────┐
│   societies     │←────────│ society_administrators│
│                 │  1:many │                       │
└────────┬────────┘         └───────────────────────┘
         │
         │ 1:1
         ↓
┌─────────────────┐
│erasmus_programs │
│                 │
└────────┬────────┘
         │
         │ 1:many
         ↓
┌─────────────────┐         ┌──────────────────┐
│ erasmus_slots   │←────────│erasmus_bookings  │
│                 │  1:many │                  │
└─────────────────┘         └──────────────────┘


┌─────────────────┐
│     events      │
│                 │
└─────────────────┘
         │
         │ many:1
         ↓
┌─────────────────┐
│   societies     │ (optional)
│                 │
└─────────────────┘
```

---

## Core Tables

### 1. profiles

Extends Supabase `auth.users` with application-specific user data.

```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  preferred_language TEXT DEFAULT 'it' CHECK (preferred_language IN ('it', 'en', 'de')),
  timezone TEXT DEFAULT 'Europe/Rome',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Indexes
CREATE INDEX idx_profiles_email ON public.profiles(email);
```

**Fields**:
- `id`: UUID (references auth.users)
- `email`: User email (duplicated for convenience)
- `full_name`: User's full name
- `preferred_language`: UI language preference (it/en/de)
- `timezone`: User's timezone for event display
- `created_at`, `updated_at`: Timestamps

---

### 2. user_roles

Role-based access control. Users can have multiple roles.

```sql
CREATE TYPE user_role AS ENUM ('user', 'society_manager', 'platform_admin');

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

-- RLS Policies
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX idx_user_roles_role ON public.user_roles(role);
```

**Roles**:
- `user`: Default role for registered users
- `society_manager`: Can manage a society
- `platform_admin`: Full admin access

---

### 3. user_consents

Track privacy and terms consents (GDPR compliance).

```sql
CREATE TABLE public.user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  consent_type TEXT NOT NULL, -- 'privacy', 'erasmus_terms'
  granted BOOLEAN DEFAULT FALSE,
  granted_at TIMESTAMPTZ,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, consent_type)
);

-- RLS Policies
ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own consents"
  ON public.user_consents FOR SELECT
  USING (auth.uid() = user_id);
```

---

### 4. societies

Society/school directory.

```sql
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
  disciplines TEXT, -- Free text
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

-- RLS Policies
ALTER TABLE public.societies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Societies are viewable by everyone"
  ON public.societies FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "Society admins can update their society"
  ON public.societies FOR UPDATE
  USING (
    id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Indexes for SEO and filtering
CREATE INDEX idx_societies_slug ON public.societies(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_region_province ON public.societies(region, province) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_verified ON public.societies(is_verified) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_created_at ON public.societies(created_at DESC) WHERE deleted_at IS NULL;

-- Full-text search
CREATE INDEX idx_societies_search ON public.societies
  USING GIN(to_tsvector('italian', ragione_sociale || ' ' || COALESCE(description, '')));
```

---

### 5. society_administrators

Many-to-many relationship between users and societies.

```sql
CREATE TABLE public.society_administrators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'admin', -- Future: 'owner', 'admin', 'editor'
  approved_by UUID REFERENCES public.profiles(id), -- Platform admin
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(society_id, user_id)
);

-- RLS Policies
ALTER TABLE public.society_administrators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Society admins can view their own admin records"
  ON public.society_administrators FOR SELECT
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_society_administrators_society ON public.society_administrators(society_id);
CREATE INDEX idx_society_administrators_user ON public.society_administrators(user_id);
```

---

### 6. events

Global events calendar.

```sql
CREATE TYPE event_type AS ENUM ('gara', 'sparring', 'seminario', 'allenamento_aperto');

CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL, -- SEO-friendly URL

  -- Core fields
  title TEXT NOT NULL,
  description TEXT,
  event_type event_type NOT NULL,
  external_link TEXT,

  -- Date/time (UTC storage + original timezone)
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ,
  timezone TEXT NOT NULL DEFAULT 'Europe/Rome',

  -- Location (text-based)
  region TEXT,
  province TEXT,
  city TEXT,
  location_name TEXT,
  address TEXT,

  -- Organizer
  creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID REFERENCES public.societies(id) ON DELETE SET NULL, -- Optional

  -- Disciplines (array of codes)
  disciplines TEXT[], -- ['spada_lunga', 'daga', ...]

  -- Moderation
  is_published BOOLEAN DEFAULT TRUE,
  deleted_at TIMESTAMPTZ,
  deleted_by UUID REFERENCES public.profiles(id),
  deletion_reason TEXT,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published events are viewable by everyone"
  ON public.events FOR SELECT
  USING (deleted_at IS NULL AND is_published = TRUE);

CREATE POLICY "Authenticated users can create events"
  ON public.events FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Event creator can update their event"
  ON public.events FOR UPDATE
  USING (creator_id = auth.uid());

CREATE POLICY "Platform admins can soft delete events"
  ON public.events FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Indexes for SEO and filtering
CREATE INDEX idx_events_slug ON public.events(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_events_start_datetime ON public.events(start_datetime DESC)
  WHERE deleted_at IS NULL AND is_published = TRUE;
CREATE INDEX idx_events_region_province ON public.events(region, province)
  WHERE deleted_at IS NULL AND is_published = TRUE;
CREATE INDEX idx_events_society_id ON public.events(society_id)
  WHERE deleted_at IS NULL;
CREATE INDEX idx_events_type ON public.events(event_type)
  WHERE deleted_at IS NULL AND is_published = TRUE;
CREATE INDEX idx_events_disciplines ON public.events USING GIN(disciplines)
  WHERE deleted_at IS NULL;

-- Full-text search
CREATE INDEX idx_events_search ON public.events
  USING GIN(to_tsvector('italian', title || ' ' || COALESCE(description, '')));
```

---

### 7. event_moderation_log

Audit trail for event deletions.

```sql
CREATE TABLE public.event_moderation_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL, -- Not FK (event might be deleted)
  deleted_by UUID NOT NULL REFERENCES public.profiles(id),
  reason TEXT NOT NULL,
  deleted_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.event_moderation_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Platform admins can view moderation log"
  ON public.event_moderation_log FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Index
CREATE INDEX idx_event_moderation_log_event_id ON public.event_moderation_log(event_id);
CREATE INDEX idx_event_moderation_log_deleted_at ON public.event_moderation_log(deleted_at DESC);
```

---

### 8. erasmus_programs

Erasmus program configuration per society.

```sql
CREATE TABLE public.erasmus_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  society_id UUID NOT NULL UNIQUE REFERENCES public.societies(id) ON DELETE CASCADE,

  -- Program settings
  description TEXT,
  general_rules TEXT,
  required_certificate_type TEXT CHECK (required_certificate_type IN ('any', 'agonistico', 'non_agonistico')),

  -- Booking settings
  auto_confirm BOOLEAN DEFAULT FALSE,
  general_capacity INTEGER DEFAULT 10,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.erasmus_programs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Erasmus programs are viewable by everyone"
  ON public.erasmus_programs FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Society admins can manage their program"
  ON public.erasmus_programs FOR ALL
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Index
CREATE INDEX idx_erasmus_programs_society ON public.erasmus_programs(society_id);
```

---

### 9. erasmus_slots

Individual training slots for Erasmus program.

```sql
CREATE TABLE public.erasmus_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.erasmus_programs(id) ON DELETE CASCADE,

  -- Date/time
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,
  timezone TEXT NOT NULL DEFAULT 'Europe/Rome',

  -- Status
  is_available BOOLEAN DEFAULT TRUE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.erasmus_slots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Available slots are viewable by everyone"
  ON public.erasmus_slots FOR SELECT
  USING (is_available = TRUE);

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

-- Indexes
CREATE INDEX idx_erasmus_slots_program ON public.erasmus_slots(program_id);
CREATE INDEX idx_erasmus_slots_datetime ON public.erasmus_slots(start_datetime, end_datetime)
  WHERE is_available = TRUE;
```

---

### 10. erasmus_bookings

Booking requests for Erasmus slots.

```sql
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'rejected', 'cancelled');

CREATE TABLE public.erasmus_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id UUID NOT NULL REFERENCES public.erasmus_slots(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Status
  status booking_status DEFAULT 'pending',
  rejection_reason TEXT,

  -- Waitlist (when capacity full)
  waitlist BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ,
  UNIQUE(slot_id, user_id)
);

-- RLS Policies
ALTER TABLE public.erasmus_bookings ENABLE ROW LEVEL SECURITY;

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

CREATE POLICY "Verified users can create bookings"
  ON public.erasmus_bookings FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.society_affiliations
      WHERE user_id = auth.uid()
        AND status = 'approved'
        AND membership_expiry_date > CURRENT_DATE
        AND certificate_expiry_date > CURRENT_DATE
    )
  );

-- Indexes
CREATE INDEX idx_erasmus_bookings_user ON public.erasmus_bookings(user_id);
CREATE INDEX idx_erasmus_bookings_slot ON public.erasmus_bookings(slot_id);
CREATE INDEX idx_erasmus_bookings_status ON public.erasmus_bookings(status);
```

---

### 11. society_affiliations

User verification and membership attestation.

```sql
CREATE TYPE affiliation_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');

CREATE TABLE public.society_affiliations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,

  -- Status
  status affiliation_status DEFAULT 'pending',

  -- Membership card attestation
  eps TEXT, -- EPS organization
  membership_number TEXT,
  membership_expiry_date DATE,

  -- Medical certificate attestation
  certificate_type TEXT CHECK (certificate_type IN ('agonistico', 'non_agonistico')),
  certificate_expiry_date DATE,

  -- Audit trail
  approved_by UUID REFERENCES public.profiles(id),
  approved_at TIMESTAMPTZ,
  attestation_legal_accepted BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id, society_id)
);

-- RLS Policies
ALTER TABLE public.society_affiliations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own affiliation"
  ON public.society_affiliations FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Society managers can view their members"
  ON public.society_affiliations FOR SELECT
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- IMPORTANT: Host society can see affiliation ONLY when active booking exists
CREATE POLICY "Host society can view affiliation when booking exists"
  ON public.society_affiliations FOR SELECT
  USING (
    user_id IN (
      SELECT eb.user_id FROM public.erasmus_bookings eb
      JOIN public.erasmus_slots es ON eb.slot_id = es.id
      JOIN public.erasmus_programs ep ON es.program_id = ep.id
      JOIN public.society_administrators sa ON ep.society_id = sa.society_id
      WHERE sa.user_id = auth.uid() AND eb.status IN ('confirmed', 'pending')
    )
  );

CREATE POLICY "Society managers can update their members"
  ON public.society_affiliations FOR UPDATE
  USING (
    society_id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

-- Indexes
CREATE INDEX idx_affiliations_user ON public.society_affiliations(user_id);
CREATE INDEX idx_affiliations_society ON public.society_affiliations(society_id);
CREATE INDEX idx_affiliations_status ON public.society_affiliations(status);
```

---

### 12. attestation_audit_log

Audit trail for attestation changes.

```sql
CREATE TABLE public.attestation_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  affiliation_id UUID NOT NULL REFERENCES public.society_affiliations(id) ON DELETE CASCADE,
  changed_by UUID NOT NULL REFERENCES public.profiles(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  field_name TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  ip_address INET
);

-- RLS Policies
ALTER TABLE public.attestation_audit_log ENABLE ROW LEVEL SECURITY;

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

-- Index
CREATE INDEX idx_attestation_audit_affiliation ON public.attestation_audit_log(affiliation_id);
CREATE INDEX idx_attestation_audit_changed_at ON public.attestation_audit_log(changed_at DESC);
```

---

### 13. society_manager_requests

Approval queue for society manager requests.

```sql
CREATE TABLE public.society_manager_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  notes TEXT,
  reviewed_by UUID REFERENCES public.profiles(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.society_manager_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own requests"
  ON public.society_manager_requests FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Platform admins can view all requests"
  ON public.society_manager_requests FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'platform_admin'
    )
  );

-- Index
CREATE INDEX idx_manager_requests_status ON public.society_manager_requests(status);
CREATE INDEX idx_manager_requests_created ON public.society_manager_requests(created_at DESC);
```

---

## Reference Data Tables

### 14. eps_organizations

Predefined list of EPS organizations.

```sql
CREATE TABLE public.eps_organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  country TEXT DEFAULT 'IT',
  is_active BOOLEAN DEFAULT TRUE
);

-- Seed data
INSERT INTO public.eps_organizations (code, name) VALUES
  ('csen', 'CSEN - Centro Sportivo Educativo Nazionale'),
  ('asi', 'ASI - Associazioni Sportive e Sociali Italiane'),
  ('aics', 'AICS - Associazione Italiana Cultura Sport'),
  ('msp', 'MSP Italia - Movimento Sportivo Popolare'),
  ('uisp', 'UISP - Unione Italiana Sport Per tutti'),
  ('csi', 'CSI - Centro Sportivo Italiano'),
  ('other', 'Altro');

-- No RLS needed (public reference data)
```

---

### 15. italian_regions

Italian regions and provinces for filters.

```sql
CREATE TABLE public.italian_regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region_code TEXT NOT NULL,
  region_name TEXT NOT NULL,
  province_code TEXT,
  province_name TEXT
);

-- Seed data (sample)
INSERT INTO public.italian_regions (region_code, region_name, province_code, province_name) VALUES
  ('LAZ', 'Lazio', 'RM', 'Roma'),
  ('LAZ', 'Lazio', 'LT', 'Latina'),
  ('LAZ', 'Lazio', 'FR', 'Frosinone'),
  ('LAZ', 'Lazio', 'VT', 'Viterbo'),
  ('LAZ', 'Lazio', 'RI', 'Rieti'),
  ('LOM', 'Lombardia', 'MI', 'Milano'),
  ('LOM', 'Lombardia', 'BG', 'Bergamo'),
  -- ... (complete list)
  ;

-- No RLS needed (public reference data)
```

---

### 16. disciplines

Predefined disciplines/weapons for event filtering.

```sql
CREATE TABLE public.disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name_it TEXT NOT NULL,
  name_en TEXT,
  name_de TEXT,
  category TEXT,
  is_active BOOLEAN DEFAULT TRUE
);

-- Seed data
INSERT INTO public.disciplines (code, name_it, name_en, name_de, category) VALUES
  ('spada_lunga', 'Spada Lunga', 'Longsword', 'Langschwert', 'sword'),
  ('spada_lato', 'Spada da Lato', 'Side Sword', 'Seitenschwert', 'sword'),
  ('spadone', 'Spadone', 'Greatsword', 'Großschwert', 'sword'),
  ('daga', 'Daga', 'Dagger', 'Dolch', 'dagger'),
  ('spada_boccoliere', 'Spada e Brocchiere', 'Sword & Buckler', 'Schwert & Buckler', 'sword'),
  ('rapier', 'Striscia/Rapier', 'Rapier', 'Rapier', 'sword'),
  ('lotta', 'Lotta/Wrestling', 'Wrestling', 'Ringen', 'grappling'),
  ('mixed', 'Misto', 'Mixed', 'Gemischt', 'mixed'),
  ('other', 'Altro', 'Other', 'Andere', 'other');

-- No RLS needed (public reference data)
```

---

## Database Functions & Triggers

### Auto-update `updated_at` timestamp

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_societies_updated_at
  BEFORE UPDATE ON public.societies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at
  BEFORE UPDATE ON public.events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ... (apply to other tables)
```

---

### Auto-create profile on user signup

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');

  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Migrations Strategy

### Migration Files

Store migrations in `/supabase/migrations/`:

- `001_initial_schema.sql` - Core tables (profiles, user_roles, consents)
- `002_societies.sql` - Societies and administrators
- `003_events.sql` - Events and moderation log
- `004_erasmus.sql` - Erasmus programs, slots, bookings
- `005_verification.sql` - Affiliations and audit log
- `006_admin.sql` - Society manager requests
- `007_reference_data.sql` - EPS, regions, disciplines
- `008_indexes_seo.sql` - Additional indexes for SEO
- `009_rls_policies.sql` - Row Level Security policies
- `010_functions_triggers.sql` - Database functions and triggers

---

## Query Examples

### Get upcoming events in region

```sql
SELECT
  e.id,
  e.slug,
  e.title,
  e.event_type,
  e.start_datetime,
  e.city,
  s.ragione_sociale AS society_name
FROM public.events e
LEFT JOIN public.societies s ON e.society_id = s.id
WHERE e.region = 'Lazio'
  AND e.start_datetime > NOW()
  AND e.deleted_at IS NULL
  AND e.is_published = TRUE
ORDER BY e.start_datetime ASC
LIMIT 20;
```

### Check user verification status

```sql
SELECT
  sa.status,
  sa.membership_expiry_date,
  sa.certificate_expiry_date,
  CASE
    WHEN sa.status = 'approved'
      AND sa.membership_expiry_date > CURRENT_DATE
      AND sa.certificate_expiry_date > CURRENT_DATE
    THEN 'verified'
    WHEN sa.membership_expiry_date <= CURRENT_DATE
      OR sa.certificate_expiry_date <= CURRENT_DATE
    THEN 'suspended'
    ELSE 'not_verified'
  END AS verification_status
FROM public.society_affiliations sa
WHERE sa.user_id = 'user-uuid-here';
```

### Get available Erasmus slots with capacity check

```sql
SELECT
  es.id,
  es.start_datetime,
  es.end_datetime,
  ep.general_capacity,
  COUNT(eb.id) FILTER (WHERE eb.status = 'confirmed') AS confirmed_bookings,
  (ep.general_capacity - COUNT(eb.id) FILTER (WHERE eb.status = 'confirmed')) AS available_slots
FROM public.erasmus_slots es
JOIN public.erasmus_programs ep ON es.program_id = ep.id
LEFT JOIN public.erasmus_bookings eb ON es.id = eb.slot_id
WHERE es.is_available = TRUE
  AND es.start_datetime > NOW()
GROUP BY es.id, ep.general_capacity
HAVING COUNT(eb.id) FILTER (WHERE eb.status = 'confirmed') < ep.general_capacity
ORDER BY es.start_datetime ASC;
```

---

## Backup & Recovery

### Automated Backups (Supabase)

- Daily automatic backups (7-day retention)
- Point-in-time recovery available
- Manual backup export via Supabase dashboard

### Manual Backup

```bash
# Export full database
pg_dump -h db.xxx.supabase.co -U postgres > backup.sql

# Export specific table
pg_dump -h db.xxx.supabase.co -U postgres -t public.events > events_backup.sql
```

---

## Monitoring

### Metrics to Track

- **Table sizes**: Monitor growth (stay under 500MB free tier)
- **Query performance**: Identify slow queries
- **RLS overhead**: Ensure policies are efficient
- **Index usage**: Verify indexes are being used

### Supabase Dashboard

- Database size
- Active connections
- Query statistics
- Slow query log

---

## Summary

The database schema provides:

1. **Security**: RLS policies on all tables
2. **Auditability**: Comprehensive audit trails
3. **Performance**: Strategic indexes for common queries
4. **SEO**: Full-text search and slug-based lookups
5. **Privacy**: Granular data visibility controls
6. **Scalability**: Efficient queries and pagination support
