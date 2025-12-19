# TECHNICAL SPECIFICATIONS & VALIDATION RULES

**Version**: 2.0 (Merged)  
**Date**: December 19, 2025  
**Status**: Ready for development

---

## KEY SPECIFICATIONS

### Event Creation
- Only verified users affiliated with a society can create events
- Events created FOR user's own society only
- Types: gare, sparring, seminari, workshop
- Free-text discipline and weapons fields
- No capacity tracking (only for exchange)

### Verification & Insurance
- Users must be verified by society to participate in exchange
- Society autocertificates via membership card attestation
- No document uploads - attestation only
- Legal declaration + audit trail
- Single society affiliation in MVP

### exchange Bookings
- Capacity per slot (not per society globally)
- Users can cancel bookings
- Society notified of cancellations
- States: pending, confirmed, cancelled

### Coordinates & Distance
- Required for societies and events (manual copy-paste)
- Distance filtering enabled
- Warning shown if missing

### Society Logos
- Random logo auto-generated at registration
- Managers can upload custom logo
- Used for badges, directory, profiles

### Communication
- No messaging/chat system in MVP
- Email notifications for critical actions
- External communication

### Media Management
- Only profile photos managed
- Upload + admin moderation

### Timezone
- Events/slots stored with timezone info
- Auto-converted for viewers
- Creators enter in their local timezone

---

## VALIDATION RULES

### Event Creation
- Date cannot be in the past
- End time must be after start time (if provided)
- Coordinates required for distance filtering

### exchange Slots
- Date cannot be in the past
- End time must be after start time
- Cannot reduce capacity below confirmed bookings

### User Verification
- Card and certificate expiry dates monitored
- Automatic suspension on expiry
- Manual updates by society

### Society Profile
- Name, tax code, address mandatory
- Coordinates strongly recommended
- At least one active manager required

---

## SUMMARY BY PLATFORM

| Platform | MVP Stories | Bonus Stories | Total |
|----------|-------------|---------------|-------|
| **Public Web App** | 40 | 6 | 46 |
| **Society Backoffice** | 27 | 3 | 30 |
| **Backoffice Admin** | 13 | 0 | 13 |
| **TOTAL** | **80** | **9** | **89** |

---

**Document Version**: 2.0 (Merged Final)  
**Next Steps**: Implementation plan with phases
