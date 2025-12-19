import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Link } from '@/i18n/navigation'
import { Title, SimpleGrid, Card, Text, Paper, Stack } from '@mantine/core'
import { getTranslations } from 'next-intl/server'

export default async function AdminDashboard() {
  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('admin')

  // Get pending societies count
  const { count: pendingSocieties } = await supabase
    .from('societies')
    .select('*', { count: 'exact', head: true })
    .eq('approved', false)
    .is('deleted_at', null)

  // Get pending manager requests count
  const { count: pendingManagers } = await supabase
    .from('society_manager_requests')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending')

  // Get total societies count
  const { count: totalSocieties } = await supabase
    .from('societies')
    .select('*', { count: 'exact', head: true })
    .is('deleted_at', null)

  // Get total users count
  const { count: totalUsers } = await supabase
    .from('profiles')
    .select('*', { count: 'exact', head: true })

  return (
    <div>
      <Title order={1} mb="xl">{t('dashboard')}</Title>

      <SimpleGrid cols={{ base: 1, sm: 2, lg: 4 }} spacing="lg" mb="xl">
        {/* Pending Societies Card */}
        <Link href="/admin/societies" style={{ textDecoration: 'none', color: 'inherit' }}>
          <Card shadow="sm" padding="lg" withBorder>
            <Text size="sm" fw={500} c="dimmed" mb="xs">
              {t('pendingSocietyApprovals')}
            </Text>
            <Text size="xl" fw={700} c="orange">
              {pendingSocieties ?? 0}
            </Text>
            <Text size="sm" c="dimmed" mt="xs">
              {t('societiesAwaitingApproval')}
            </Text>
          </Card>
        </Link>

        {/* Pending Manager Requests Card */}
        <Link href="/admin/societies" style={{ textDecoration: 'none', color: 'inherit' }}>
          <Card shadow="sm" padding="lg" withBorder>
            <Text size="sm" fw={500} c="dimmed" mb="xs">
              {t('pendingManagerRequests')}
            </Text>
            <Text size="xl" fw={700} c="blue">
              {pendingManagers ?? 0}
            </Text>
            <Text size="sm" c="dimmed" mt="xs">
              {t('managerRequestsAwaitingReview')}
            </Text>
          </Card>
        </Link>

        {/* Total Societies Card */}
        <Card shadow="sm" padding="lg" withBorder>
          <Text size="sm" fw={500} c="dimmed" mb="xs">
            {t('totalSocieties')}
          </Text>
          <Text size="xl" fw={700} c="green">
            {totalSocieties ?? 0}
          </Text>
          <Text size="sm" c="dimmed" mt="xs">
            {t('activeSocietiesInSystem')}
          </Text>
        </Card>

        {/* Total Users Card */}
        <Link href="/admin/users" style={{ textDecoration: 'none', color: 'inherit' }}>
          <Card shadow="sm" padding="lg" withBorder>
            <Text size="sm" fw={500} c="dimmed" mb="xs">
              {t('totalUsers')}
            </Text>
            <Text size="xl" fw={700} c="grape">
              {totalUsers ?? 0}
            </Text>
            <Text size="sm" c="dimmed" mt="xs">
              {t('registeredUsers')}
            </Text>
          </Card>
        </Link>
      </SimpleGrid>

      <Paper shadow="sm" p="lg" withBorder>
        <Title order={2} size="h3" mb="md">{t('quickActions')}</Title>
        <Stack gap="xs">
          <Link href="/admin/societies" style={{ fontSize: 'var(--mantine-font-size-sm)', fontWeight: 500 }}>
            {t('reviewSocietyApprovals')}
          </Link>
          <Link href="/admin/users" style={{ fontSize: 'var(--mantine-font-size-sm)', fontWeight: 500 }}>
            {t('manageUserRoles')}
          </Link>
        </Stack>
      </Paper>
    </div>
  )
}
