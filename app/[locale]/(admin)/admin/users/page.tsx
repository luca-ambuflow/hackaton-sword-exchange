import { createSupabaseServerClient } from '@/lib/supabase/server'
import { grantAdminRoleAction, revokeAdminRoleAction } from './actions'
import { Title, Paper, Text, Stack, Group, Badge, Button, Alert, Code } from '@mantine/core'
import { getTranslations } from 'next-intl/server'

export default async function UserRolesPage() {
  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('admin')

  // Get all users with their roles
  const { data: users } = await supabase
    .from('profiles')
    .select(`
      id,
      email,
      full_name,
      created_at,
      user_roles (
        role
      )
    `)
    .order('created_at', { ascending: false })

  // Transform data to include role flags
  const usersWithRoles = users?.map((user: any) => ({
    ...user,
    isPlatformAdmin: user.user_roles?.some((r: any) => r.role === 'platform_admin'),
    isSocietyManager: user.user_roles?.some((r: any) => r.role === 'society_manager'),
  }))

  // Separate platform admins from regular users
  const platformAdmins = usersWithRoles?.filter((u) => u.isPlatformAdmin) || []
  const regularUsers = usersWithRoles?.filter((u) => !u.isPlatformAdmin) || []

  return (
    <div>
      <Title order={1} mb="xl">{t('userRoleManagement')}</Title>

      {/* Platform Admins Section */}
      <Stack gap="lg" mb="xl">
        <Title order={2} size="h2">
          {t('platformAdmins')} ({platformAdmins.length})
        </Title>

        {platformAdmins.length === 0 ? (
          <Paper withBorder p="xl" style={{ textAlign: 'center' }}>
            <Text c="dimmed">{t('noPlatformAdminsFound')}</Text>
          </Paper>
        ) : (
          <Stack gap="sm">
            {platformAdmins.map((user: any) => (
              <Paper key={user.id} withBorder p="md" shadow="sm">
                <Group justify="space-between" align="flex-start">
                  <div>
                    <Text fw={600}>
                      {user.full_name || t('noName')}
                    </Text>
                    <Text size="sm" c="dimmed">{user.email}</Text>
                    <Group gap="xs" mt="xs">
                      <Badge color="grape" size="sm">
                        {t('platformAdmin')}
                      </Badge>
                      {user.isSocietyManager && (
                        <Badge color="blue" size="sm">
                          {t('societyManager')}
                        </Badge>
                      )}
                    </Group>
                  </div>
                  <form action={revokeAdminRoleAction}>
                    <input type="hidden" name="userId" value={user.id} />
                    <Button type="submit" color="red" size="sm">
                      {t('revokeAdmin')}
                    </Button>
                  </form>
                </Group>
              </Paper>
            ))}
          </Stack>
        )}
      </Stack>

      {/* Regular Users Section */}
      <Stack gap="lg">
        <Title order={2} size="h2">
          {t('allUsers')} ({regularUsers.length})
        </Title>

        <Alert color="yellow" title={t('note')}>
          {t('securityNote')}
        </Alert>

        {regularUsers.length === 0 ? (
          <Paper withBorder p="xl" style={{ textAlign: 'center' }}>
            <Text c="dimmed">{t('noUsersFound')}</Text>
          </Paper>
        ) : (
          <Stack gap="xs">
            {regularUsers.map((user: any) => (
              <Paper key={user.id} withBorder p="md" shadow="sm">
                <Group justify="space-between" align="flex-start">
                  <div>
                    <Text fw={600}>
                      {user.full_name || t('noName')}
                    </Text>
                    <Text size="sm" c="dimmed">{user.email}</Text>
                    <Group gap="xs" mt="xs">
                      {user.isSocietyManager && (
                        <Badge color="blue" size="sm">
                          {t('societyManager')}
                        </Badge>
                      )}
                      {!user.isSocietyManager && (
                        <Badge color="gray" size="sm">
                          {t('user')}
                        </Badge>
                      )}
                    </Group>
                  </div>
                  <form action={grantAdminRoleAction}>
                    <input type="hidden" name="userId" value={user.id} />
                    <Button type="submit" color="grape" size="sm">
                      {t('grantAdmin')}
                    </Button>
                  </form>
                </Group>
              </Paper>
            ))}
          </Stack>
        )}
      </Stack>

      {/* Instructions Section */}
      <Alert color="blue" title={t('manualDatabaseSetup')} mt="xl">
        <Text size="sm" mb="sm">
          {t('manualDatabaseSetupDescription')}
        </Text>
        <Code block>
          {`INSERT INTO public.user_roles (user_id, role)
VALUES ('[user-uuid]', 'platform_admin')
ON CONFLICT (user_id, role) DO NOTHING;`}
        </Code>
      </Alert>
    </div>
  )
}
