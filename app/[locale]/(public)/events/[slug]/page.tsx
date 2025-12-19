import { createSupabaseServerClient } from '@/lib/supabase/server'
import { notFound } from 'next/navigation'
import { Link } from '@/i18n/navigation'
import { Box, Title, Text, Paper, Group, Badge, Stack, Button, Anchor, Divider } from '@mantine/core'
import { getLocale, getTranslations } from 'next-intl/server'

const EVENT_TYPE_COLORS: Record<string, string> = {
  gara: 'red',
  sparring: 'blue',
  seminario: 'green',
  allenamento_aperto: 'orange',
}

interface EventDetailPageProps {
  params: Promise<{ slug: string }>
}

export default async function EventDetailPage({ params }: EventDetailPageProps) {
  const { slug } = await params
  const supabase = await createSupabaseServerClient()
  const locale = await getLocale()
  const t = await getTranslations('events')

  const { data: event, error } = await supabase
    .from('events')
    .select(`
      id,
      slug,
      title,
      description,
      event_type,
      external_link,
      start_datetime,
      end_datetime,
      timezone,
      region,
      province,
      city,
      location_name,
      address,
      disciplines,
      creator_id,
      society_id,
      created_at,
      societies (
        id,
        name,
        slug
      ),
      profiles!events_creator_id_fkey (
        full_name
      )
    `)
    .eq('slug', slug)
    .is('deleted_at', null)
    .eq('is_published', true)
    .single()

  if (error || !event) {
    notFound()
  }

  // Fetch discipline names if event has disciplines
  let disciplineNames: string[] = []
  if (event.disciplines && event.disciplines.length > 0) {
    const { data: disciplines } = await supabase
      .from('disciplines')
      .select('code, name_it, name_en, name_de')
      .in('code', event.disciplines)

    if (disciplines) {
      disciplineNames = disciplines.map(d => {
        if (locale === 'en' && d.name_en) return d.name_en
        if (locale === 'de' && d.name_de) return d.name_de
        return d.name_it
      })
    }
  }

  const eventTypeOptions: Record<string, string> = {
    gara: t('eventTypes.gara'),
    sparring: t('eventTypes.sparring'),
    seminario: t('eventTypes.seminario'),
    allenamento_aperto: t('eventTypes.allenamentoAperto'),
  }

  const formatDateTime = (dateStr: string, tz: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString(locale, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: tz,
    })
  }

  const formatDateOnly = (dateStr: string, tz: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString(locale, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      timeZone: tz,
    })
  }

  const formatTimeOnly = (dateStr: string, tz: string) => {
    const date = new Date(dateStr)
    return date.toLocaleTimeString(locale, {
      hour: '2-digit',
      minute: '2-digit',
      timeZone: tz,
    })
  }

  const startDate = formatDateOnly(event.start_datetime, event.timezone)
  const startTime = formatTimeOnly(event.start_datetime, event.timezone)
  const endTime = event.end_datetime ? formatTimeOnly(event.end_datetime, event.timezone) : null

  return (
    <Box maw={800} mx="auto">
      <Link href="/events" style={{ textDecoration: 'none' }}>
        <Text size="sm" c="dimmed" mb="md">← {t('backToEvents')}</Text>
      </Link>

      <Group gap="xs" mb="md">
        <Badge size="lg" color={EVENT_TYPE_COLORS[event.event_type] || 'gray'}>
          {eventTypeOptions[event.event_type] || event.event_type}
        </Badge>
        {(event as any).societies && (
          <Link href={`/societies/${(event as any).societies.slug}`} style={{ textDecoration: 'none' }}>
            <Badge size="lg" variant="outline" color="gray" style={{ cursor: 'pointer' }}>
              {(event as any).societies.name}
            </Badge>
          </Link>
        )}
      </Group>

      <Title order={1} mb="lg">{event.title}</Title>

      {/* Date and Time */}
      <Paper withBorder p="md" mb="md">
        <Text fw={600} mb="sm">{t('detail.dateTime')}</Text>
        <Text size="lg">📅 {startDate}</Text>
        <Text size="md" c="dimmed">
          🕐 {startTime}{endTime && ` - ${endTime}`} ({event.timezone})
        </Text>
      </Paper>

      {/* Location */}
      {(event.location_name || event.city || event.address) && (
        <Paper withBorder p="md" mb="md">
          <Text fw={600} mb="sm">{t('detail.location')}</Text>
          {event.location_name && (
            <Text size="lg">📍 {event.location_name}</Text>
          )}
          {(event.city || event.province || event.region) && (
            <Text size="md" c="dimmed">
              {[event.city, event.province, event.region].filter(Boolean).join(', ')}
            </Text>
          )}
          {event.address && (
            <Text size="sm" c="dimmed" mt="xs">{event.address}</Text>
          )}
        </Paper>
      )}

      {/* Description */}
      {event.description && (
        <Paper withBorder p="md" mb="md">
          <Text fw={600} mb="sm">{t('detail.description')}</Text>
          <Text style={{ whiteSpace: 'pre-wrap' }}>{event.description}</Text>
        </Paper>
      )}

      {/* Disciplines */}
      {disciplineNames.length > 0 && (
        <Paper withBorder p="md" mb="md">
          <Text fw={600} mb="sm">{t('detail.disciplines')}</Text>
          <Group gap="xs">
            {disciplineNames.map((name, idx) => (
              <Badge key={idx} variant="light" color="gray">{name}</Badge>
            ))}
          </Group>
        </Paper>
      )}

      {/* External Link */}
      {event.external_link && (
        <Paper withBorder p="md" mb="md">
          <Text fw={600} mb="sm">{t('detail.moreInfo')}</Text>
          <Anchor href={event.external_link} target="_blank" rel="noopener noreferrer">
            {event.external_link}
          </Anchor>
        </Paper>
      )}

      {/* Organizer Info */}
      <Divider my="lg" />
      <Text size="sm" c="dimmed">
        {t('detail.createdBy')}: {(event as any).profiles?.full_name || t('detail.anonymous')}
      </Text>
      <Text size="xs" c="dimmed">
        {t('detail.postedOn')}: {new Date(event.created_at).toLocaleDateString(locale)}
      </Text>
    </Box>
  )
}
