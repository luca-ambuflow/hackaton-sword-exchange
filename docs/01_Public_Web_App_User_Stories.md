# PUBLIC WEB APP - USER STORIES

**Version**: 2.0 (Merged)  
**Date**: December 19, 2025  
**Status**: Ready for development

---

## 1.1 Authentication & Registration

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

## 1.2 Society Directory (Public View)

**US-2.1** As a **visitor**, I want to view a list of societies with filters (region, province), so that I can find societies in my area.

**US-2.2** As a **visitor**, I want to filter societies by distance in kilometers from my location, so that I can find the nearest societies.
- Requires browser geolocation or manual location input
- Only societies with coordinates appear in distance filter results

**US-2.3** As a **visitor**, I want to see society details (name, address, contacts, website, bio), so that I can learn about them.
- View link to society's events on calendar
- View exchange Program indicator if active
- SEO-optimized pages with semantic URLs

---

## 1.3 Global Events Calendar

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

## 1.4 exchange Program

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

## 1.5 User Profile

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

## 1.6 Internationalization & SEO

**US-6.1** As a **visitor**, I want event and society pages SEO-optimized, so that they're discoverable via search engines.

**US-6.2** As a **visitor**, I want to view times in my local timezone, so that I know when events happen in my time.

**US-6.3** As a **creator**, I want to enter times in my local timezone, so that I don't need manual conversion.

---

## 1.7 Privacy & Data Visibility

**US-7.1** As a **verified user**, I want my verification data visible only to me, my society, and host societies with active bookings, so that my privacy is protected.

**US-7.2** As a **registered user**, I want profile photos to be the only managed media, so that moderation stays simple.

---

## 1.8 BONUS FEATURES

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
