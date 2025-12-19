"use client"

import { Link } from '@/i18n/navigation'
import { useEffect, useState } from 'react'
import { createSupabaseBrowserClient } from '@/lib/supabase/client'

export default function NavBar() {
  const [fullName, setFullName] = useState<string | null>(null)

  useEffect(() => {
    const supabase = createSupabaseBrowserClient()

    async function loadUser() {
      const { data: userRes } = await supabase.auth.getUser()
      const user = userRes.user
      if (!user) {
        setFullName(null)
        return
      }

      // Try profiles.full_name; fallback to auth metadata if present
      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single()

      const nameFromProfile = profile?.full_name as string | undefined
      const nameFromMeta = (user.user_metadata?.full_name as string | undefined) || (user.user_metadata?.name as string | undefined)
      setFullName(nameFromProfile || nameFromMeta || user.email || 'Account')
    }

    loadUser()

    // Optionally subscribe to auth state changes to update name after login
    const { data: subscription } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!session?.user) {
        setFullName(null)
        return
      }
      // Re-load profile when auth state changes
      loadUser()
    })

    return () => {
      subscription.subscription.unsubscribe()
    }
  }, [])

  return (
    <nav className="w-full border-b bg-white/80 backdrop-blur">
      <div className="mx-auto flex max-w-6xl flex-col gap-2 px-4 py-3 md:flex-row md:items-center md:justify-between">
        <div className="text-lg font-semibold">
          <Link href="/" className="hover:opacity-80">Swords</Link>
        </div>
        <div className="flex flex-col gap-2 md:flex-row md:items-center md:gap-6">
          <Link href="/societies" className="text-sm hover:underline">Societies</Link>
          <Link href="/events" className="text-sm hover:underline">Events</Link>
          {fullName ? (
            <span className="truncate rounded bg-gray-100 px-3 py-1 text-sm text-gray-800" title={fullName}>
              {fullName}
            </span>
          ) : (
            <Link href="/auth/sign-in" className="rounded bg-black px-3 py-1 text-sm text-white hover:opacity-90">
              Log in
            </Link>
          )}
        </div>
      </div>
    </nav>
  )
}
