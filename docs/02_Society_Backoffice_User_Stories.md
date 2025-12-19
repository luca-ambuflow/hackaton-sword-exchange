# SOCIETY BACKOFFICE - USER STORIES

**Version**: 2.0 (Merged)  
**Date**: December 19, 2025  
**Status**: Ready for development

---

## 2.1 Authentication & Access

**US-8.1** As a **society manager**, I want to login to the society backoffice, so that I can manage my society.
- Only approved managers can access

**US-8.2** As a **registered user**, I want to request to become a society manager, so that I can manage a society profile.
- Requires manual admin approval

---

## 2.2 Society Profile Management

**US-9.1** As a **society manager**, I want to create/edit my society profile with required fields (name, tax code, address, coordinates), so that my society is listed and searchable.
- Coordinates entry via copy-paste lat/long fields

**US-9.2** As a **society manager**, I want to see a warning if coordinates are missing, so that I understand visibility limitations.
- Alert: "⚠️ Without coordinates your society won't appear on maps or distance searches"

**US-9.3** As a **society manager**, I want to add optional info (VAT, contacts, website, bio), so that users can learn more.

**US-9.4** As a **society manager**, I want to upload a custom logo to replace the auto-generated one, so that my society has proper branding.
- Random logo generated at registration
- Can be replaced anytime

**US-9.5** As a **society manager**, I want to manage multiple administrators, so that management duties can be shared.
- Must always have at least one active manager

---

## 2.3 Event Management

**US-10.1** As a **society manager**, I want to create events for my society, so that I can promote activities.
- Same event creation features as regular users
- Events linked to managed society

---

## 2.4 User Affiliation & Verification

**US-11.1** As a **society manager**, I want to view users pending verification, so that I can process affiliation requests.
- Shows users who registered/requested affiliation but are not yet verified

**US-11.2** As a **society manager**, I want to approve or reject affiliation requests, so that I can control membership.

**US-11.3** As a **society manager**, I want to verify users by attesting their EPS, membership card, and certificate details, so that they become verified and insured.
- Fields: EPS (dropdown + "Other"), card number, card validity, certificate type (agonistic/non-agonistic), certificate expiry
- No document uploads - attestation only
- Legal declaration checkbox confirming data accuracy
- System logs who attested and when (audit trail)

**US-11.4** As a **society manager**, I want to view all affiliated users with their verification status, so that I can monitor membership.
- Filters: status, date, EPS
- Shows card/certificate details and expiry dates

**US-11.5** As a **society manager**, I want to update user card/certificate details, so that I can maintain accurate records.
- Updates logged in audit trail
- Expired data automatically suspends user from exchange

**US-11.6** As a **society manager**, I want to view verification details only for my users and users with active bookings at my society, so that privacy is maintained.

**US-11.7** As a **society manager**, I want to suspend users, so that I can manage non-compliance.
- Suspended users blocked from exchange
- Can be reactivated by updating data

---

## 2.5 exchange Program Configuration

**US-12.1** As a **society manager**, I want to configure my exchange Program (description, rules, certificate requirements, confirmation mode), so that visitors understand what to expect.
- Certificate requirement: agonistic/non-agonistic/none
- Confirmation mode: auto-confirm or manual approval
- General capacity setting (max people per slot)
- Single location (multi-sede not in MVP)

**US-12.2** As a **society manager**, I want to modify exchange Program settings, so that I can update them over time.
- Changes apply to future slots

---

## 2.6 exchange Slot Management

**US-13.1** As a **society manager**, I want to create individual exchange slots with date/time/capacity, so that I can offer specific training dates.

**US-13.2** As a **society manager**, I want to generate recurring slots (e.g., every Thursday 19:00-21:00 from Sept to June), so that I can quickly create many slots.

**US-13.3** As a **society manager**, I want to remove individual slot dates (e.g., holidays), so that I can manage exceptions.

**US-13.4** As a **society manager**, I want to add additional individual slots, so that I can offer extra opportunities.

**US-13.5** As a **society manager**, I want to edit existing slots (time, date, capacity), so that I can update them.
- Cannot edit past slots
- Cannot reduce capacity below confirmed bookings
- Users notified of significant changes

---

## 2.7 exchange Booking Management

**US-14.1** As a **society manager**, I want to view all bookings with their status (confirmed/pending/cancelled), so that I can manage requests.
- Shows user details, slot, booking date
- Shows card/certificate data for confirmed bookings only

**US-14.2** As a **society manager**, I want to manually approve or reject booking requests with a reason, so that visitors know the outcome.
- Only for manual approval mode
- Reason required for rejection
- Email notifications sent

**US-14.3** As a **society manager**, I want to confirm user attendance after a slot, so that badges can be awarded.
- Can be done after slot date
- Only confirmed attendees receive badges

**US-14.4** As a **society manager**, I want to view and handle "full slot" interest requests, so that I can manage exceptions.
- Can contact user manually or explicitly reject with reason

**US-14.5** As a **society manager**, I want to be notified when users cancel bookings, so that I know slots are available again.

---

## 2.8 BONUS FEATURES

**Bonus-7** As a **society manager**, I want to rate/review exchange visitors, so that other societies have visibility on guest behavior.
- Ratings are public
- Criteria: friendliness, fair-play, teamwork, compliance, punctuality

**Bonus-8** As a **society manager**, I want to view feedback received from visitors, so that I can monitor satisfaction.

**Bonus-9** As a **society manager**, I want to embed a widget showing upcoming events on my website, so that I can promote outside the platform.

---

**Society Backoffice Summary:**
- **MVP User Stories**: 27 stories
- **Bonus Features**: 3 stories
