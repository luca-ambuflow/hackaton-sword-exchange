import { createNavigation } from 'next-intl/navigation'
import { defineRouting } from 'next-intl/routing'

export const locales = ['it', 'en', 'de'] as const
export type Locale = (typeof locales)[number]
export const defaultLocale: Locale = 'it'

export const routing = defineRouting({
  locales,
  defaultLocale,
})

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing)
