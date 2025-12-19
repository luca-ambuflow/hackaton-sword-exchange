import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Title, Box, Text } from '@mantine/core'
import { getLocale, getTranslations } from 'next-intl/server'
import CreateEventForm from './CreateEventForm'

export default async function NewEventPage() {
  const supabase = await createSupabaseServerClient()
  const locale = await getLocale()
  const t = await getTranslations('events')

  // Fetch disciplines with localized names
  const { data: disciplines } = await supabase
    .from('disciplines')
    .select('code, name_it, name_en, name_de')
    .eq('is_active', true)
    .order('display_order', { ascending: true })

  // Fetch unique regions
  const { data: regionsRaw } = await supabase
    .from('italian_regions')
    .select('region_code, region_name')

  // Deduplicate regions
  const regionsMap = new Map<string, string>()
  regionsRaw?.forEach(r => {
    if (!regionsMap.has(r.region_code)) {
      regionsMap.set(r.region_code, r.region_name)
    }
  })
  const regions = Array.from(regionsMap.entries()).map(([region_code, region_name]) => ({
    region_code,
    region_name,
  })).sort((a, b) => a.region_name.localeCompare(b.region_name))

  // Fetch approved societies for optional association
  const { data: societies } = await supabase
    .from('societies')
    .select('id, name')
    .eq('approved', true)
    .is('deleted_at', null)
    .order('name', { ascending: true })

  // Map disciplines to localized names
  const localizedDisciplines = (disciplines ?? []).map(d => {
    let name = d.name_it // default
    if (locale === 'en' && d.name_en) name = d.name_en
    if (locale === 'de' && d.name_de) name = d.name_de
    return { code: d.code, name }
  })

  return (
    <Box maw={800} mx="auto">
      <Title order={1} mb="sm">{t('createTitle')}</Title>
      <Text c="dimmed" mb="xl">{t('createSubtitle')}</Text>
      
      <CreateEventForm 
        disciplines={localizedDisciplines}
        regions={regions}
        societies={societies ?? []}
      />
    </Box>
  )
}
