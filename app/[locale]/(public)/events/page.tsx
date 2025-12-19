import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Link } from '@/i18n/navigation'
import { Box, Title, TextInput, Button, Text, Stack, Card, Group, Badge, Select } from '@mantine/core'
import { getLocale, getTranslations } from 'next-intl/server'

function toQuery(searchParams: { [key: string]: string | string[] | undefined }) {
  const entries = Object.entries(searchParams).map(([k, v]) => [k, Array.isArray(v) ? v[0] : v])
  return Object.fromEntries(entries)
}

const EVENT_TYPE_COLORS: Record<string, string> = {
  gara: 'red',
  sparring: 'blue',
  seminario: 'green',
  allenamento_aperto: 'orange',
}

export default async function EventsPage({ searchParams }: { searchParams: Promise<{ [key: string]: string | string[] | undefined }> }) {
  const resolvedSearchParams = await searchParams
  const { search = '', type = '', region = '' } = toQuery(resolvedSearchParams)

  const supabase = await createSupabaseServerClient()
  const locale = await getLocale()
  const t = await getTranslations('events')

  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Build query for events
  let query = supabase
    .from('events')
    .select(`
      id,
      slug,
      title,
      description,
      event_type,
      start_datetime,
      end_datetime,
      timezone,
      city,
      region,
      province,
      location_name,
      disciplines,
      society_id,
      societies (
        name,
        slug
      )
    `)
    .is('deleted_at', null)
    .eq('is_published', true)
    .gte('start_datetime', new Date().toISOString())
    .order('start_datetime', { ascending: true })

  if (search) {
    query = query.ilike('title', `%${search}%`)
  }

  if (type) {
    query = query.eq('event_type', type)
  }

  if (region) {
    query = query.eq('region', region)
  }

  const { data: events, error } = await query

  // Fetch unique regions for filter
  const { data: regionsRaw } = await supabase
    .from('italian_regions')
    .select('region_code, region_name')

  const regionsMap = new Map<string, string>()
  regionsRaw?.forEach(r => {
    if (!regionsMap.has(r.region_code)) {
      regionsMap.set(r.region_code, r.region_name)
    }
  })
  const regions = Array.from(regionsMap.entries())
    .map(([value, label]) => ({ value, label }))
    .sort((a, b) => a.label.localeCompare(b.label))

  const eventTypeOptions = [
    { value: 'gara', label: t('eventTypes.gara') },
    { value: 'sparring', label: t('eventTypes.sparring') },
    { value: 'seminario', label: t('eventTypes.seminario') },
    { value: 'allenamento_aperto', label: t('eventTypes.allenamentoAperto') },
  ]

  const formatDate = (dateStr: string, tz: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString(locale, {
      weekday: 'short',
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: tz,
    })
  }

  const getEventTypeLabel = (eventType: string) => {
    const option = eventTypeOptions.find(o => o.value === eventType)
    return option?.label ?? eventType
  }

  return (
    <Box maw={1000} mx="auto">
      <Title order={1} mb="lg">{t('title')}</Title>

      {/* Filters */}
      <form>
        <Group mb="lg" grow>
          <TextInput
            name="search"
            defaultValue={search}
            placeholder={t('searchPlaceholder')}
          />
          <Select
            name="type"
            defaultValue={type}
            placeholder={t('filterByType')}
            data={eventTypeOptions}
            clearable
          />
          <Select
            name="region"
            defaultValue={region}
            placeholder={t('filterByRegion')}
            data={regions}
            clearable
            searchable
          />
          <Button type="submit" color="dark" variant="outline">
            {t('filter')}
          </Button>
        </Group>
      </form>

      {user && (
        <Box mb="lg">
          <Link href="/events/new" style={{ textDecoration: 'none' }}>
            <Button color="dark" size="sm">
              {t('createEvent')}
            </Button>
          </Link>
        </Box>
      )}

      {error && (
        <Text size="sm" c="red">{error.message}</Text>
      )}

      {!error && (!events || events.length === 0) && (
        <Text size="sm" c="dimmed">{t('noEvents')}</Text>
      )}

      <Stack gap="md">
        {events?.map((event: any) => (
          <Link key={event.slug} href={`/events/${event.slug}`} style={{ textDecoration: 'none', color: 'inherit' }}>
            <Card shadow="sm" padding="lg" withBorder>
              <Group justify="space-between" align="flex-start" mb="sm">
                <div style={{ flex: 1 }}>
                  <Group gap="xs" mb="xs">
                    <Badge color={EVENT_TYPE_COLORS[event.event_type] || 'gray'}>
                      {getEventTypeLabel(event.event_type)}
                    </Badge>
                    {event.societies && (
                      <Badge variant="outline" color="gray">
                        {event.societies.name}
                      </Badge>
                    )}
                  </Group>
                  <Text size="lg" fw={600}>{event.title}</Text>
                </div>
              </Group>
              
              <Text size="sm" c="dimmed" mb="xs">
                📅 {formatDate(event.start_datetime, event.timezone)}
                {event.end_datetime && ` - ${formatDate(event.end_datetime, event.timezone)}`}
              </Text>
              
              {(event.city || event.location_name) && (
                <Text size="sm" c="dimmed" mb="xs">
                  📍 {[event.location_name, event.city, event.province].filter(Boolean).join(', ')}
                </Text>
              )}
              
              {event.description && (
                <Text size="sm" mt="sm" lineClamp={2}>{event.description}</Text>
              )}
            </Card>
          </Link>
        ))}
      </Stack>
    </Box>
  )
}
