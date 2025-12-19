# Implementation Phases - Detailed Breakdown

This document provides step-by-step instructions for each implementation phase.

---

## Current Status

As of now, all setup steps including running the database migrations have been completed.

- Next.js project initialized: completed
- Repository and tooling (TypeScript, Tailwind): completed
- Supabase project created and environment variables configured: completed
- Supabase browser/server clients added under `src/lib/supabase`: completed
- i18n scaffolding and base configuration: completed
- Database migrations: completed

Next step: implement Phase 1 (societies pages and email/password auth).

## Phase 0: Foundation (Week 1)

### Goal
Set up project infrastructure with authentication and internationalization.

### Prerequisites
- Node.js 20.x installed
- Git installed
- Supabase account created
- GitHub repository created

---

### Step 1: Initialize Next.js Project

```bash
# Create Next.js project with TypeScript and App Router
npx create-next-app@latest swords \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*"

cd swords

# Initialize git if not already done
git init
git add .
git commit -m "chore: initialize Next.js project"
```

**Files Created**:
- `next.config.js`
- `tailwind.config.ts`
- `tsconfig.json`
- `package.json`
- `src/app/layout.tsx`
- `src/app/page.tsx`

---

### Step 2: Set Up Supabase

**A. Create Supabase Project**:
1. Go to https://supabase.com
2. Create new project
3. Note: `Project URL` and `anon public key`

**B. Configure Environment Variables**:

```bash
# Create .env.local
cp .env.example .env.local
```

`.env.local`:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

`.env.example`:
```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SITE_URL=
```

**C. Install Supabase Packages**:

```bash
npm install @supabase/supabase-js @supabase/ssr
```

**D. Create Supabase Clients**:

`/src/lib/supabase/client.ts`:
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

`/src/lib/supabase/server.ts`:
```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.set({ name, value: '', ...options })
        },
      },
    }
  )
}
```

---

### Step 3: Create Database Schema

**A. Create Migrations Folder**:

```bash
mkdir -p supabase/migrations
```

**B. Create Initial Schema**:

`/supabase/migrations/001_initial_schema.sql`:
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  preferred_language TEXT DEFAULT 'it' CHECK (preferred_language IN ('it', 'en', 'de')),
  timezone TEXT DEFAULT 'Europe/Rome',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User roles
CREATE TYPE user_role AS ENUM ('user', 'society_manager', 'platform_admin');

CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

-- User consents
CREATE TABLE public.user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  consent_type TEXT NOT NULL,
  granted BOOLEAN DEFAULT FALSE,
  granted_at TIMESTAMPTZ,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, consent_type)
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- RLS Policies for user_roles
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policies for user_consents
CREATE POLICY "Users can view their own consents"
  ON public.user_consents FOR SELECT
  USING (auth.uid() = user_id);

-- Function to auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');

  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user');

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call function on user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Indexes
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX idx_user_roles_role ON public.user_roles(role);
```

**C. Run Migration**:

In Supabase Dashboard:
1. Go to SQL Editor
2. Paste contents of `001_initial_schema.sql`
3. Click "Run"

Or use Supabase CLI:
```bash
supabase db push
```

---

### Step 4: Configure next-intl (i18n)

**A. Install next-intl**:

```bash
npm install next-intl
```

**B. Create i18n Configuration**:

Create folder structure:
```bash
mkdir -p src/i18n/locales
```

`/src/i18n/routing.ts`:
```typescript
import { defineRouting } from 'next-intl/routing'

export const routing = defineRouting({
  locales: ['it', 'en', 'de'],
  defaultLocale: 'it',
  localePrefix: 'always'
})

export const { Link, redirect, usePathname, useRouter } = routing
```

`/src/i18n/request.ts`:
```typescript
import { getRequestConfig } from 'next-intl/server'
import { routing } from './routing'

export default getRequestConfig(async ({ locale }) => {
  if (!routing.locales.includes(locale as any)) {
    return { messages: {} }
  }

  return {
    messages: (await import(`./locales/${locale}.json`)).default
  }
})
```

**C. Create Translation Files**:

`/src/i18n/locales/it.json`:
```json
{
  "common": {
    "appName": "Portale Scherma Storica",
    "login": "Accedi",
    "register": "Registrati",
    "logout": "Esci",
    "home": "Home",
    "save": "Salva",
    "cancel": "Annulla"
  },
  "navigation": {
    "home": "Home",
    "societies": "Società",
    "events": "Eventi",
    "erasmus": "Erasmus"
  },
  "auth": {
    "loginTitle": "Accedi",
    "registerTitle": "Registrati",
    "email": "Email",
    "password": "Password",
    "fullName": "Nome completo",
    "loginButton": "Accedi",
    "registerButton": "Registrati"
  }
}
```

`/src/i18n/locales/en.json`:
```json
{
  "common": {
    "appName": "Historical Fencing Portal",
    "login": "Login",
    "register": "Register",
    "logout": "Logout",
    "home": "Home",
    "save": "Save",
    "cancel": "Cancel"
  },
  "navigation": {
    "home": "Home",
    "societies": "Societies",
    "events": "Events",
    "erasmus": "Erasmus"
  },
  "auth": {
    "loginTitle": "Login",
    "registerTitle": "Register",
    "email": "Email",
    "password": "Password",
    "fullName": "Full Name",
    "loginButton": "Login",
    "registerButton": "Register"
  }
}
```

`/src/i18n/locales/de.json`:
```json
{
  "common": {
    "appName": "Historisches Fechten Portal",
    "login": "Anmelden",
    "register": "Registrieren",
    "logout": "Abmelden",
    "home": "Startseite",
    "save": "Speichern",
    "cancel": "Abbrechen"
  },
  "navigation": {
    "home": "Startseite",
    "societies": "Vereine",
    "events": "Veranstaltungen",
    "erasmus": "Erasmus"
  },
  "auth": {
    "loginTitle": "Anmelden",
    "registerTitle": "Registrieren",
    "email": "E-Mail",
    "password": "Passwort",
    "fullName": "Vollständiger Name",
    "loginButton": "Anmelden",
    "registerButton": "Registrieren"
  }
}
```

**D. Update next.config.js**:

```javascript
const withNextIntl = require('next-intl/plugin')('./src/i18n/request.ts')

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['supabase.co'], // Add Supabase storage domain
  },
}

module.exports = withNextIntl(nextConfig)
```

---

### Step 5: Create Middleware (Auth + i18n)

`/src/middleware.ts`:
```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import createMiddleware from 'next-intl/middleware'
import { routing } from './i18n/routing'

const intlMiddleware = createMiddleware(routing)

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          response.cookies.set({
            name,
            value,
            ...options,
          })
        },
        remove(name: string, options: CookieOptions) {
          response.cookies.set({
            name,
            value: '',
            ...options,
          })
        },
      },
    }
  )

  const {
    data: { session },
  } = await supabase.auth.getSession()

  // Protected routes
  const protectedPaths = ['/dashboard', '/society-admin', '/admin']
  const isProtectedRoute = protectedPaths.some((path) =>
    request.nextUrl.pathname.includes(path)
  )

  if (isProtectedRoute && !session) {
    const loginUrl = new URL('/auth/login', request.url)
    return NextResponse.redirect(loginUrl)
  }

  // Apply i18n middleware
  return intlMiddleware(request)
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
```

---

### Step 6: Restructure App for i18n

**A. Move app folder**:

```bash
mkdir -p src/app/[locale]
mv src/app/page.tsx src/app/[locale]/page.tsx
mv src/app/layout.tsx src/app/[locale]/layout.tsx
```

**B. Update Root Layout**:

`/src/app/[locale]/layout.tsx`:
```typescript
import { NextIntlClientProvider } from 'next-intl'
import { getMessages } from 'next-intl/server'
import { Inter } from 'next/font/google'
import '../globals.css'

const inter = Inter({ subsets: ['latin'] })

export default async function RootLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode
  params: { locale: string }
}) {
  const messages = await getMessages()

  return (
    <html lang={locale}>
      <body className={inter.className}>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  )
}
```

---

### Step 7: Install shadcn/ui

```bash
npx shadcn-ui@latest init
```

Answer prompts:
- Style: Default
- Base color: Slate
- CSS variables: Yes

Install core components:
```bash
npx shadcn-ui@latest add button input select dialog dropdown-menu checkbox card label
```

---

### Step 8: Create Authentication Pages

**A. Install Form Libraries**:

```bash
npm install react-hook-form zod @hookform/resolvers
```

**B. Create Auth Pages**:

Create folder:
```bash
mkdir -p src/app/[locale]/auth/login
mkdir -p src/app/[locale]/auth/register
mkdir -p src/app/[locale]/auth/callback
```

`/src/app/[locale]/auth/login/page.tsx`:
```typescript
import { LoginForm } from '@/components/auth/login-form'
import { useTranslations } from 'next-intl'

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-md">
        <LoginForm />
      </div>
    </div>
  )
}
```

`/src/app/[locale]/auth/register/page.tsx`:
```typescript
import { RegisterForm } from '@/components/auth/register-form'

export default function RegisterPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-full max-w-md">
        <RegisterForm />
      </div>
    </div>
  )
}
```

`/src/app/[locale]/auth/callback/route.ts`:
```typescript
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = createClient()
    await supabase.auth.exchangeCodeForSession(code)
  }

  return NextResponse.redirect(new URL('/dashboard', request.url))
}
```

**C. Create Auth Components**:

Create folder:
```bash
mkdir -p src/components/auth
```

`/src/components/auth/login-form.tsx`:
```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { useTranslations } from 'next-intl'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function LoginForm() {
  const t = useTranslations('auth')
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const supabase = createClient()
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      setError(error.message)
      setLoading(false)
    } else {
      router.push('/dashboard')
      router.refresh()
    }
  }

  return (
    <form onSubmit={handleLogin} className="space-y-4">
      <h1 className="text-2xl font-bold">{t('loginTitle')}</h1>

      <div>
        <Label htmlFor="email">{t('email')}</Label>
        <Input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </div>

      <div>
        <Label htmlFor="password">{t('password')}</Label>
        <Input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? 'Loading...' : t('loginButton')}
      </Button>
    </form>
  )
}
```

`/src/components/auth/register-form.tsx`:
```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { useTranslations } from 'next-intl'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function RegisterForm() {
  const t = useTranslations('auth')
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [fullName, setFullName] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const supabase = createClient()
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    })

    if (error) {
      setError(error.message)
      setLoading(false)
    } else {
      router.push('/dashboard')
      router.refresh()
    }
  }

  return (
    <form onSubmit={handleRegister} className="space-y-4">
      <h1 className="text-2xl font-bold">{t('registerTitle')}</h1>

      <div>
        <Label htmlFor="fullName">{t('fullName')}</Label>
        <Input
          id="fullName"
          type="text"
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          required
        />
      </div>

      <div>
        <Label htmlFor="email">{t('email')}</Label>
        <Input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </div>

      <div>
        <Label htmlFor="password">{t('password')}</Label>
        <Input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          minLength={6}
        />
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <Button type="submit" className="w-full" disabled={loading}>
        {loading ? 'Loading...' : t('registerButton')}
      </Button>
    </form>
  )
}
```

---

### Step 9: Create Base Layout Components

Create folders:
```bash
mkdir -p src/components/layout
```

`/src/components/layout/header.tsx`:
```typescript
import { Link } from '@/i18n/routing'
import { useTranslations } from 'next-intl'
import { LanguageSwitcher } from './language-switcher'

export function Header() {
  const t = useTranslations('navigation')
  const tCommon = useTranslations('common')

  return (
    <header className="border-b">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-8">
          <Link href="/" className="text-xl font-bold">
            {tCommon('appName')}
          </Link>

          <nav className="flex gap-6">
            <Link href="/societies">{t('societies')}</Link>
            <Link href="/events">{t('events')}</Link>
            <Link href="/erasmus">{t('erasmus')}</Link>
          </nav>
        </div>

        <div className="flex items-center gap-4">
          <LanguageSwitcher />
          <Link href="/auth/login">{tCommon('login')}</Link>
        </div>
      </div>
    </header>
  )
}
```

`/src/components/layout/language-switcher.tsx`:
```typescript
'use client'

import { useLocale } from 'next-intl'
import { useRouter, usePathname } from '@/i18n/routing'

export function LanguageSwitcher() {
  const locale = useLocale()
  const router = useRouter()
  const pathname = usePathname()

  const changeLanguage = (newLocale: string) => {
    router.replace(pathname, { locale: newLocale })
  }

  return (
    <select
      value={locale}
      onChange={(e) => changeLanguage(e.target.value)}
      className="rounded border px-2 py-1"
    >
      <option value="it">IT</option>
      <option value="en">EN</option>
      <option value="de">DE</option>
    </select>
  )
}
```

`/src/components/layout/footer.tsx`:
```typescript
export function Footer() {
  return (
    <footer className="border-t py-8">
      <div className="container mx-auto px-4 text-center text-sm text-gray-600">
        © 2025 Scherma Storica Portal
      </div>
    </footer>
  )
}
```

---

### Step 10: Update Root Layout with Header/Footer

`/src/app/[locale]/layout.tsx`:
```typescript
import { NextIntlClientProvider } from 'next-intl'
import { getMessages } from 'next-intl/server'
import { Inter } from 'next/font/google'
import { Header } from '@/components/layout/header'
import { Footer } from '@/components/layout/footer'
import '../globals.css'

const inter = Inter({ subsets: ['latin'] })

export default async function RootLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode
  params: { locale: string }
}) {
  const messages = await getMessages()

  return (
    <html lang={locale}>
      <body className={inter.className}>
        <NextIntlClientProvider messages={messages}>
          <Header />
          <main className="min-h-screen">{children}</main>
          <Footer />
        </NextIntlClientProvider>
      </body>
    </html>
  )
}
```

---

### Step 11: Test Phase 0

```bash
# Start development server
npm run dev

# Visit http://localhost:3000
# Test:
# - Language switcher (IT/EN/DE)
# - Register new user
# - Login
# - Session persistence (refresh page)
# - Logout
```

---

### Phase 0 Deliverables

✅ Next.js 14 project initialized
✅ Supabase connected
✅ Database schema created
✅ next-intl configured (IT, EN, DE)
✅ Authentication working (register, login, logout)
✅ Middleware configured (auth + i18n)
✅ Base layouts (header, footer)
✅ shadcn/ui installed

**Next Phase**: [Phase 1 - Society Directory](#phase-1-society-directory-week-2)

---

## Phase 1: Society Directory (Week 2)

### Goal
Build public society directory with list view, detail pages, and filters.

### Prerequisites
- Phase 0 completed
- Database migrations run

---

### Step 1: Create Society Database Migration

`/supabase/migrations/002_societies.sql`:
```sql
-- Societies table
CREATE TABLE public.societies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,

  -- Required
  ragione_sociale TEXT NOT NULL,
  codice_fiscale TEXT NOT NULL UNIQUE,
  sede TEXT NOT NULL,

  -- Optional
  partita_iva TEXT,
  phone TEXT,
  email TEXT,
  website TEXT,
  disciplines TEXT,
  description TEXT,

  -- Location
  region TEXT,
  province TEXT,
  city TEXT,
  address TEXT,
  postal_code TEXT,

  -- Metadata
  logo_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Society administrators
CREATE TABLE public.society_administrators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'admin',
  approved_by UUID REFERENCES public.profiles(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(society_id, user_id)
);

-- Enable RLS
ALTER TABLE public.societies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.society_administrators ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Societies are viewable by everyone"
  ON public.societies FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "Society admins can update their society"
  ON public.societies FOR UPDATE
  USING (
    id IN (
      SELECT society_id FROM public.society_administrators
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Society admins can view their admin records"
  ON public.society_administrators FOR SELECT
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_societies_slug ON public.societies(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_region_province ON public.societies(region, province) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_created_at ON public.societies(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_societies_search ON public.societies
  USING GIN(to_tsvector('italian', ragione_sociale || ' ' || COALESCE(description, '')));

CREATE INDEX idx_society_administrators_society ON public.society_administrators(society_id);
CREATE INDEX idx_society_administrators_user ON public.society_administrators(user_id);

-- Trigger for updated_at
CREATE TRIGGER update_societies_updated_at
  BEFORE UPDATE ON public.societies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

Run migration in Supabase Dashboard SQL Editor.

---

### Step 2: Create Utility Functions

`/src/lib/utils/slugify.ts`:
```typescript
export function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}
```

---

### Step 3: Create Server Actions

Create folder:
```bash
mkdir -p src/actions/societies
```

`/src/actions/societies/get-societies.ts`:
```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

interface SocietyFilters {
  region?: string
  province?: string
  search?: string
  limit?: number
  offset?: number
}

export async function getSocieties(filters: SocietyFilters = {}) {
  const supabase = createClient()
  const { region, province, search, limit = 20, offset = 0 } = filters

  let query = supabase
    .from('societies')
    .select('*', { count: 'exact' })
    .is('deleted_at', null)
    .order('created_at', { ascending: false })

  if (region) {
    query = query.eq('region', region)
  }

  if (province) {
    query = query.eq('province', province)
  }

  if (search) {
    query = query.ilike('ragione_sociale', `%${search}%`)
  }

  const { data, error, count } = await query.range(offset, offset + limit - 1)

  if (error) throw error

  return { societies: data || [], count: count || 0 }
}
```

`/src/actions/societies/get-society-by-slug.ts`:
```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function getSocietyBySlug(slug: string) {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('societies')
    .select('*')
    .eq('slug', slug)
    .is('deleted_at', null)
    .single()

  if (error) throw error

  return data
}
```

---

### Step 4: Create Society Pages

**A. List Page**:

Create folder:
```bash
mkdir -p src/app/[locale]/societies
```

`/src/app/[locale]/societies/page.tsx`:
```typescript
import { getSocieties } from '@/actions/societies/get-societies'
import { SocietyCard } from '@/components/societies/society-card'
import { SocietyFilters } from '@/components/societies/society-filters'
import { useTranslations } from 'next-intl'

export default async function SocietiesPage({
  searchParams,
}: {
  searchParams: { region?: string; province?: string; search?: string }
}) {
  const t = useTranslations('societies')
  const { societies } = await getSocieties(searchParams)

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="mb-8 text-3xl font-bold">{t('title')}</h1>

      <SocietyFilters />

      <div className="mt-8 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {societies.map((society) => (
          <SocietyCard key={society.id} society={society} />
        ))}
      </div>

      {societies.length === 0 && (
        <p className="text-center text-gray-500">{t('noResults')}</p>
      )}
    </div>
  )
}

export const metadata = {
  title: 'Società di Scherma Storica - Historical Fencing Societies',
  description: 'Directory of historical fencing schools and associations',
}
```

**B. Detail Page**:

Create folder:
```bash
mkdir -p src/app/[locale]/societies/[slug]
```

`/src/app/[locale]/societies/[slug]/page.tsx`:
```typescript
import { getSocietyBySlug } from '@/actions/societies/get-society-by-slug'
import { notFound } from 'next/navigation'
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const society = await getSocietyBySlug(params.slug)

  return {
    title: `${society.ragione_sociale} - Scherma Storica Portal`,
    description: society.description || `${society.ragione_sociale} - ${society.city}, ${society.region}`,
  }
}

export default async function SocietyPage({
  params,
}: {
  params: { slug: string }
}) {
  let society
  try {
    society = await getSocietyBySlug(params.slug)
  } catch {
    notFound()
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="mb-4 text-3xl font-bold">{society.ragione_sociale}</h1>

      <div className="grid gap-8 lg:grid-cols-3">
        <div className="lg:col-span-2">
          {society.description && (
            <div className="mb-6">
              <h2 className="mb-2 text-xl font-semibold">Descrizione</h2>
              <p>{society.description}</p>
            </div>
          )}

          {society.disciplines && (
            <div className="mb-6">
              <h2 className="mb-2 text-xl font-semibold">Discipline</h2>
              <p>{society.disciplines}</p>
            </div>
          )}
        </div>

        <div className="rounded-lg border p-6">
          <h2 className="mb-4 text-xl font-semibold">Informazioni</h2>

          <dl className="space-y-2">
            <div>
              <dt className="font-medium">Sede</dt>
              <dd className="text-gray-600">{society.sede}</dd>
            </div>

            {society.city && (
              <div>
                <dt className="font-medium">Città</dt>
                <dd className="text-gray-600">
                  {society.city}, {society.province}
                </dd>
              </div>
            )}

            {society.email && (
              <div>
                <dt className="font-medium">Email</dt>
                <dd className="text-gray-600">{society.email}</dd>
              </div>
            )}

            {society.phone && (
              <div>
                <dt className="font-medium">Telefono</dt>
                <dd className="text-gray-600">{society.phone}</dd>
              </div>
            )}

            {society.website && (
              <div>
                <dt className="font-medium">Sito web</dt>
                <dd>
                  <a
                    href={society.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:underline"
                  >
                    {society.website}
                  </a>
                </dd>
              </div>
            )}
          </dl>
        </div>
      </div>
    </div>
  )
}
```

---

### Step 5: Create Society Components

Create folder:
```bash
mkdir -p src/components/societies
```

`/src/components/societies/society-card.tsx`:
```typescript
import { Link } from '@/i18n/routing'
import type { Database } from '@/types/database.types'

type Society = Database['public']['Tables']['societies']['Row']

export function SocietyCard({ society }: { society: Society }) {
  return (
    <Link href={`/societies/${society.slug}`}>
      <div className="rounded-lg border p-6 transition hover:shadow-lg">
        <h3 className="mb-2 text-xl font-semibold">{society.ragione_sociale}</h3>

        <p className="mb-4 text-sm text-gray-600">
          {society.city}, {society.province}
        </p>

        {society.description && (
          <p className="line-clamp-3 text-sm text-gray-700">{society.description}</p>
        )}
      </div>
    </Link>
  )
}
```

`/src/components/societies/society-filters.tsx`:
```typescript
'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function SocietyFilters() {
  const router = useRouter()
  const searchParams = useSearchParams()

  const updateFilter = (key: string, value: string) => {
    const params = new URLSearchParams(searchParams)
    if (value) {
      params.set(key, value)
    } else {
      params.delete(key)
    }
    router.push(`/societies?${params.toString()}`)
  }

  return (
    <div className="flex gap-4">
      <div className="flex-1">
        <Label htmlFor="search">Cerca</Label>
        <Input
          id="search"
          type="text"
          placeholder="Nome società..."
          defaultValue={searchParams.get('search') || ''}
          onChange={(e) => updateFilter('search', e.target.value)}
        />
      </div>
    </div>
  )
}
```

---

### Step 6: Add Translations

Update `/src/i18n/locales/it.json`:
```json
{
  "societies": {
    "title": "Società di Scherma Storica",
    "noResults": "Nessuna società trovata",
    "search": "Cerca per nome"
  }
}
```

---

### Step 7: Test Phase 1

```bash
npm run dev

# Test:
# - Visit /societies
# - See society list
# - Filter by search
# - Click on society card
# - View society detail page at /societies/[slug]
# - Check SEO metadata (view page source)
```

---

### Phase 1 Deliverables (planned)

- Society database tables created
- Society list page with filters
- Society detail pages with SEO
- Server Actions for CRUD operations
- Components (SocietyCard, SocietyFilters)

**Next**: Continue with Phases 2-7 following similar patterns.

Due to length constraints, the remaining phases follow the same detailed breakdown structure. Each phase includes:
- Database migrations
- Server Actions
- Pages (with SEO)
- Components
- Translations
- Testing checklist

---

## Summary

This phased approach ensures:

1. **Incremental progress**: Each phase delivers working features
2. **Clear structure**: Consistent patterns across phases
3. **Quality gates**: Testing before moving forward
4. **Documentation**: Code is self-documenting with TypeScript
5. **SEO focus**: Proper metadata from Phase 1

The detailed breakdown for Phase 0 and Phase 1 serves as a template for implementing the remaining phases (Events Calendar, Verification, Erasmus, Admin, SEO/Performance, Deployment).
