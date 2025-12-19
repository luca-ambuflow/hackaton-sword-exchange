import type { Metadata } from 'next'
import { NextIntlClientProvider } from 'next-intl'
import { getMessages } from 'next-intl/server'
import { notFound } from 'next/navigation'
import { Inter } from 'next/font/google'
import { locales, type Locale } from '@/i18n/navigation'
import NavBar from '@/components/NavBar'
import { MantineProvider, ColorSchemeScript, Container } from '@mantine/core'
import { theme } from '@/lib/theme'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Historical Fencing Portal',
  description:
    'A community hub for HEMA societies, events and Erasmus. Built with Next.js, Supabase and next-intl.',
}

export function generateStaticParams() {
  return locales.map((locale) => ({ locale }))
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ locale: string }>
}) {
  // Await params in Next.js 15
  const { locale } = await params

  // Validate locale
  if (!locales.includes(locale as Locale)) {
    notFound()
  }

  // Get messages from next-intl
  const messages = await getMessages()

  return (
    <html lang={locale}>
      <head>
        <ColorSchemeScript defaultColorScheme="dark" />
      </head>
      <body className={inter.className}>
        <MantineProvider theme={theme} defaultColorScheme="dark">
          <NextIntlClientProvider locale={locale} messages={messages}>
            <NavBar />
            <Container component="main" size="lg" py="xl">{children}</Container>
          </NextIntlClientProvider>
        </MantineProvider>
      </body>
    </html>
  )
}
