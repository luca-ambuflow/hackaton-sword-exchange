import { getRequestConfig } from 'next-intl/server'
import { notFound } from 'next/navigation'

// Supported locales for the application
export const locales = ['it', 'en', 'de'] as const
export type Locale = (typeof locales)[number]
export const defaultLocale: Locale = 'it'

export default getRequestConfig(async ({ requestLocale }) => {
  // Await the locale from requestLocale
  const locale = await requestLocale
  
  // Validate that the incoming `locale` parameter is valid
  if (!locales.includes(locale as Locale)) notFound()

  return {
    messages: (await import(`./messages/${locale}.json`)).default,
  }
})
