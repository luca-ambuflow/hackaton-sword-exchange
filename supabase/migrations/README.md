# Database Migrations

This directory contains SQL migration files for the Historical Fencing Portal database schema.

## Overview

The database schema is split into 7 migration files, organized by feature and phase:

| Migration | Description | Phase | Priority |
|-----------|-------------|-------|----------|
| `001_initial_schema.sql` | Core auth tables (profiles, user_roles, consents) | Phase 0 | **REQUIRED** |
| `002_societies.sql` | Society directory and administrators | Phase 1 | **REQUIRED** |
| `003_events.sql` | Events calendar and moderation | Phase 2 | REQUIRED |
| `004_erasmus.sql` | Erasmus program, slots, bookings | Phase 4 | REQUIRED |
| `005_verification.sql` | User verification and attestation | Phase 3 | REQUIRED |
| `006_admin.sql` | Society manager approval queue | Phase 5 | REQUIRED |
| `007_reference_data.sql` | Reference data (EPS, regions, disciplines) | All | REQUIRED |

## Running Migrations

### Option 1: Supabase Dashboard (Recommended for Development)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run each migration file **in order** (001 → 007)
4. Copy and paste the contents of each file
5. Click **Run** to execute

**Important:** Run migrations in numerical order. Later migrations depend on earlier ones.

### Option 2: Supabase CLI

If you have the Supabase CLI installed:

```bash
# Initialize Supabase locally (if not already done)
supabase init

# Link to your remote project
supabase link --project-ref your-project-ref

# Push all migrations
supabase db push

# Or push individually
supabase db push --file supabase/migrations/001_initial_schema.sql
```

### Option 3: Direct PostgreSQL Connection

```bash
# Connect to your Supabase database
psql "postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres"

# Run each migration
\i supabase/migrations/001_initial_schema.sql
\i supabase/migrations/002_societies.sql
# ... etc.
```

## Migration Details

### 001_initial_schema.sql
**Phase 0 - Foundation**

Creates core authentication and user management tables:
- `profiles` - User profiles extending auth.users
- `user_roles` - Role-based access control (RBAC)
- `user_consents` - GDPR consent tracking

**Key Features:**
- Auto-creates profile on user signup (trigger)
- Auto-assigns 'user' role on registration
- Row Level Security (RLS) on all tables

### 002_societies.sql
**Phase 1 - Society Directory**

Creates society directory and management tables:
- `societies` - Society/school directory
- `society_administrators` - Many-to-many user-society relationship

**Key Features:**
- Auto-generates SEO-friendly slugs
- Full-text search (Italian language)
- Soft delete support
- Location-based filtering (region, province, city)

### 003_events.sql
**Phase 2 - Events Calendar**

Creates events calendar and moderation system:
- `events` - Global events calendar
- `event_moderation_log` - Audit trail for admin deletions

**Key Features:**
- Support for 4 event types (gara, sparring, seminario, allenamento_aperto)
- Timezone-aware dates (UTC storage + display timezone)
- Discipline tagging (array field)
- Platform admin moderation (soft delete)
- Auto-generates slugs with date suffix

### 004_verification.sql
**Phase 3 - Verification System**

Creates user verification and attestation system:
- `society_affiliations` - User membership attestation
- `attestation_audit_log` - Audit trail for attestation changes

**Key Features:**
- EPS membership card attestation
- Medical certificate attestation
- Privacy-first: attestation visible only to home society and hosts with active bookings
- Complete audit trail for legal compliance
- Auto-expire logic based on dates

### 005_erasmus.sql
**Phase 4 - Erasmus Program**

Creates Erasmus training exchange program:
- `erasmus_programs` - Program configuration per society
- `erasmus_slots` - Individual training slots
- `erasmus_bookings` - User booking requests

**Key Features:**
- Auto-confirm or manual approval modes
- Capacity management with waitlist support
- Requires verified users (checks society_affiliations)
- Host society can only see attestation during active bookings

### 006_admin.sql
**Phase 5 - Admin Features**

Creates admin approval queue for society managers:
- `society_manager_requests` - Approval queue
- `pending_manager_requests` - Convenience view

**Key Features:**
- Users request to become society managers
- Platform admins approve/reject
- Auto-grants society_manager role on approval
- Auto-creates society_administrator record

### 007_reference_data.sql
**All Phases - Reference Data**

Creates and seeds reference data tables:
- `eps_organizations` - Italian EPS organizations (8 organizations + "other")
- `italian_regions` - All Italian regions and provinces (110+ entries)
- `disciplines` - Historical fencing disciplines (20+ disciplines)

**Key Features:**
- Pre-seeded with real data
- Multilingual support (IT/EN/DE)
- Used for dropdowns and filters throughout the application

## Schema Summary

### Tables Created (17 total)

**Core:**
- profiles
- user_roles
- user_consents

**Societies:**
- societies
- society_administrators
- society_manager_requests

**Events:**
- events
- event_moderation_log

**Erasmus:**
- erasmus_programs
- erasmus_slots
- erasmus_bookings

**Verification:**
- society_affiliations
- attestation_audit_log

**Reference:**
- eps_organizations
- italian_regions
- disciplines

### Custom Types (3 total)
- `user_role` - user, society_manager, platform_admin
- `event_type` - gara, sparring, seminario, allenamento_aperto
- `affiliation_status` - pending, approved, rejected, suspended
- `booking_status` - pending, confirmed, rejected, cancelled

### Functions & Triggers
- `update_updated_at_column()` - Auto-update updated_at timestamps
- `handle_new_user()` - Auto-create profile and role on signup
- `generate_society_slug()` - Auto-generate SEO slugs for societies
- `generate_event_slug()` - Auto-generate SEO slugs for events
- `log_event_deletion()` - Log event deletions to moderation log
- `auto_confirm_booking()` - Auto-confirm Erasmus bookings
- `log_attestation_change()` - Audit attestation changes
- `handle_manager_request_approval()` - Process manager approvals

### Indexes
All tables have appropriate indexes for:
- Primary key lookups
- Foreign key relationships
- Common filters (region, province, date ranges)
- Full-text search (GIN indexes)
- SEO (slug lookups)

## Row Level Security (RLS)

All tables have RLS enabled with policies for:
- **Public access:** Events, societies, erasmus programs (published/active only)
- **User access:** Own profile, roles, consents, bookings, affiliations
- **Society manager access:** Their society's data, members, erasmus slots
- **Platform admin access:** All data, moderation capabilities

## Testing Migrations

After running migrations, verify with these queries:

```sql
-- Check tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Check reference data loaded
SELECT COUNT(*) FROM public.eps_organizations;      -- Should be 9
SELECT COUNT(*) FROM public.italian_regions;        -- Should be 110+
SELECT COUNT(*) FROM public.disciplines;            -- Should be 20+

-- Test trigger by creating a user
-- (Profile and user_role should be auto-created)
```

## Rollback

Supabase does not support automatic rollback. To rollback:

1. **Backup first:** Export your database before making changes
2. **Drop tables manually:** Run DROP TABLE statements in reverse order
3. **Restore from backup:** Use Supabase dashboard to restore

Example rollback (reverse order):

```sql
-- Drop in reverse order of dependencies
DROP TABLE IF EXISTS public.attestation_audit_log CASCADE;
DROP TABLE IF EXISTS public.society_affiliations CASCADE;
DROP TABLE IF EXISTS public.erasmus_bookings CASCADE;
DROP TABLE IF EXISTS public.erasmus_slots CASCADE;
DROP TABLE IF EXISTS public.erasmus_programs CASCADE;
DROP TABLE IF EXISTS public.event_moderation_log CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.society_manager_requests CASCADE;
DROP TABLE IF EXISTS public.society_administrators CASCADE;
DROP TABLE IF EXISTS public.societies CASCADE;
DROP TABLE IF EXISTS public.user_consents CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Drop reference tables
DROP TABLE IF EXISTS public.disciplines CASCADE;
DROP TABLE IF EXISTS public.italian_regions CASCADE;
DROP TABLE IF EXISTS public.eps_organizations CASCADE;

-- Drop custom types
DROP TYPE IF EXISTS booking_status CASCADE;
DROP TYPE IF EXISTS affiliation_status CASCADE;
DROP TYPE IF EXISTS event_type CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;
```

## Next Steps

After running migrations:

1. ✅ Verify all tables created successfully
2. ✅ Check reference data loaded (EPS, regions, disciplines)
3. ✅ Test user registration (profile auto-creation)
4. Create your first platform admin user (manually update user_roles)
5. Start building application features in phases

## Support

For issues or questions:
- Check Supabase logs in dashboard
- Review `/docs/04-database-schema.md` for detailed schema documentation
- Review `/docs/06-phases.md` for implementation order

## Version History

- **v1.0.0** - Initial schema (7 migrations)
  - Phase 0-5 complete database structure
  - All core features supported
  - Production-ready with RLS
