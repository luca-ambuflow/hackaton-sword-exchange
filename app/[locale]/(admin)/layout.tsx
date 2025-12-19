import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale, getTranslations } from 'next-intl/server'
import { redirect, Link } from '@/i18n/navigation'
import { Container, Group, Title, Text, Button, Box, Paper } from '@mantine/core'
import AdminTabs from './AdminTabs'

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createSupabaseServerClient()
  const locale = await getLocale()
  const t = await getTranslations('admin')

  // Check if user is authenticated
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect({ href: '/auth/sign-in', locale })
  }

  // Check if user has platform_admin role
  const { data: roles } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', user!.id)
    .eq('role', 'platform_admin')
    .single()

  if (!roles) {
    // User is not a platform admin, redirect to home
    redirect({ href: '/', locale })
  }

  return (
    <Box mih="100vh">
      <Paper shadow="xs" p="md" mb="lg">
        <Container size="lg">
          <Group justify="space-between" mb="md">
            <Title order={2}>{t('title')}</Title>
            <Group gap="sm">
              <Text size="sm" c="dimmed">{user!.email}</Text>
              <Link href="/" style={{ textDecoration: 'none' }}>
                <Button variant="subtle" size="compact-sm">
                  {t('backToSite')}
                </Button>
              </Link>
            </Group>
          </Group>
          <AdminTabs />
        </Container>
      </Paper>
      <Container size="lg">
        {children}
      </Container>
    </Box>
  )
}
