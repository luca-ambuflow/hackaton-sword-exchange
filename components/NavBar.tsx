"use client"

import { Link } from '@/i18n/navigation'
import { useEffect, useState } from 'react'
import { createSupabaseBrowserClient } from '@/lib/supabase/client'
import { Group, Container, Button, Text, Box } from '@mantine/core'
import { signOutAction } from '@/app/[locale]/(public)/auth/actions'
import { useTranslations } from 'next-intl'
import LanguageSwitcher from '@/components/LanguageSwitcher'

export default function NavBar() {
  const t = useTranslations('nav')
  const [fullName, setFullName] = useState<string | null>(null)
  const [isAdmin, setIsAdmin] = useState(false)

  useEffect(() => {
    const supabase = createSupabaseBrowserClient()

    async function loadUser() {
      const { data: userRes } = await supabase.auth.getUser()
      const user = userRes.user
      if (!user) {
        setFullName(null)
        setIsAdmin(false)
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

      // Check if user is platform admin
      const { data: adminRole } = await supabase
        .from('user_roles')
        .select('role')
        .eq('user_id', user.id)
        .eq('role', 'platform_admin')
        .maybeSingle()

      setIsAdmin(!!adminRole)
    }

    loadUser()

    // Optionally subscribe to auth state changes to update name after login
    const { data: subscription } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!session?.user) {
        setFullName(null)
        setIsAdmin(false)
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
    <Box component="nav" style={{ borderBottom: '1px solid var(--mantine-color-default-border)', backgroundColor: 'var(--mantine-color-body)', backdropFilter: 'blur(10px)' }}>
      <Container size="lg" py="md">
        <Group justify="space-between" wrap="wrap">
          <Text size="lg" fw={600} component={Link} href="/" style={{ textDecoration: 'none', color: 'inherit' }}>
            {t('swords')}
          </Text>
          <Group gap="md" wrap="wrap">
            <Text size="sm" component={Link} href="/societies" style={{ textDecoration: 'none', color: 'inherit' }}>
              {t('societies')}
            </Text>
            <Text size="sm" component={Link} href="/events" style={{ textDecoration: 'none', color: 'inherit' }}>
              {t('events')}
            </Text>
            {isAdmin && (
              <Text size="sm" component={Link} href="/admin" style={{ textDecoration: 'none', color: 'inherit' }}>
                {t('admin')}
              </Text>
            )}
            {fullName ? (
              <Group gap="xs">
                <Button variant="light" size="compact-sm" component={Link} href="/account" title={fullName}>
                  {fullName}
                </Button>
                <Button
                  variant="subtle"
                  size="compact-sm"
                  onClick={signOutAction}
                >
                  {t('logOut')}
                </Button>
              </Group>
            ) : (
              <Button variant="filled" color="dark" size="compact-sm" component={Link} href="/auth/sign-in">
                {t('logIn')}
              </Button>
            )}
            <LanguageSwitcher />
          </Group>
        </Group>
      </Container>
    </Box>
  )
}
