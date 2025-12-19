# BACKOFFICE ADMIN PLATFORM - USER STORIES

**Version**: 2.0 (Merged)  
**Date**: December 19, 2025  
**Status**: Ready for development

---

## 3.1 Admin Authentication & Access

**US-15.1** As a **platform admin**, I want to login to the admin backoffice, so that I can moderate content and manage the platform.

---

## 3.2 Society & Manager Management

**US-16.1** As a **platform admin**, I want to view all societies with filters (status, date, region), so that I can manage them.

**US-16.2** As a **platform admin**, I want to manually review and approve society manager requests, so that only legitimate managers can manage societies.
- Manual review is the only way to become a manager
- Email notifications sent on approval/rejection

**US-16.3** As a **platform admin**, I want to view and approve society registration requests, so that verified societies enter the platform.
- Includes offline verification (phone call + certificate check)
- Requester becomes manager automatically on approval
- Email notification sent

**US-16.4** As a **platform admin**, I want to seed societies directly into the database, so that I can bootstrap the platform.
- Societies immediately active
- Can be assigned managers later

**US-16.5** As a **platform admin**, I want to suspend or remove societies, so that I can manage problematic cases.
- Strong confirmation required
- Reason logging mandatory
- Email notifications sent

**US-16.6** As a **system**, I want to auto-generate random logos at society registration, so that societies have visual placeholders.

---

## 3.3 Event Moderation

**US-17.1** As a **platform admin**, I want to view all events with filters (creator, date, status, type), so that I can moderate them.

**US-17.2** As a **platform admin**, I want to quickly delete events with strong confirmation and a reason, so that I can address spam/violations.
- Accessible from calendar view and event detail
- Strong confirmation (re-enter title or explicit confirm)
- Email notification sent to creator with reason
- Event marked as "removed" (soft delete)

---

## 3.4 Content & Media Moderation

**US-18.1** As a **platform admin**, I want to moderate and remove inappropriate profile photos, so that content standards are maintained.

---

## 3.5 User & Abuse Management

**US-19.1** As a **platform admin**, I want to suspend or ban problematic users, so that I can manage abuses.
- Temporary or permanent suspension
- Reason required
- Email notifications sent
- Activity logged

---

## 3.6 System Configuration

**US-20.1** As a **developer**, I want the system to support i18n from the start, so that multiple languages can be added easily.

---

## 3.7 Audit & Logging

**US-21.1** As a **platform admin**, I want to view logs of critical activities (deletions, suspensions, approvals), so that I can monitor administrative actions.
- Shows who, what, when, why, details
- Filters by type, admin, date, object
- Export to CSV/PDF

---

**Backoffice Admin Summary:**
- **MVP User Stories**: 13 stories
- **Primary Functions**: Moderation, Approval Workflows, System Management
