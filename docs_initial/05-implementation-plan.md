# Implementation Plan

## Overview

This document outlines the implementation strategy for the Historical Fencing Portal, organized into 7 phases over approximately 10 weeks.

---

## Development Approach

### Principles

1. **Phased Delivery**: Build in incremental phases, each delivering working functionality
2. **SEO First**: Prioritize SEO-critical features early
3. **MVP Focus**: Core value proposition before nice-to-have features
4. **Test as You Build**: Validate each phase before moving to next
5. **Free Tier Conscious**: Monitor usage throughout development

---

## Technology Stack Setup

### Prerequisites

```bash
# Required software
- Node.js 20.x LTS
- npm 10.x (or pnpm/yarn)
- Git
- PostgreSQL client (for local testing)
```

### Project Initialization

```bash
# 1. Create Next.js project
npx create-next-app@latest swords \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*"

# 2. Install core dependencies
cd swords
npm install @supabase/supabase-js @supabase/ssr
npm install next-intl
npm install luxon
npm install --save-dev @types/luxon

# 3. Install form libraries
npm install react-hook-form zod @hookform/resolvers

# 4. Install UI components (shadcn/ui)
npx shadcn-ui@latest init
npx shadcn-ui@latest add button input select dialog dropdown-menu checkbox card

# 5. Install calendar
npm install react-big-calendar
npm install --save-dev @types/react-big-calendar

# 6. Install utilities
npm install clsx tailwind-merge

# 7. (Optional) Install state management
npm install zustand
```

---

## Phase Overview

| Phase | Focus | Duration | Deliverable |
|-------|-------|----------|-------------|
| 0 | Foundation | Week 1 | Working auth + i18n |
| 1 | Society Directory | Week 2 | Public directory |
| 2 | Events Calendar | Weeks 3-4 | Event creation & listing |
| 3 | Verification System | Week 5 | Affiliation & attestation |
| 4 | Erasmus Program | Weeks 6-7 | Bookings system |
| 5 | Admin Dashboard | Week 8 | Moderation tools |
| 6 | SEO & Performance | Week 9 | Production-ready |
| 7 | Deployment | Week 10 | Live site |

---

## Implementation Order Rationale

### Why This Sequence?

**Phase 0 (Foundation)**:
- Must come first - establishes technical foundation
- Authentication needed for all user-facing features
- i18n must be configured before building any pages

**Phase 1 (Society Directory)**:
- Simplest module, validates full stack integration
- Provides early SEO value (society listings)
- Required for later features (events can link to societies)

**Phase 2 (Events Calendar)**:
- Core value proposition - quick event creation
- Demonstrates SEO optimization for dynamic content
- Needs societies to exist (for organizer association)

**Phase 3 (Verification System)**:
- Required before Erasmus program
- Complex business logic, needs dedicated focus
- Independent from events calendar

**Phase 4 (Erasmus Program)**:
- Depends on verification system
- Most complex module, needs time
- Differentiator feature

**Phase 5 (Admin Dashboard)**:
- Needed for moderation but not blocking for users
- Can be built once content exists (events, societies)

**Phase 6 (SEO & Performance)**:
- Final polish before launch
- Requires all content types to exist
- Critical for production

**Phase 7 (Deployment)**:
- Final validation and go-live

---

## Critical Files by Phase

### Phase 0: Foundation

**Config Files**:
- `next.config.js` - Next.js configuration
- `tailwind.config.ts` - Tailwind setup
- `tsconfig.json` - TypeScript config
- `.env.local` - Environment variables
- `.env.example` - Template

**Supabase**:
- `/src/lib/supabase/client.ts`
- `/src/lib/supabase/server.ts`
- `/src/middleware.ts`
- `/supabase/migrations/001_initial_schema.sql`

**i18n**:
- `/src/i18n/routing.ts`
- `/src/i18n/request.ts`
- `/src/i18n/locales/it.json`
- `/src/i18n/locales/en.json`
- `/src/i18n/locales/de.json`

**Auth**:
- `/src/app/[locale]/auth/login/page.tsx`
- `/src/app/[locale]/auth/register/page.tsx`
- `/src/app/[locale]/auth/callback/route.ts`
- `/src/components/auth/login-form.tsx`
- `/src/components/auth/register-form.tsx`

**Layout**:
- `/src/app/[locale]/layout.tsx`
- `/src/components/layout/header.tsx`
- `/src/components/layout/footer.tsx`
- `/src/components/layout/language-switcher.tsx`

---

### Phase 1: Society Directory

**Database**:
- `/supabase/migrations/002_societies.sql`

**Server Actions**:
- `/src/actions/societies/create-society.ts`
- `/src/actions/societies/update-society.ts`
- `/src/actions/societies/get-societies.ts`
- `/src/actions/societies/get-society-by-slug.ts`

**Pages**:
- `/src/app/[locale]/societies/page.tsx`
- `/src/app/[locale]/societies/[slug]/page.tsx`
- `/src/app/[locale]/society-admin/profile/page.tsx`

**Components**:
- `/src/components/societies/society-card.tsx`
- `/src/components/societies/society-filters.tsx`
- `/src/components/societies/society-form.tsx`

---

### Phase 2: Events Calendar

**Database**:
- `/supabase/migrations/003_events.sql`

**Server Actions**:
- `/src/actions/events/create-event.ts`
- `/src/actions/events/update-event.ts`
- `/src/actions/events/delete-event.ts`
- `/src/actions/events/duplicate-event.ts`
- `/src/actions/events/get-events.ts`

**Pages**:
- `/src/app/[locale]/events/page.tsx`
- `/src/app/[locale]/events/create/page.tsx`
- `/src/app/[locale]/events/[slug]/page.tsx`
- `/src/app/[locale]/events/[slug]/edit/page.tsx`

**Components**:
- `/src/components/events/event-card.tsx`
- `/src/components/events/event-filters.tsx`
- `/src/components/events/event-form.tsx`
- `/src/components/events/event-calendar-view.tsx`
- `/src/components/events/quick-event-creator.tsx`

**Utilities**:
- `/src/lib/utils/timezone.ts`
- `/src/lib/utils/slugify.ts`
- `/src/lib/hooks/use-timezone.ts`

---

### Phase 3: Verification System

**Database**:
- `/supabase/migrations/005_verification.sql`

**Server Actions**:
- `/src/actions/verification/request-affiliation.ts`
- `/src/actions/verification/approve-affiliation.ts`
- `/src/actions/verification/attest-documents.ts`
- `/src/actions/verification/check-verification-status.ts`

**Pages**:
- `/src/app/[locale]/dashboard/affiliation/page.tsx`
- `/src/app/[locale]/dashboard/verification/page.tsx`
- `/src/app/[locale]/society-admin/members/page.tsx`

**Components**:
- `/src/components/verification/affiliation-request-form.tsx`
- `/src/components/verification/attestation-form.tsx`
- `/src/components/verification/verification-badge.tsx`
- `/src/components/verification/member-status-card.tsx`

---

### Phase 4: Erasmus Program

**Database**:
- `/supabase/migrations/004_erasmus.sql`

**Server Actions**:
- `/src/actions/erasmus/create-program.ts`
- `/src/actions/erasmus/update-program.ts`
- `/src/actions/erasmus/generate-slots.ts`
- `/src/actions/erasmus/create-booking.ts`
- `/src/actions/erasmus/approve-booking.ts`
- `/src/actions/erasmus/reject-booking.ts`

**Pages**:
- `/src/app/[locale]/erasmus/page.tsx`
- `/src/app/[locale]/erasmus/browse/page.tsx`
- `/src/app/[locale]/erasmus/my-bookings/page.tsx`
- `/src/app/[locale]/society-admin/erasmus/settings/page.tsx`
- `/src/app/[locale]/society-admin/erasmus/slots/page.tsx`
- `/src/app/[locale]/society-admin/erasmus/bookings/page.tsx`

**Components**:
- `/src/components/erasmus/program-settings-form.tsx`
- `/src/components/erasmus/slot-generator.tsx`
- `/src/components/erasmus/slot-calendar.tsx`
- `/src/components/erasmus/booking-card.tsx`

---

### Phase 5: Admin Dashboard

**Database**:
- `/supabase/migrations/006_admin.sql`

**Server Actions**:
- `/src/actions/admin/approve-society-manager.ts`
- `/src/actions/admin/moderate-event.ts`

**Pages**:
- `/src/app/[locale]/admin/page.tsx`
- `/src/app/[locale]/admin/societies/page.tsx`
- `/src/app/[locale]/admin/events/page.tsx`

---

### Phase 6: SEO & Performance

**SEO Files**:
- `/src/app/sitemap.ts`
- `/src/app/robots.ts`
- `/src/components/seo/event-schema.tsx`
- `/src/components/seo/organization-schema.tsx`

**Optimizations**:
- Add `generateMetadata` to all dynamic pages
- Implement React cache for deduplication
- Add loading skeletons
- Optimize images
- Database query optimization

---

### Phase 7: Deployment

**Deployment Setup**:
- Connect GitHub to Vercel
- Configure environment variables
- Set up production Supabase database
- Run migrations on production
- Configure custom domain

---

## Development Workflow

### Daily Workflow

```bash
# 1. Pull latest changes
git pull origin main

# 2. Create feature branch
git checkout -b feature/phase-1-societies

# 3. Start development server
npm run dev

# 4. Make changes, test locally
# ...

# 5. Run type check
npm run type-check

# 6. Run linter
npm run lint

# 7. Commit changes
git add .
git commit -m "feat(societies): add society directory page"

# 8. Push to GitHub
git push origin feature/phase-1-societies

# 9. Create pull request
# Review on Vercel preview deployment
```

---

## Testing Strategy

### Manual Testing

**Per Phase**:
- Test all new features in browser
- Test different user roles
- Test mobile responsiveness
- Test different locales (IT, EN, DE)

**SEO Testing**:
- Lighthouse audit (target score >90)
- Validate structured data (Google Rich Results Test)
- Test social media previews (OpenGraph)
- Check sitemap generation
- Verify robots.txt

**Performance Testing**:
- Page load times (<3s)
- Time to Interactive (<5s)
- Core Web Vitals (LCP, FID, CLS)

### Automated Testing (Future)

Phase 0 focuses on manual testing. Consider adding:
- E2E tests (Playwright) in Phase 6
- Unit tests for critical business logic
- Integration tests for Server Actions

---

## Environment Management

### Environments

1. **Local Development** (`http://localhost:3000`)
   - Local Next.js dev server
   - Supabase development project

2. **Preview** (Vercel preview deployments)
   - Automatic per-PR deployments
   - Supabase development project

3. **Production** (`https://schermaportal.com`)
   - Vercel production deployment
   - Supabase production project

### Environment Variables

```bash
# .env.local (development)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Production (Vercel)
NEXT_PUBLIC_SUPABASE_URL=https://yyy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=yyy
SUPABASE_SERVICE_ROLE_KEY=yyy
NEXT_PUBLIC_SITE_URL=https://schermaportal.com
```

---

## Code Organization Principles

### File Naming

- **Pages**: `page.tsx` (Next.js convention)
- **Components**: `kebab-case.tsx` (e.g., `event-card.tsx`)
- **Server Actions**: `kebab-case.ts` (e.g., `create-event.ts`)
- **Utilities**: `kebab-case.ts` (e.g., `slugify.ts`)
- **Types**: `PascalCase` for types (e.g., `EventInput`)

### Component Structure

```typescript
// 1. Imports
import { useState } from 'react'
import { useTranslations } from 'next-intl'

// 2. Types
interface EventCardProps {
  event: Event
}

// 3. Component
export function EventCard({ event }: EventCardProps) {
  const t = useTranslations('events')

  // 4. Hooks
  const [isExpanded, setIsExpanded] = useState(false)

  // 5. Render
  return (
    <div>
      <h3>{event.title}</h3>
      {/* ... */}
    </div>
  )
}
```

### Server Action Structure

```typescript
'use server'

// 1. Imports
import { createServerClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

// 2. Types
interface CreateEventInput {
  title: string
  // ...
}

// 3. Validation schema
const eventSchema = z.object({
  title: z.string().min(3),
  // ...
})

// 4. Server Action
export async function createEvent(input: CreateEventInput) {
  // a. Validate auth
  const user = await getCurrentUser()
  if (!user) throw new Error('Unauthorized')

  // b. Validate input
  const validated = eventSchema.parse(input)

  // c. Business logic
  const slug = slugify(validated.title)

  // d. Database operation
  const supabase = createServerClient()
  const { data, error } = await supabase
    .from('events')
    .insert({ ...validated, slug, creator_id: user.id })
    .select()
    .single()

  if (error) throw error

  // e. Revalidate cache
  revalidatePath('/events')

  // f. Return result
  return { success: true, data }
}
```

---

## Quality Checklist

### Before Moving to Next Phase

- [ ] All features working as specified
- [ ] No TypeScript errors
- [ ] No console errors in browser
- [ ] Mobile responsive
- [ ] All locales tested (IT, EN, DE)
- [ ] RLS policies tested
- [ ] Database migrations run successfully
- [ ] Code committed and pushed to GitHub
- [ ] Vercel preview deployment verified

### SEO Checklist (Phase 6)

- [ ] All pages have proper `<title>` and `<meta>` tags
- [ ] Structured data on all entity pages
- [ ] Sitemap generated and accessible
- [ ] Robots.txt configured
- [ ] Hreflang tags for all locales
- [ ] OpenGraph tags for social sharing
- [ ] Fast page loads (<3s)
- [ ] Mobile-friendly (Google Mobile-Friendly Test)
- [ ] Lighthouse score >90

---

## Risk Mitigation

### Potential Risks & Mitigations

**Risk**: Exceeding free tier limits
- **Mitigation**: Monitor Vercel/Supabase dashboards weekly
- **Mitigation**: Implement soft deletes and cleanup old data
- **Mitigation**: Optimize images and queries

**Risk**: Complex Erasmus booking logic
- **Mitigation**: Design phase before implementation
- **Mitigation**: Write comprehensive test cases
- **Mitigation**: Start with simplest version, iterate

**Risk**: SEO not effective
- **Mitigation**: Validate early with Google Search Console
- **Mitigation**: Follow SEO best practices checklist
- **Mitigation**: Test with Lighthouse from Phase 1

**Risk**: Performance issues
- **Mitigation**: Profile slow queries early
- **Mitigation**: Add indexes proactively
- **Mitigation**: Monitor Core Web Vitals

---

## Success Metrics

### Technical Metrics

- **Build Success Rate**: 100% (no failed builds)
- **Lighthouse Score**: >90 (performance, accessibility, best practices, SEO)
- **Page Load Time**: <3 seconds (75th percentile)
- **Error Rate**: <1% (production errors)

### Functional Metrics

- **Feature Completion**: 100% of MVP features working
- **Browser Compatibility**: Works on Chrome, Firefox, Safari, Edge
- **Mobile Compatibility**: Fully responsive, works on iOS and Android
- **Accessibility**: No critical WCAG 2.1 AA violations

---

## Documentation Maintenance

### Throughout Development

- Update this plan if scope changes
- Document decisions in GitHub issues
- Keep README.md current
- Add inline code comments for complex logic
- Update database schema docs when tables change

---

## Post-Launch Plan

### Immediate Post-Launch (Week 11-12)

1. **Monitor**:
   - Error tracking (check logs daily)
   - Free tier usage (Vercel, Supabase)
   - User feedback (if any)

2. **Quick Fixes**:
   - Address critical bugs
   - Fix SEO issues
   - Performance optimizations

3. **Analytics**:
   - Set up basic analytics (privacy-friendly)
   - Track key metrics (events created, societies registered)

### Future Enhancements (Post-MVP)

Prioritize based on user feedback:
- Distance filter (geocoding)
- Email notifications
- User reporting system
- Feedback/reviews for Erasmus
- Maps integration
- Advanced search
- Mobile app (future)

---

## Summary

This implementation plan provides:

1. **Clear roadmap**: 7 phases with specific deliverables
2. **Organized approach**: Technical foundation first, then features
3. **Quality gates**: Checklist before advancing phases
4. **Risk awareness**: Known risks with mitigation strategies
5. **Maintainability**: Code organization principles and documentation

The plan balances speed (10 weeks total) with quality (proper SEO, security, performance) while staying within free tier limits.

Next: See [Implementation Phases](./06-phases.md) for detailed phase breakdowns.
