import createMiddleware from 'next-intl/middleware'
import { routing } from './i18n/navigation'

export default createMiddleware(routing)

export const config = {
  // Match all pathnames except for
  // - /api routes
  // - /_next (Next.js internals)
  // - /_vercel (Vercel internals)
  // - Static files (e.g. /favicon.ico, /robots.txt, etc.)
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)'],
}
