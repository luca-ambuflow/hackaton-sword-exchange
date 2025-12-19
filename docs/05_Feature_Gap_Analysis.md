# FEATURE GAP ANALYSIS

**Version**: 1.0  
**Date**: December 19, 2025  
**Purpose**: Identify what's implemented vs what needs to be built

---

## EXISTING IMPLEMENTATION (Based on Migrations & Code Review)

### ✅ Database Schema - IMPLEMENTED

#### Foundation (Migration 001)
- ✅ User profiles with email, full_name, language, timezone
- ✅ User roles (user, society_manager, platform_admin)
- ✅ User consents tracking (privacy, terms, erasmus_terms)

#### Societies (Migration 002, 008, 009, 010)
- ✅ Society directory with basic fields (ragione_sociale, codice_fiscale, sede)
- ✅ Society administrators (many-to-many)
- ✅ Society approval workflow (approved, approved_by, approved_at)
- ✅ Auto-add society creator as admin (Migration 009)
- ✅ Slug generation for SEO
- ✅ Soft delete support
- ❌ **MISSING: Coordinates (latitude, longitude) for distance filtering**
- ❌ **MISSING: Logo generation/upload functionality**

#### Events (Migration 003)
- ✅ Events calendar with types (gara, sparring, seminario, allenamento_aperto)
- ✅ Event moderation (soft delete, deletion reason)
- ✅ Timezone support
- ✅ Disciplines array
- ❌ **MISSING: Coordinates for events**
- ❌ **MISSING: Weapons field**
- ❌ **MISSING: Event duplication feature**

#### Verification (Migration 004)
- ✅ Society affiliations with status (pending, approved, rejected, suspended)
- ✅ EPS, membership card, certificate attestation
- ✅ Attestation audit log
- ✅ Expiry date tracking
- ✅ Privacy-aware RLS policies

#### Exchange Program (Migration 005)
- ✅ Exchange programs per society
- ✅ Exchange slots with capacity
- ✅ Exchange bookings with status
- ✅ Auto-confirm vs manual approval
- ❌ **MISSING: Waitlist functionality**
- ❌ **MISSING: Attendance confirmation**
- ❌ **MISSING: Badge generation**

#### Admin (Migration 006, 011)
- ✅ Admin role management
- ✅ Event moderation log
- ✅ Society approval functions

### ✅ Application Pages - IMPLEMENTED

#### Public Pages
- ✅ Home page
- ✅ Societies directory (`/societies`)
- ✅ Society detail page (`/societies/[slug]`)
- ✅ Events calendar (`/events`)
- ✅ Sign up / Sign in pages

#### Protected Pages
- ✅ Account page
- ✅ Create society page (`/societies/new`)

#### Admin Pages
- ✅ Admin dashboard
- ✅ Society approvals page (`/admin/societies`)
- ✅ User management page (`/admin/users`)

---

## MISSING FEATURES BY PRIORITY

### 🔴 HIGH PRIORITY - Core MVP Features

#### 1. Coordinates & Distance Filtering
- **Database**: Add `latitude`, `longitude` to societies and events tables
- **UI**: Add coordinate input fields with warnings
- **Feature**: Distance-based filtering for societies and events
- **User Stories**: US-1.2, US-2.2, US-9.1, US-9.2

#### 2. Event Management - Complete Implementation
- **Database**: Add `weapons` field to events
- **UI**: Event creation form (currently missing)
- **UI**: Event editing page
- **UI**: Event duplication feature
- **Feature**: Prevent unverified users from creating events
- **User Stories**: US-3.4, US-3.5, US-3.6, US-3.7, US-3.8

#### 3. User Profile System
- **Database**: Add profile photo, bio fields to profiles
- **UI**: Profile page (public and private views)
- **UI**: Profile photo upload
- **Feature**: Display badges and achievements
- **User Stories**: US-5.1, US-5.2, US-5.3, US-5.4, US-5.5, US-5.8

#### 4. Exchange Program - Public Pages
- **UI**: Exchange landing page
- **UI**: Exchange program listing with filters
- **UI**: Exchange program detail page
- **UI**: Available slots view
- **UI**: Booking interface
- **Feature**: Terms acceptance before first booking
- **User Stories**: US-4.1, US-4.2, US-4.3, US-4.4, US-4.5

#### 5. Exchange Program - User Features
- **Database**: Add waitlist support to bookings
- **Database**: Add attendance confirmation
- **Database**: Add badges table
- **UI**: My bookings page
- **UI**: Exchange history
- **UI**: Cancel booking
- **Feature**: Badge generation after confirmed attendance
- **User Stories**: US-4.6, US-4.7, US-4.8, US-4.9, US-4.10, US-4.11, US-4.12

#### 6. Society Backoffice - Complete Implementation
- **UI**: Society backoffice dashboard
- **UI**: Society profile editor with coordinate warnings
- **UI**: Logo upload
- **UI**: Pending affiliations view
- **UI**: Approve/reject affiliations
- **UI**: User verification form with attestation
- **UI**: Affiliated users list with filters
- **User Stories**: US-9.1, US-9.2, US-9.3, US-9.4, US-11.1, US-11.2, US-11.3, US-11.4, US-11.5, US-11.7

#### 7. Society Backoffice - Exchange Management
- **UI**: Exchange program configuration
- **UI**: Create individual slots
- **UI**: Generate recurring slots
- **UI**: Edit/delete slots
- **UI**: View bookings
- **UI**: Approve/reject bookings (manual mode)
- **UI**: Confirm attendance
- **UI**: Handle waitlist requests
- **User Stories**: US-12.1, US-12.2, US-13.1, US-13.2, US-13.3, US-13.4, US-13.5, US-14.1, US-14.2, US-14.3, US-14.4, US-14.5

#### 8. Email Notifications
- **Feature**: Event deletion notification
- **Feature**: Booking confirmation/rejection
- **Feature**: Booking cancellation notification
- **Feature**: Slot change notification
- **Feature**: Society approval notification
- **Feature**: Manager approval notification
- **User Stories**: US-3.9, US-4.5, US-4.7, US-14.2, US-14.5, US-16.2, US-16.3

#### 9. Admin Features - Enhanced
- **UI**: Event moderation interface
- **UI**: Profile photo moderation
- **UI**: User suspension interface
- **UI**: Audit log viewer
- **User Stories**: US-17.1, US-17.2, US-18.1, US-19.1, US-21.1

#### 10. Society Change Request
- **Database**: Support for society change requests
- **UI**: Request society change
- **Feature**: Validation (no active bookings)
- **User Stories**: US-5.7

### 🟡 MEDIUM PRIORITY - Enhanced Features

#### 11. Society Logo Generation
- **Feature**: Auto-generate random logos at registration
- **Feature**: Logo upload and replacement
- **User Stories**: US-9.4, US-16.6

#### 12. Manager Request System
- **Database**: Manager request tracking
- **UI**: Request to become manager
- **UI**: Admin approval interface for managers
- **User Stories**: US-8.2, US-16.2

#### 13. Multiple Administrators
- **UI**: Manage society administrators
- **Feature**: Ensure at least one active manager
- **User Stories**: US-9.5

#### 14. Advanced Filtering
- **UI**: Enhanced society filters (region, province, distance)
- **UI**: Enhanced event filters (region, province, distance, type, discipline, weapon)
- **User Stories**: US-2.1, US-2.2, US-3.2

#### 15. SEO Optimization
- **Feature**: Meta tags for society pages
- **Feature**: Meta tags for event pages
- **Feature**: Semantic URLs (already have slugs)
- **User Stories**: US-2.3, US-3.1, US-6.1

#### 16. Timezone Display
- **Feature**: Auto-convert times to viewer's timezone
- **Feature**: Display timezone info clearly
- **User Stories**: US-6.2, US-6.3

### 🟢 LOW PRIORITY - Bonus Features

#### 17. Interactive Map
- **UI**: Map view for societies
- **Bonus**: Bonus-1

#### 18. ICS Export
- **Feature**: Export events to calendar format
- **Bonus**: Bonus-2

#### 19. Reviews & Ratings
- **Database**: Reviews table
- **UI**: Rate/review societies after visits
- **UI**: View ratings
- **Bonus**: Bonus-3, Bonus-7, Bonus-8

#### 20. Favorites & Notifications
- **Database**: Favorites table
- **UI**: Mark events as favorites
- **Feature**: Save searches and notifications
- **Bonus**: Bonus-4, Bonus-5

#### 21. Level Badges
- **Feature**: Progressive badges based on visits
- **Bonus**: Bonus-6

#### 22. Event Widget
- **Feature**: Embeddable widget for society websites
- **Bonus**: Bonus-9

---

## SUMMARY

### Implementation Status
- **Fully Implemented**: ~30% (Database foundation, basic pages, admin approval)
- **Partially Implemented**: ~20% (Events, societies, exchange structure exists but incomplete)
- **Not Started**: ~50% (User profiles, exchange UI, society backoffice, notifications)

### Critical Path Items (Must Have for MVP)
1. Coordinates for societies and events
2. Event creation/editing UI
3. User profile system
4. Exchange program public UI
5. Society backoffice complete
6. Email notifications
7. Verification workflow UI

### Next Steps
Create phased implementation plan prioritizing critical path items.
