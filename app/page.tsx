// Root path should redirect to the default locale to keep language prefixes in URLs
import { redirect } from 'next/navigation'

export default function RootPage() {
  // Mirror middleware defaultLocale ('it')
  redirect('/it')
}
