import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Title, Paper, Text, Stack, Group, Anchor } from '@mantine/core'
import { SocietyApprovalActions } from './SocietyApprovalActions'
import { getTranslations } from 'next-intl/server'

export default async function SocietyApprovalsPage() {
  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('admin')

  // Get pending societies
  const { data: pendingSocieties } = await supabase
    .from('societies')
    .select(`
      id,
      slug,
      ragione_sociale,
      codice_fiscale,
      city,
      region,
      email,
      website,
      created_at,
      society_administrators (
        user_id,
        profiles (
          email,
          full_name
        )
      )
    `)
    .eq('approved', false)
    .is('deleted_at', null)
    .order('created_at', { ascending: true })

  // Get approved societies
  const { data: approvedSocieties } = await supabase
    .from('societies')
    .select(`
      id,
      slug,
      ragione_sociale,
      codice_fiscale,
      city,
      region,
      approved_at,
      profiles!societies_approved_by_fkey (
        email,
        full_name
      )
    `)
    .eq('approved', true)
    .is('deleted_at', null)
    .order('approved_at', { ascending: false })
    .limit(20)

  return (
    <div>
      <Title order={1} mb="xl">{t('societyApprovals')}</Title>

      {/* Pending Societies Section */}
      <Stack gap="lg" mb="xl">
        <Title order={2} size="h2">
          {t('pendingApprovals')} ({pendingSocieties?.length ?? 0})
        </Title>

        {!pendingSocieties || pendingSocieties.length === 0 ? (
          <Paper withBorder p="xl" style={{ textAlign: 'center' }}>
            <Text c="dimmed">{t('noPendingSocietyApprovals')}</Text>
          </Paper>
        ) : (
          <Stack gap="md">
            {pendingSocieties.map((society: any) => {
              const creator = society.society_administrators?.[0]?.profiles

              return (
                <Paper key={society.id} withBorder p="lg" shadow="sm">
                  <Group justify="space-between" align="flex-start" mb="md">
                    <div style={{ flex: 1 }}>
                      <Text size="lg" fw={600}>
                        {society.ragione_sociale}
                      </Text>
                      <Text size="sm" c="dimmed">
                        {t('cf')} {society.codice_fiscale}
                      </Text>
                      {society.city && society.region && (
                        <Text size="sm" c="dimmed">
                          {society.city}, {society.region}
                        </Text>
                      )}
                    </div>
                    <Text size="sm" c="dimmed" style={{ textAlign: 'right' }}>
                      {t('created')} {new Date(society.created_at).toLocaleDateString()}
                    </Text>
                  </Group>

                  {society.email && (
                    <Text size="sm" mb="xs">
                      <Text component="span" fw={500}>{t('emailLabel')}</Text> {society.email}
                    </Text>
                  )}
                  {society.website && (
                    <Text size="sm" mb="xs">
                      <Text component="span" fw={500}>{t('websiteLabel')}</Text>{' '}
                      <Anchor href={society.website} target="_blank" rel="noopener noreferrer">
                        {society.website}
                      </Anchor>
                    </Text>
                  )}
                  {creator && (
                    <Text size="sm" mb="md">
                      <Text component="span" fw={500}>{t('creatorLabel')}</Text> {creator.full_name || creator.email}
                    </Text>
                  )}

                  <SocietyApprovalActions societyId={society.id} />
                </Paper>
              )
            })}
          </Stack>
        )}
      </Stack>

      {/* Recently Approved Societies Section */}
      <Stack gap="lg">
        <Title order={2} size="h2">
          {t('recentlyApproved')} ({approvedSocieties?.length ?? 0})
        </Title>

        {!approvedSocieties || approvedSocieties.length === 0 ? (
          <Paper withBorder p="xl" style={{ textAlign: 'center' }}>
            <Text c="dimmed">{t('noApprovedSocietiesYet')}</Text>
          </Paper>
        ) : (
          <Stack gap="sm">
            {approvedSocieties.map((society: any) => (
              <Paper key={society.id} withBorder p="md" shadow="sm">
                <Group justify="space-between" align="center">
                  <div>
                    <Text fw={600}>{society.ragione_sociale}</Text>
                    <Text size="sm" c="dimmed">
                      {society.city && society.region
                        ? `${society.city}, ${society.region}`
                        : society.codice_fiscale}
                    </Text>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <Text size="sm" c="dimmed">
                      {t('approved')} {new Date(society.approved_at).toLocaleDateString()}
                    </Text>
                    {society.profiles && (
                      <Text size="xs" c="dimmed">
                        {t('by')} {society.profiles.full_name || society.profiles.email}
                      </Text>
                    )}
                  </div>
                </Group>
              </Paper>
            ))}
          </Stack>
        )}
      </Stack>
    </div>
  )
}
