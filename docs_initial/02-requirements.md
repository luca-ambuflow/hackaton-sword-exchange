# Requirements

## Project Vision

Create a centralized web portal for the Historical Fencing (Scherma Storica) community, starting in Italy and expanding to Europe and beyond. The platform addresses the fragmented ecosystem of small, uncoordinated fencing societies by providing:

1. A unified **directory** of associations and schools
2. A **global events calendar** with minimal friction for event creation
3. An **exchange Program** for cross-society training visits with safety guarantees

### Success Criteria

The product must **self-sustaining through network effects**: more events → more traffic → more incentive to post events.

**Priority**: Minimal friction in event creation (no pre-approval required).

---

## User Roles & Permissions

### 1. Visitor (Not Logged In)

**Access**:
- Browse society directory (public)
- Browse events calendar (public)
- View society detail pages
- View event detail pages
- View exchange program landing page

**Cannot**:
- Create events
- Book exchange slots
- Request society affiliation

---

### 2. Registered User (Person)

**Access**:
- All Visitor permissions
- **Create events** (immediately published, no approval)
- Request affiliation to a society
- View own verification status

**Once Verified** (by society):
- Book exchange training slots
- View own membership card/certificate details

**Cannot** (until verified):
- Participate in exchange program

**States**:
- **Not Verified** (default after registration)
- **Verified** (society approved + valid docs)
- **Suspended** (expired membership card or medical certificate)

---

### 3. Society Manager (Admin of Society)

**Access**:
- All Registered User permissions
- Manage society profile (edit details, logo)
- **Approve/reject** user affiliation requests
- **Attest** membership cards and medical certificates
- Manage society administrators (add/remove)
- Configure **exchange Program** settings
- Create/manage **exchange slots**
- Approve/reject exchange booking requests
- View member verification status

**Responsibilities**:
- Verify user credentials
- Keep attestations up to date
- Manage exchange capacity and bookings
- Maintain society profile accuracy

**Approval Required**:
- Society managers must be **manually approved** by platform admin

---

### 4. Platform Admin

**Access**:
- All permissions
- **Delete events** quickly (with reason)
- View moderation queue
- **Approve** society manager requests (manual review)
- View audit logs

**Responsibilities**:
- Content moderation
- Abuse prevention
- Society manager validation
- System maintenance

---

## Functional Requirements

### Module 1: Society Directory

#### Purpose
Public directory of Historical Fencing associations, schools, and societies.

#### Required Fields
- **Ragione sociale** (official name) - Required
- **Codice fiscale** (tax code) - Required, unique
- **Sede** (headquarters location) - Required
- **At least 1 administrator** - Required

#### Optional Fields
- Partita IVA (VAT number)
- Contact information (phone, email)
- Website URL
- Disciplines practiced (free text or link to website)
- General description

#### Deferred Fields (Not in MVP)
- Training schedule (difficult to keep updated)
- GPS coordinates (no map in MVP)

#### Features

**List View**:
- Display all societies as cards/list
- Filters:
  - Region (Italian regions)
  - Province (province codes)
  - Search by name (full-text search)
- Pagination
- SEO-optimized URLs (`/societies/[slug]`)

**Detail View**:
- Society information
- Contact details
- Associated events (upcoming)
- exchange Program status (if active)
- **SEO Critical**: Indexable, structured data (Organization schema)

**Management** (Society Managers):
- Edit society profile
- Upload logo
- Update contact information
- Manage administrators

#### User Experience
- **MVP**: Simple list view with filters
- **Future**: Map view with clustering

---

### Module 2: Global Events Calendar

#### Purpose
Unified calendar for all Historical Fencing events with **minimal friction** for creation.

#### Event Creation
- **Who can create**: Any registered user
- **Approval required**: NO (events published immediately)
- **Association**: Events can be independent OR linked to a society

#### Event Types (Enum)
- **Gara** (Competition)
- **Sparring** (Sparring session)
- **Seminario** (Seminar/Workshop)
- **Allenamento Aperto** (Open Training)

#### Event Fields (MVP)

**Required**:
- Title
- Event type (enum)
- Date and time (start)
- Location (city, province, region)
- Short description
- External link (for full details/registration)

**Optional**:
- End date/time
- Organizer (society association)
- Disciplines/weapons (multi-select from enum)

**Deferred** (Not in MVP):
- Event cost
- Event regulations
- Participant capacity
- Registration/participant list

#### Disciplines/Weapons (Enum)

Predefined list for filtering (especially competitions):
- Spada Lunga (Longsword)
- Spada da Lato (Side Sword)
- Spadone (Greatsword)
- Daga (Dagger)
- Spada e Brocchiere (Sword & Buckler)
- Striscia/Rapier (Rapier)
- Lotta/Wrestling (Wrestling)
- Misto (Mixed)
- Altro (Other)

Multiple selection allowed per event.

#### Event Filters

**MVP Filters**:
- Date range
- Region
- Province
- Event type
- Organizer (society)
- Discipline/weapon (for competitions)

**Deferred**:
- Distance (km) filter - requires geocoding

#### Quick Event Creation

**Priority Feature**: Minimize time to create event

- **Duplicate event**: Copy previous event, update dates
- **Templates**: Save event templates for recurring events
- **Minimal form**: Only essential fields required

#### Moderation

**Admin Powers**:
- Quick delete events (button on calendar view)
- Deletion requires reason (text input)
- Deletion logged (event ID, reason, admin, timestamp)

**Deletion Notification**:
- **MVP**: In-app notification (reason logged, visible to creator)
- **Future**: Email notification

**User Reporting**:
- **MVP**: No "report event" button
- **Future**: User-flagging system for spam

#### Timezone Handling

**Critical Requirement**: Proper timezone support

**Storage**:
- Store datetime in UTC (PostgreSQL TIMESTAMPTZ)
- Store original timezone in separate column

**Display**:
- Default: Show in user's detected timezone
- Show original timezone in parentheses for clarity
- Example: "19:00 CET (20:00 EET original)"

**User Experience**:
- Auto-detect user timezone (browser API)
- Allow manual timezone selection in event creation form

#### SEO Requirements

**Critical**: Events must be easily discoverable via search

- SEO-friendly URLs: `/events/torneo-spada-lunga-roma-2025-12`
- Dynamic metadata (title, description, keywords)
- Structured data (Event schema.org)
- Fast page loads (SSR)
- Mobile-friendly
- Sitemap inclusion (recent events only)

---

### Module 3: exchange Program

#### Purpose
Enable cross-society training visits with verification of participant credentials (membership card, medical certificate).

#### Concept
Societies host training sessions for visitors from other clubs, similar to exchange student exchange programs.

#### Program Structure (Society Level)

Each society has **one exchange Program** with shared settings:

**Program Settings**:
- Program description ("What to expect")
- General rules
- Medical certificate requirement:
  - Any certificate accepted
  - Agonistico only
  - Non-agonistico only
- Confirmation mode:
  - **Auto-confirm** (instant booking)
  - **Manual approval** (society reviews each request)

**Not Supported in MVP**:
- Multi-location societies (single location assumed)

#### Slots

**Slot Definition**:
- Date
- Start time
- End time
- Timezone

**Bulk Generation**:
- Create slots from recurrence pattern
- Example: "Every Thursday 19:00-21:00 from Sept 2025 to June 2026"
- Exclude specific dates (holidays, breaks)
- Add individual slots manually

**Slot Management**:
- Enable/disable individual slots
- Delete slots
- Edit slot times

#### Capacity Management

**MVP**: General capacity for entire society (not per-slot)

**Behavior**:
- Count active bookings across all slots
- When at capacity:
  - Show "Request Anyway" option
  - Create booking with waitlist flag
  - Society can manually approve/reject
  - Society can explicitly reject with reason

#### Booking Flow

**Requirements to Book**:
- User must be **verified** (approved by their society)
- User must have **valid membership card** (not expired)
- User must have **valid medical certificate** (not expired, correct type)

**Booking Process**:
1. User browses available slots
2. User selects slot
3. System checks verification status
4. If auto-confirm enabled: Booking confirmed immediately
5. If manual approval: Booking pending, society reviews
6. Society approves/rejects with reason

**Rejection**:
- Society provides text reason for rejection
- User sees reason in booking status

#### Data Visibility (Privacy)

**Critical**: Membership card and medical certificate data is private

**Visibility Rules**:
- User sees own data (always)
- User's home society sees data (for members they manage)
- Host society sees data **only when active booking exists**
- **Never** displayed publicly
- **Never** displayed on user profile page

#### Verification System

**Affiliation Request**:
1. User selects society to join
2. User requests affiliation
3. Society manager reviews request
4. Society manager approves/rejects

**Attestation** (Society Manager):
- **EPS** (Ente di Promozione Sportiva) - Dropdown with autocomplete + "Altro"
- Membership card number
- Membership card expiry date
- Medical certificate type: Agonistico / Non-agonistico
- Medical certificate expiry date

**Legal Declaration**:
- Society must accept checkbox confirming data is truthful
- Attestation logged with audit trail (who, when, IP)

**Audit Trail**:
- Track which society manager attested
- Track when attestation was made
- Track changes to attestations (old value → new value)

**Multi-Affiliation**:
- **MVP**: Single affiliation only (user can belong to one society)
- **Future**: Multi-affiliation support

**Changing Society**:
- User can request affiliation to different society
- Previous affiliation remains until new one approved
- User is "not verified" during transition

#### States

**User Verification States**:
- **Not Verified**: Default, cannot use exchange
- **Verified**: Society approved, valid docs, can book exchange
- **Suspended**: Expired card or certificate, exchange blocked

**Auto-Suspension**:
- When membership card expires → Suspended
- When medical certificate expires → Suspended
- Society must update attestation to re-verify

---

## Non-Functional Requirements

### 1. Internationalization (i18n)

**Requirement**: Multi-language support from day 1

**Languages (MVP)**:
- **Italian (IT)** - Primary language
- **English (EN)** - International audience
- **German (DE)** - Central European HEMA community

**Implementation**:
- All strings translatable (no hardcoded text)
- Locale-specific URLs: `/it/events`, `/en/events`, `/de/events`
- Language switcher in header
- Locale stored in user preferences (optional)
- SEO: Hreflang tags for all locales

---

### 2. SEO Optimization

**Requirement**: Critical for discoverability

**Target Search Terms**:
- "eventi scherma storica"
- "scherma storica [city]"
- "torneo spada lunga"
- "[society name]"

**Implementation**:
- All public pages SSR (Server-Side Rendered)
- SEO-friendly URLs (slugs, no IDs)
- Dynamic metadata (title, description, keywords)
- Structured data (JSON-LD):
  - Events: schema.org/Event
  - Societies: schema.org/Organization
  - Breadcrumbs: schema.org/BreadcrumbList
- OpenGraph tags (social sharing)
- Dynamic sitemap (all events, societies, in all locales)
- Fast page loads (<3s, Core Web Vitals)
- Mobile-responsive
- Canonical URLs
- Robots.txt configuration

---

### 3. Timezone Handling

**Requirement**: Accurate timezone support for international events

**Storage**:
- UTC in database (TIMESTAMPTZ)
- Original timezone stored separately

**Display**:
- User's detected timezone (browser API)
- Original timezone shown for context
- Clear labeling of timezones

**Edge Cases**:
- Daylight saving time transitions
- Cross-timezone bookings
- Multi-timezone event listings

---

### 4. Free Tier Sustainability

**Requirement**: Stay within free hosting limits

**Vercel Free Tier**:
- 100GB bandwidth/month
- 100 hours serverless execution/month

**Supabase Free Tier**:
- 500MB database storage
- 50,000 monthly active users
- 2GB bandwidth/month

**Mitigation Strategies**:
- Image optimization (Next.js Image, compression)
- Efficient database queries (indexes, pagination)
- Soft deletes (archive old events after 6 months)
- Cleanup old exchange slots (delete after 1 year)
- Monitor dashboards regularly
- Implement caching where appropriate

---

### 5. Privacy & Consent

**Requirement**: GDPR-compliant data handling

**Consents Required**:
- Privacy policy (registration)
- exchange program terms (before first booking)

**Data Protection**:
- Membership card/certificate data is private
- Row-level security (RLS) in database
- No document uploads/scans (attestation only)
- Audit trails for sensitive operations

**User Rights**:
- View own data
- Delete account (future)
- Export data (future)

---

### 6. Performance

**Requirements**:
- Page load <3 seconds (Core Web Vitals)
- Time to Interactive <5 seconds
- Mobile-responsive (100% mobile score)
- Lighthouse score >90

**Optimizations**:
- SSR for critical pages
- Image optimization
- Code splitting
- Lazy loading
- Database query optimization
- CDN for static assets

---

### 7. Security

**Requirements**:
- Role-based access control (RBAC)
- Row-level security (RLS) in database
- Input validation (prevent XSS, SQL injection)
- CSRF protection
- Secure session management
- HTTPS only

**Audit Trails**:
- Event deletions (who, when, why)
- Attestations (who, when, changes)
- Society manager approvals

---

## Feature Priority Matrix

### Phase 0 (Foundation)
- Project setup
- Authentication
- Base layouts
- i18n configuration

### Phase 1 (MVP - Core Value)
- Society directory (list, detail, filters)
- Events calendar (create, list, filters)
- Quick event creation (duplicate, templates)
- Admin event moderation

### Phase 2 (MVP - Differentiation)
- Verification system (affiliation, attestation)
- exchange program (settings, slots, bookings)

### Phase 3 (Post-MVP)
- Distance filter (requires geocoding)
- Email notifications
- User reporting system
- Advanced analytics
- Gamification (badges, points)

---

## Out of Scope (Not in MVP)

### Events Module
- Event registration/ticketing
- Participant lists
- Event capacity limits
- Event cost/pricing
- Detailed regulations
- Event photos/gallery

### Society Directory
- Maps/coordinates display
- Training schedules
- Instructor profiles
- Detailed discipline breakdown

### exchange Program
- Feedback/reviews for visits
- Multi-location societies
- Multi-affiliation users
- exchange badges/gamification

### General Features
- Real-time notifications
- Chat/messaging
- Forums/discussions
- User profiles (beyond basic)
- Social features (likes, comments)
- Mobile app
- ICS calendar export
- Email digest subscriptions
- Analytics dashboard for societies

---

## User Stories

### Visitor
- As a visitor, I want to browse events so I can find competitions near me
- As a visitor, I want to search for societies so I can find a club to join
- As a visitor, I want to see event details so I can decide whether to attend

### Registered User
- As a user, I want to create an event quickly so I can promote my seminar
- As a user, I want to duplicate previous events so I can save time creating recurring events
- As a user, I want to request affiliation to a society so I can participate in exchange
- As a user, I want to view my verification status so I know if I can book exchange slots

### Verified User
- As a verified user, I want to browse exchange slots so I can train with other societies
- As a verified user, I want to book an exchange slot so I can visit another club
- As a verified user, I want to see my booking status so I know if I'm confirmed

### Society Manager
- As a society manager, I want to approve affiliation requests so I can build my member roster
- As a society manager, I want to attest membership cards so members can use exchange
- As a society manager, I want to configure my exchange program so visitors know what to expect
- As a society manager, I want to create recurring exchange slots so I don't have to create each one manually
- As a society manager, I want to approve/reject booking requests so I can manage capacity

### Platform Admin
- As an admin, I want to delete spam events quickly so the calendar stays clean
- As an admin, I want to approve society manager requests so only legitimate managers have access
- As an admin, I want to view audit logs so I can monitor system usage

---

## Success Metrics

### Engagement
- Number of events created per month
- Number of societies registered
- Number of exchange bookings per month
- Number of active users (monthly)

### Growth
- Events growth rate (month-over-month)
- User registration growth
- Geographic expansion (events outside Italy)

### Quality
- Event deletion rate (spam indicator)
- Verification completion rate
- exchange booking approval rate

### Technical
- Page load time (avg)
- Lighthouse score
- Free tier usage (% of limits)
- Error rate

---

## Constraints

1. **Budget**: Must use free tiers only (Vercel, Supabase)
2. **Timeline**: Phased rollout over 10 weeks
3. **Resources**: Small team, optimize for development speed
4. **Scope**: MVP first, iterate based on user feedback
5. **Technology**: Modern stack for long-term maintainability

---

## Acceptance Criteria

### Society Directory
- [ ] Public list of societies visible to all
- [ ] Filters work (region, province, search)
- [ ] Society detail pages are SEO-optimized
- [ ] Society managers can edit their society profile

### Events Calendar
- [ ] Any registered user can create an event
- [ ] Events are published immediately (no approval)
- [ ] Calendar view displays events clearly
- [ ] Filters work (date, region, type, discipline)
- [ ] Event detail pages are SEO-optimized
- [ ] Quick duplicate function works

### exchange Program
- [ ] Society managers can configure their exchange program
- [ ] Bulk slot generation from recurrence works
- [ ] Verified users can book slots
- [ ] Capacity management works (auto-block when full)
- [ ] Booking approval flow works (auto/manual)
- [ ] Membership/certificate data is private (only visible to authorized users)

### Verification System
- [ ] Users can request affiliation
- [ ] Society managers can approve affiliation
- [ ] Society managers can attest documents
- [ ] Attestations are logged in audit trail
- [ ] Expired documents auto-suspend verification

### Admin Tools
- [ ] Admins can delete events with reason
- [ ] Admins can approve society manager requests
- [ ] Audit logs are accessible

### SEO & Performance
- [ ] All public pages are SSR
- [ ] Sitemap includes all entities in all locales
- [ ] Structured data is present on all entity pages
- [ ] Page load time <3 seconds
- [ ] Lighthouse score >90
