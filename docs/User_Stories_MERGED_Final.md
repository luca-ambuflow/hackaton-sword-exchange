# **USER STORIES - PORTALE SCHERMA STORICA**
## **MERGED FINAL VERSION**
**Version**: 2.0 (Merged)  
**Date**: December 19, 2025  
**Status**: Ready for development

---

# **1. PUBLIC WEB APP**

---

## **1.1 Authentication & Registration**

**US-1.1** As a **visitor**, I want to register with email/password and select my society, so that I can access the platform.
- During registration, society selection is mandatory
- Option to create new society if not present in list
- User automatically affiliates to selected society with "non-verified" status

**US-1.2** As a **visitor registering a new society**, I want to be warned if I don't provide coordinates, so that I understand my society won't appear on maps or distance searches.

**US-1.3** As a **registered user**, I want to login with email/password, so that I can access platform features.

**US-1.4** As a **registered user**, I want to logout, so that I can end my session securely.

**US-1.5** As a **registered user**, I want to request affiliation to a society, so that I can become verified and access restricted features.

**US-1.6** As a **registered user**, I want to accept privacy terms during registration, so that I understand how my data is used.

**US-1.7** As a **registered user**, I want to accept separate exchange terms before participating, so that I understand program rules and liability.

---

## **1.2 Society Directory (Public View)**

**US-2.1** As a **visitor**, I want to view a list of societies with filters (region, province), so that I can find societies in my area.

**US-2.2** As a **visitor**, I want to filter societies by distance in kilometers from my location, so that I can find the nearest societies.
- Requires browser geolocation or manual location input
- Only societies with coordinates appear in distance filter results

**US-2.3** As a **visitor**, I want to see society details (name, address, contacts, website, bio), so that I can learn about them.
- View link to society's events on calendar
- View exchange Program indicator if active
- SEO-optimized pages with semantic URLs

---

## **1.3 Global Events Calendar**

**US-3.1** As a **visitor**, I want to view all events on a public calendar with two views (calendar/list), so that I can discover historical fencing events.
- Events show: title, date/time (with timezone), location, type, organizer
- SEO-optimized pages

**US-3.2** As a **visitor**, I want to filter events by region, province, organizing society, distance, type, and discipline/weapon, so that I can find relevant events.

**US-3.3** As a **visitor**, I want to view event details (title, type, date/time, location, organizer, description, external link), so that I can decide whether to participate.
- Map shown only if coordinates provided
- External link opens in new tab

**US-3.4** As a **verified user affiliated with a society**, I want to create events for my society, so that they appear on the global calendar.
- Required fields: title, type (gare/sparring/seminari/workshop), date/time, location with coordinates, description, external link
- Events published immediately (no approval)
- No capacity tracking for events

**US-3.5** As an **unaffiliated user**, I want to be prevented from creating events until I'm verified, so that all events have legitimate organizers.

**US-3.6** As a **registered user**, I want to add free-text discipline and weapon fields when creating events, so that I can specify details flexibly.

**US-3.7** As a **registered user**, I want to copy/duplicate a previous event, so that I can quickly create recurring events.

**US-3.8** As a **registered user**, I want to edit my events, so that I can update information.
- Cannot edit past events
- Timezone automatically set from browser

**US-3.9** As an **event creator**, I want to receive email notification if my event is deleted with the reason, so that I understand what happened.

---

## **1.4 exchange Program**

**US-4.1** As a **visitor**, I want to view a dedicated exchange landing page with engaging explanation and "Apply" button, so that I understand the program benefits.
- Explains what exchange is, benefits, how it works, requirements
- Links to registration and available programs

**US-4.2** As a **visitor**, I want to view societies offering exchange Programs with filters (region, province, date range), so that I can find training opportunities.

**US-4.3** As a **visitor**, I want to view exchange Program details for a society (description, rules, requirements), so that I know what to expect.

**US-4.4** As a **verified user**, I want to view available exchange slots with date/time/capacity, so that I can book training sessions.
- Only verified users with valid card/certificate can view slots
- Slots show: date, time, status (available/full/booked by me), participants count

**US-4.5** As a **verified user**, I want to book an exchange slot, so that I can train at another society.
- Auto-confirmation or manual approval based on society settings
- Email notifications sent to user and society
- Must accept exchange terms before first booking

**US-4.6** As a **verified user**, I want to express interest in full slots ("vorrei venire lo stesso"), so that the society can contact me if space becomes available.

**US-4.7** As a **verified user**, I want to cancel my exchange booking, so that I can free up the slot.
- Society notified via email

**US-4.8** As a **verified user**, I want to see my booking status (pending/confirmed/cancelled), so that I know my request state.

**US-4.9** As a **verified user**, I want to see my exchange history, so that I can track where I've trained.

**US-4.10** As a **verified user**, I want to earn society badges when I complete confirmed visits, so that I can display them on my profile.
- Badges auto-generated with society logo
- Only awarded after society confirms attendance

**US-4.11** As a **non-verified or suspended user**, I want to be blocked from exchange participation with clear messaging, so that only insured users can participate.

**US-4.12** As a **verified user**, I want to book exchange slots without home society approval, so that I can freely explore once verified.

---

## **1.5 User Profile**

**US-5.1** As a **registered user**, I want to create a profile with photo, name, and affiliated society, so that I can be recognized in the community.
- Profile has public and private sections

**US-5.2** As a **registered user**, I want to upload and manage my profile photo, so that I can personalize my profile.

**US-5.3** As a **registered user**, I want to edit my bio (fencing background, experience), so that I can share my story.

**US-5.4** As a **registered user**, I want to display exchange badges and competition badges on my profile, so that I can showcase my achievements.

**US-5.5** As a **registered user**, I want to view my own verification status (card, certificate, expiry dates), so that I know if I need renewals.
- This data is private (not in public profile)

**US-5.6** As a **verified user**, I want to be automatically suspended from exchange if my card/certificate expires, so that insurance validity is maintained.

**US-5.7** As a **registered user**, I want to request a society change, so that I can update my affiliation.
- Cannot change if active exchange bookings exist
- New affiliation request starts with "non-verified" status
- Old affiliation remains until new one is approved

**US-5.8** As a **visitor**, I want to view public user profiles, so that I can see their exchange badges and achievements.

---

## **1.6 Internationalization & SEO**

**US-6.1** As a **visitor**, I want event and society pages SEO-optimized, so that they're discoverable via search engines.

**US-6.2** As a **visitor**, I want to view times in my local timezone, so that I know when events happen in my time.

**US-6.3** As a **creator**, I want to enter times in my local timezone, so that I don't need manual conversion.

---

## **1.7 Privacy & Data Visibility**

**US-7.1** As a **verified user**, I want my verification data visible only to me, my society, and host societies with active bookings, so that my privacy is protected.

**US-7.2** As a **registered user**, I want profile photos to be the only managed media, so that moderation stays simple.

---

## **1.8 PUBLIC WEB APP - BONUS FEATURES**

**Bonus-1** As a **visitor**, I want to view societies on an interactive map, so that I can visualize their distribution.

**Bonus-2** As a **visitor**, I want to export events to ICS format, so that I can add them to my calendar.

**Bonus-3** As a **verified user**, I want to rate/review host societies after visits, so that I can share my experience.
- Ratings are public
- Criteria: professionalism, welcome, growth opportunity, structure

**Bonus-4** As a **visitor**, I want to mark events as favorites, so that I can track interesting events.

**Bonus-5** As a **visitor**, I want to save searches and receive notifications for new matching events, so that I'm alerted to opportunities.

**Bonus-6** As a **registered user**, I want to earn level badges based on societies visited, so that I can showcase engagement.

---

**Public Web App Summary:**
- **MVP User Stories**: 40 stories
- **Bonus Features**: 6 stories

---

# **2. SOCIETY BACKOFFICE**

---

## **2.1 Authentication & Access**

**US-8.1** As a **society manager**, I want to login to the society backoffice, so that I can manage my society.
- Only approved managers can access

**US-8.2** As a **registered user**, I want to request to become a society manager, so that I can manage a society profile.
- Requires manual admin approval

---

## **2.2 Society Profile Management**

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

## **2.3 Event Management**

**US-10.1** As a **society manager**, I want to create events for my society, so that I can promote activities.
- Same event creation features as regular users
- Events linked to managed society

---

## **2.4 User Affiliation & Verification**

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

## **2.5 exchange Program Configuration**

**US-12.1** As a **society manager**, I want to configure my exchange Program (description, rules, certificate requirements, confirmation mode), so that visitors understand what to expect.
- Certificate requirement: agonistic/non-agonistic/none
- Confirmation mode: auto-confirm or manual approval
- General capacity setting (max people per slot)
- Single location (multi-sede not in MVP)

**US-12.2** As a **society manager**, I want to modify exchange Program settings, so that I can update them over time.
- Changes apply to future slots

---

## **2.6 exchange Slot Management**

**US-13.1** As a **society manager**, I want to create individual exchange slots with date/time/capacity, so that I can offer specific training dates.

**US-13.2** As a **society manager**, I want to generate recurring slots (e.g., every Thursday 19:00-21:00 from Sept to June), so that I can quickly create many slots.

**US-13.3** As a **society manager**, I want to remove individual slot dates (e.g., holidays), so that I can manage exceptions.

**US-13.4** As a **society manager**, I want to add additional individual slots, so that I can offer extra opportunities.

**US-13.5** As a **society manager**, I want to edit existing slots (time, date, capacity), so that I can update them.
- Cannot edit past slots
- Cannot reduce capacity below confirmed bookings
- Users notified of significant changes

---

## **2.7 exchange Booking Management**

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

## **2.8 SOCIETY BACKOFFICE - BONUS FEATURES**

**Bonus-7** As a **society manager**, I want to rate/review exchange visitors, so that other societies have visibility on guest behavior.
- Ratings are public
- Criteria: friendliness, fair-play, teamwork, compliance, punctuality

**Bonus-8** As a **society manager**, I want to view feedback received from visitors, so that I can monitor satisfaction.

**Bonus-9** As a **society manager**, I want to embed a widget showing upcoming events on my website, so that I can promote outside the platform.

---

**Society Backoffice Summary:**
- **MVP User Stories**: 27 stories
- **Bonus Features**: 3 stories

---

# **3. BACKOFFICE ADMIN PLATFORM**

---

## **3.1 Admin Authentication & Access**

**US-15.1** As a **platform admin**, I want to login to the admin backoffice, so that I can moderate content and manage the platform.

---

## **3.2 Society & Manager Management**

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

## **3.3 Event Moderation**

**US-17.1** As a **platform admin**, I want to view all events with filters (creator, date, status, type), so that I can moderate them.

**US-17.2** As a **platform admin**, I want to quickly delete events with strong confirmation and a reason, so that I can address spam/violations.
- Accessible from calendar view and event detail
- Strong confirmation (re-enter title or explicit confirm)
- Email notification sent to creator with reason
- Event marked as "removed" (soft delete)

---

## **3.4 Content & Media Moderation**

**US-18.1** As a **platform admin**, I want to moderate and remove inappropriate profile photos, so that content standards are maintained.

---

## **3.5 User & Abuse Management**

**US-19.1** As a **platform admin**, I want to suspend or ban problematic users, so that I can manage abuses.
- Temporary or permanent suspension
- Reason required
- Email notifications sent
- Activity logged

---

## **3.6 System Configuration**

**US-20.1** As a **developer**, I want the system to support i18n from the start, so that multiple languages can be added easily.

---

## **3.7 Audit & Logging**

**US-21.1** As a **platform admin**, I want to view logs of critical activities (deletions, suspensions, approvals), so that I can monitor administrative actions.
- Shows who, what, when, why, details
- Filters by type, admin, date, object
- Export to CSV/PDF

---

**Backoffice Admin Summary:**
- **MVP User Stories**: 13 stories
- **Primary Functions**: Moderation, Approval Workflows, System Management

---

# **SUMMARY BY PLATFORM**

| Platform | MVP Stories | Bonus Stories | Total |
|----------|-------------|---------------|-------|
| **Public Web App** | 40 | 6 | 46 |
| **Society Backoffice** | 27 | 3 | 30 |
| **Backoffice Admin** | 13 | 0 | 13 |
| **TOTAL** | **80** | **9** | **89** |

---

# **KEY SPECIFICATIONS**

## **Event Creation**
- Only verified users affiliated with a society can create events
- Events created FOR user's own society only
- Types: gare, sparring, seminari, workshop
- Free-text discipline and weapons fields
- No capacity tracking (only for exchange)

## **Verification & Insurance**
- Users must be verified by society to participate in exchange
- Society autocertificates via membership card attestation
- No document uploads - attestation only
- Legal declaration + audit trail
- Single society affiliation in MVP

## **exchange Bookings**
- Capacity per slot (not per society globally)
- Users can cancel bookings
- Society notified of cancellations
- States: pending, confirmed, cancelled

## **Coordinates & Distance**
- Required for societies and events (manual copy-paste)
- Distance filtering enabled
- Warning shown if missing

## **Society Logos**
- Random logo auto-generated at registration
- Managers can upload custom logo
- Used for badges, directory, profiles

## **Communication**
- No messaging/chat system in MVP
- Email notifications for critical actions
- External communication

## **Media Management**
- Only profile photos managed
- Upload + admin moderation

## **Timezone**
- Events/slots stored with timezone info
- Auto-converted for viewers
- Creators enter in their local timezone

---

# **VALIDATION RULES**

## **Event Creation**
- Date cannot be in the past
- End time must be after start time (if provided)
- Coordinates required for distance filtering

## **exchange Slots**
- Date cannot be in the past
- End time must be after start time
- Cannot reduce capacity below confirmed bookings

## **User Verification**
- Card and certificate expiry dates monitored
- Automatic suspension on expiry
- Manual updates by society

## **Society Profile**
- Name, tax code, address mandatory
- Coordinates strongly recommended
- At least one active manager required

---

**Document Version**: 2.0 (Merged Final)  
**Next Steps**: Technical architecture, database schema, API specification

