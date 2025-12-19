import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale, getTranslations } from 'next-intl/server'
import { redirect } from '@/i18n/navigation'
import { updateProfileAction } from './actions'
import { Box, Title, Paper, Text, Stack, TextInput, Select, Button } from '@mantine/core'

export default async function AccountPage() {
  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('account')
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    const locale = await getLocale()
    redirect({ href: '/auth/sign-in', locale })
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, preferred_language, timezone, email')
    .eq('id', user!.id)
    .single()

  return (
    <Box maw={600} mx="auto">
      <Title order={1} mb="lg">{t('title')}</Title>

      <Paper withBorder p="md" mb="xl">
        <Text size="sm" c="dimmed">{t('signedInAs')}</Text>
        <Text fw={500}>{user!.email}</Text>
      </Paper>

      <form action={updateProfileAction}>
        <Stack gap="md">
          <TextInput
            label={t('fullName')}
            name="full_name"
            defaultValue={(profile as any)?.full_name ?? ''}
            required
          />

          <Select
            label={t('preferredLanguage')}
            name="preferred_language"
            defaultValue={(profile as any)?.preferred_language ?? ''}
            data={[
              { value: '', label: t('systemDefault') },
              { value: 'en', label: 'English' },
              { value: 'it', label: 'Italiano' },
              { value: 'de', label: 'Deutsch' },
            ]}
          />

          <TextInput
            label={t('timezone')}
            name="timezone"
            placeholder={t('timezonePlaceholder')}
            defaultValue={(profile as any)?.timezone ?? ''}
          />

          <Button type="submit" color="dark">
            {t('save')}
          </Button>
        </Stack>
      </form>
    </Box>
  )
}
