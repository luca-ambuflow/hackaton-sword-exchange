import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale, getTranslations } from 'next-intl/server'
import { redirect } from '@/i18n/navigation'
import CreateSocietyForm from './CreateSocietyForm'
import { Box, Title } from '@mantine/core'

export default async function NewSocietyPage() {
  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('societies')
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    const locale = await getLocale()
    redirect({ href: '/auth/sign-in', locale })
  }

  return (
    <Box maw={600} mx="auto">
      <Title order={1} mb="lg">{t('createSociety')}</Title>
      <CreateSocietyForm />
    </Box>
  )
}
