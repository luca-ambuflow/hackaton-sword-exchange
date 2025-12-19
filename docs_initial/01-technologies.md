# Technologies

## Overview

The Historical Fencing Portal uses modern, production-ready technologies optimized for SEO, performance, and free-tier hosting.

## Core Stack

### Framework: Next.js 14+

**What**: React framework with App Router (Server Components)

**Why**:
- **SSR/SSG**: Critical for SEO - all public pages server-rendered
- **App Router**: Modern routing with layouts, loading states, error boundaries
- **Server Actions**: Simplified data mutations without separate API routes
- **Image Optimization**: Automatic image optimization with `next/image`
- **Built-in i18n**: Works seamlessly with next-intl
- **Vercel Integration**: Deploy to Vercel free tier with zero configuration

**Version**: 14.2.0+

**Key Features Used**:
- Server Components for public pages (societies, events)
- Server Actions for data mutations
- Dynamic metadata generation for SEO
- Middleware for auth + i18n
- Dynamic sitemap generation

---

### Database: PostgreSQL via Supabase

**What**: Relational database with built-in auth, row-level security, and real-time capabilities

**Why**:
- **Relational Model**: Perfect for complex relationships (users, societies, events, bookings)
- **Row Level Security (RLS)**: Database-level security policies
- **Free Tier**: Generous limits (500MB storage, 50K monthly active users)
- **Built-in Auth**: Integrated authentication system
- **PostgreSQL Features**: Full-text search, JSON columns, PostGIS (future)
- **Migration System**: Version-controlled database changes

**Free Tier Limits**:
- 500MB database storage
- 1GB file storage
- 50,000 monthly active users
- 2GB bandwidth

**Key Features Used**:
- Row Level Security (RLS) on all tables
- UUIDs for primary keys
- TIMESTAMPTZ for timezone-aware dates
- GIN indexes for full-text search
- Soft deletes with `deleted_at` column

---

### Authentication: Supabase Auth

**What**: Built-in authentication system from Supabase

**Why**:
- **Integrated**: Works seamlessly with Supabase database
- **Multiple Providers**: Email/password, OAuth (Google, GitHub, etc.)
- **Session Management**: Automatic token refresh
- **SSR Compatible**: Works with Next.js Server Components
- **Free**: No additional cost
- **Security**: Industry-standard JWT tokens

**Features Used**:
- Email/password authentication
- Session cookies for SSR
- Custom profiles table extending `auth.users`
- Role-based access via custom `user_roles` table

---

### Styling: TailwindCSS + shadcn/ui

**What**: Utility-first CSS framework + accessible component library

**Why**:
- **TailwindCSS**:
  - Utility-first approach for rapid development
  - Minimal CSS bundle size (purges unused styles)
  - Consistent design system
  - Responsive design built-in
  - Dark mode support (future)

- **shadcn/ui**:
  - Accessible components (Radix UI primitives)
  - Customizable (copy components, own the code)
  - No runtime overhead (not a package dependency)
  - TypeScript support
  - Tailwind-integrated

**Components Used**:
- Button, Input, Select, Checkbox
- Dialog (modals)
- Dropdown Menu
- Card
- Calendar (for date pickers)

---

### Internationalization: next-intl

**What**: i18n library for Next.js App Router

**Why**:
- **App Router Native**: Built specifically for Next.js 14+
- **Server Components**: Works with SSR
- **Type Safety**: TypeScript support for translation keys
- **Performance**: No client-side overhead for static translations
- **SEO Friendly**: Proper `<link rel="alternate">` tags
- **Locale Routing**: Automatic `/it`, `/en`, `/de` routes

**Supported Languages** (MVP):
- Italian (IT) - Primary
- English (EN) - International
- German (DE) - Central European HEMA community

**Features Used**:
- Server-side translations
- Dynamic locale routing
- Language switcher component
- Locale-specific metadata for SEO

---

### Date/Time: Luxon

**What**: Modern date/time library based on Intl API

**Why**:
- **Timezone Support**: Superior to date-fns for timezone handling
- **Immutable API**: Safer than Moment.js
- **International**: Built on browser's Intl API
- **Lightweight**: No locale files needed
- **ISO 8601**: Standard date string parsing

**Use Cases**:
- Converting event times from UTC to user timezone
- Storing times in UTC, displaying in local timezone
- Parsing user input in their timezone
- Handling DST (Daylight Saving Time) transitions

**Why Not date-fns?**
- Luxon has better timezone support out of the box
- Luxon's API is more intuitive for timezone operations
- date-fns requires additional libraries for full timezone support

---

### Forms: react-hook-form + zod

**What**: Form management + schema validation

**Why**:
- **react-hook-form**:
  - Minimal re-renders (performance)
  - Uncontrolled components (less state)
  - Built-in validation
  - TypeScript support
  - Small bundle size

- **zod**:
  - Type-safe schema validation
  - Runtime type checking
  - Automatic TypeScript inference
  - Composable schemas
  - Custom error messages

**Use Cases**:
- Event creation form with validation
- Society profile editing
- Erasmus booking forms
- Affiliation requests
- Admin forms

**Example Flow**:
```typescript
// Define schema
const eventSchema = z.object({
  title: z.string().min(3),
  event_type: z.enum(['gara', 'sparring', 'seminario', 'allenamento_aperto']),
  start_datetime: z.date(),
})

// Infer TypeScript type
type EventInput = z.infer<typeof eventSchema>

// Use in form
const form = useForm<EventInput>({
  resolver: zodResolver(eventSchema)
})
```

---

### UI Components: Radix UI (via shadcn/ui)

**What**: Unstyled, accessible component primitives

**Why**:
- **Accessibility**: WAI-ARIA compliant
- **Unstyled**: Full control over design
- **Composable**: Build complex UIs from primitives
- **TypeScript**: Full type safety
- **No Runtime CSS**: Works with Tailwind

**Components Used**:
- Dialog (modals for confirmations)
- Dropdown Menu (user menus)
- Select (form dropdowns)
- Checkbox (consents, filters)
- Popover (date pickers, tooltips)

---

### Calendar UI: react-big-calendar

**What**: Calendar component for displaying events

**Why**:
- **Mature Library**: Battle-tested, widely used
- **Multiple Views**: Month, week, day, agenda
- **Customizable**: Full control over rendering
- **Event Handling**: Click, drag-and-drop (future)
- **Timezone Aware**: Works with Luxon

**Use Cases**:
- Events calendar page (month/week view)
- Erasmus slots visualization
- Admin event moderation view

**Alternative Considered**: FullCalendar
- Rejected: react-big-calendar is lighter and more React-friendly

---

### State Management: Zustand (Optional)

**What**: Lightweight state management library

**Why**:
- **Minimal**: Only when needed (most state is server-side)
- **Simple API**: Easy to learn and use
- **No Boilerplate**: Less code than Redux
- **TypeScript**: Full type safety
- **Small Bundle**: ~1KB

**When to Use**:
- Multi-step form wizards (event creation)
- UI state (modals, sidebars)
- Optimistic updates

**When NOT to Use**:
- Server state (use Server Actions instead)
- URL state (use searchParams)
- Simple component state (use useState)

**Alternative Considered**: React Context
- Zustand is simpler for non-trivial state

---

## Hosting & Deployment

### Frontend: Vercel

**What**: Platform for deploying Next.js applications

**Why**:
- **Free Tier**: 100GB bandwidth, 100hrs serverless execution
- **Next.js Native**: Built by the same team
- **Zero Config**: Deploy with git push
- **Edge Network**: Fast global CDN
- **Preview Deployments**: Automatic PR previews
- **Analytics**: Built-in performance monitoring

**Free Tier Limits**:
- 100GB bandwidth/month
- 100 hours serverless function execution/month
- Unlimited preview deployments

**Deployment Flow**:
```bash
git push origin main
# Automatic deployment via Vercel GitHub integration
```

---

### Database: Supabase

**What**: PostgreSQL hosting with built-in features

**Why**:
- **Free Tier**: 500MB storage, 50K users
- **Managed**: Auto backups, updates
- **Dashboard**: GUI for database management
- **Real-time**: WebSockets for live updates (future)
- **Storage**: File uploads (logos, images)

---

## Development Tools

### TypeScript

**Version**: 5.4+

**Why**:
- Type safety for large codebase
- Better IDE support (autocomplete, refactoring)
- Catch errors at compile time
- Self-documenting code

---

### ESLint + Prettier

**Why**:
- **ESLint**: Code quality, catch bugs
- **Prettier**: Consistent formatting
- **Integration**: Works with Next.js, TypeScript

**Config**: Next.js defaults + Tailwind plugin

---

### Git

**Version Control**: GitHub

**Why**:
- Industry standard
- Vercel integration
- Issue tracking
- Pull request reviews

---

## Libraries Summary

### Production Dependencies

```json
{
  "next": "^14.2.0",
  "react": "^18.3.0",
  "react-dom": "^18.3.0",
  "@supabase/supabase-js": "^2.39.0",
  "@supabase/ssr": "^0.1.0",
  "next-intl": "^3.9.0",
  "luxon": "^3.4.0",
  "react-hook-form": "^7.50.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "tailwindcss": "^3.4.0",
  "@radix-ui/react-dialog": "^1.0.5",
  "@radix-ui/react-dropdown-menu": "^2.0.6",
  "@radix-ui/react-select": "^2.0.0",
  "react-big-calendar": "^1.11.0",
  "clsx": "^2.1.0",
  "tailwind-merge": "^2.2.0",
  "zustand": "^4.5.0"
}
```

### Development Dependencies

```json
{
  "typescript": "^5.4.0",
  "@types/node": "^20.0.0",
  "@types/react": "^18.3.0",
  "@types/luxon": "^3.4.0",
  "eslint": "^8.57.0",
  "eslint-config-next": "^14.2.0",
  "prettier": "^3.2.0",
  "prettier-plugin-tailwindcss": "^0.5.0"
}
```

---

## Technology Decisions Summary

| Requirement | Technology | Rationale |
|------------|-----------|-----------|
| Framework | Next.js 14+ | SSR for SEO, App Router, Server Actions |
| Database | PostgreSQL (Supabase) | Relational model, RLS, free tier |
| Auth | Supabase Auth | Integrated, SSR-compatible, free |
| Styling | TailwindCSS + shadcn/ui | Rapid development, accessibility |
| i18n | next-intl | App Router native, SEO-friendly |
| Date/Time | Luxon | Superior timezone support |
| Forms | react-hook-form + zod | Performance, type safety |
| Calendar | react-big-calendar | Mature, customizable |
| State | Zustand (optional) | Lightweight, minimal use |
| Hosting | Vercel + Supabase | Free tiers, zero config |

---

## Future Considerations

### Post-MVP Technologies

- **Geocoding**: Nominatim (free) or Google Geocoding API for distance filters
- **Email**: Resend or SendGrid (free tier) for transactional emails
- **Analytics**: Plausible or Umami (privacy-friendly, self-hosted)
- **Error Tracking**: Sentry (free tier) for production monitoring
- **Image CDN**: Cloudinary (free tier) for user-uploaded images

### Deferred Features

- Real-time updates (Supabase real-time subscriptions)
- File uploads (Supabase Storage)
- Advanced search (Algolia or Meilisearch)
- Maps (Leaflet + OpenStreetMap, free)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   USER BROWSER                          │
├─────────────────────────────────────────────────────────┤
│  Next.js 14 (React 18)                                  │
│  - Server Components (SSR)                              │
│  - Client Components (Interactive UI)                   │
│  - next-intl (i18n)                                     │
│  - TailwindCSS + shadcn/ui                             │
└─────────────────────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────┐
│              VERCEL (Edge Network)                      │
│  - Serverless Functions                                 │
│  - Edge Middleware (auth + i18n)                        │
│  - CDN (static assets)                                  │
└─────────────────────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────┐
│                 SUPABASE                                │
├─────────────────────────────────────────────────────────┤
│  PostgreSQL Database                                    │
│  - Row Level Security (RLS)                             │
│  - Full-text search                                     │
│  - Indexes for performance                              │
│                                                         │
│  Supabase Auth                                          │
│  - Email/password                                       │
│  - Session management                                   │
│  - JWT tokens                                           │
└─────────────────────────────────────────────────────────┘
```

---

## Development Environment

### Required Tools

- **Node.js**: 20.x LTS
- **npm**: 10.x (or pnpm/yarn)
- **Git**: Latest version
- **VS Code** (recommended): With extensions:
  - ESLint
  - Prettier
  - Tailwind CSS IntelliSense
  - TypeScript

### Setup Commands

```bash
# Install Node.js 20.x
# Install Git
# Clone repository
git clone <repo-url>

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Add Supabase keys to .env.local

# Run development server
npm run dev

# Open http://localhost:3000
```

---

## References

- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [next-intl Documentation](https://next-intl-docs.vercel.app/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [shadcn/ui Documentation](https://ui.shadcn.com/)
- [Luxon Documentation](https://moment.github.io/luxon/)
- [react-hook-form Documentation](https://react-hook-form.com/)
- [Zod Documentation](https://zod.dev/)
