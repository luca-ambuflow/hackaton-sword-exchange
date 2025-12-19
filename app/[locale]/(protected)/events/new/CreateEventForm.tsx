"use client"

import { useFormState } from 'react-dom'
import { createEventAction } from '../actions'
import {
  Stack,
  TextInput,
  Textarea,
  Button,
  Alert,
  Select,
  Group,
  Checkbox,
  Paper,
  Text,
  SimpleGrid
} from '@mantine/core'
import { useTranslations } from 'next-intl'

const initialState = {
  error: null as string | null,
}

interface CreateEventFormProps {
  disciplines: Array<{ code: string; name: string }>
  regions: Array<{ region_code: string; region_name: string }>
  societies: Array<{ id: string; name: string }>
}

const EVENT_TYPES = [
  { value: 'gara', labelKey: 'eventTypes.gara' },
  { value: 'sparring', labelKey: 'eventTypes.sparring' },
  { value: 'seminario', labelKey: 'eventTypes.seminario' },
  { value: 'allenamento_aperto', labelKey: 'eventTypes.allenamentoAperto' },
]

const TIMEZONES = [
  { value: 'Europe/Rome', label: 'Europe/Rome (CET/CEST)' },
  { value: 'Europe/London', label: 'Europe/London (GMT/BST)' },
  { value: 'Europe/Paris', label: 'Europe/Paris (CET/CEST)' },
  { value: 'Europe/Berlin', label: 'Europe/Berlin (CET/CEST)' },
  { value: 'Europe/Madrid', label: 'Europe/Madrid (CET/CEST)' },
  { value: 'Europe/Vienna', label: 'Europe/Vienna (CET/CEST)' },
  { value: 'Europe/Warsaw', label: 'Europe/Warsaw (CET/CEST)' },
  { value: 'Europe/Prague', label: 'Europe/Prague (CET/CEST)' },
  { value: 'Europe/Budapest', label: 'Europe/Budapest (CET/CEST)' },
  { value: 'Europe/Athens', label: 'Europe/Athens (EET/EEST)' },
  { value: 'UTC', label: 'UTC' },
]

export default function CreateEventForm({ disciplines, regions, societies }: CreateEventFormProps) {
  const [state, formAction] = useFormState(createEventAction, initialState)
  const t = useTranslations('events')

  const eventTypeOptions = EVENT_TYPES.map(et => ({
    value: et.value,
    label: t(et.labelKey),
  }))

  const regionOptions = regions.map(r => ({
    value: r.region_code,
    label: r.region_name,
  }))

  const societyOptions = societies.map(s => ({
    value: s.id,
    label: s.name,
  }))

  return (
    <form action={formAction}>
      <Stack gap="md">
        {state?.error && (
          <Alert color="red" title={t('form.error')}>
            {state.error}
          </Alert>
        )}

        {/* Basic Information */}
        <Paper withBorder p="md">
          <Text fw={600} mb="md">{t('form.basicInfo')}</Text>

          <Stack gap="sm">
            <TextInput
              label={t('form.title')}
              name="title"
              required
              placeholder={t('form.titlePlaceholder')}
            />

            <Select
              label={t('form.eventType')}
              name="event_type"
              required
              data={eventTypeOptions}
              defaultValue="seminario"
            />

            <Textarea
              label={t('form.description')}
              name="description"
              rows={4}
              placeholder={t('form.descriptionPlaceholder')}
            />

            <TextInput
              label={t('form.externalLink')}
              name="external_link"
              type="url"
              placeholder="https://..."
            />
          </Stack>
        </Paper>

        {/* Date and Time */}
        <Paper withBorder p="md">
          <Text fw={600} mb="md">{t('form.dateTime')}</Text>

          <Stack gap="sm">
            <Group grow>
              <TextInput
                label={t('form.startDateTime')}
                name="start_datetime"
                type="datetime-local"
                required
              />

              <TextInput
                label={t('form.endDateTime')}
                name="end_datetime"
                type="datetime-local"
              />
            </Group>

            <Select
              label={t('form.timezone')}
              name="timezone"
              data={TIMEZONES}
              defaultValue="Europe/Rome"
              searchable
            />
          </Stack>
        </Paper>

        {/* Location */}
        <Paper withBorder p="md">
          <Text fw={600} mb="md">{t('form.location')}</Text>

          <Stack gap="sm">
            <Group grow>
              <Select
                label={t('form.region')}
                name="region"
                data={regionOptions}
                searchable
                clearable
              />

              <TextInput
                label={t('form.province')}
                name="province"
                placeholder={t('form.provincePlaceholder')}
              />
            </Group>

            <TextInput
              label={t('form.city')}
              name="city"
              placeholder={t('form.cityPlaceholder')}
            />

            <TextInput
              label={t('form.locationName')}
              name="location_name"
              placeholder={t('form.locationNamePlaceholder')}
            />

            <TextInput
              label={t('form.address')}
              name="address"
              placeholder={t('form.addressPlaceholder')}
            />
          </Stack>
        </Paper>

        {/* Organizer */}
        <Paper withBorder p="md">
          <Text fw={600} mb="md">{t('form.organizer')}</Text>

          <Select
            label={t('form.society')}
            name="society_id"
            data={societyOptions}
            searchable
            clearable
            placeholder={t('form.societyPlaceholder')}
          />
        </Paper>

        {/* Disciplines */}
        <Paper withBorder p="md">
          <Text fw={600} mb="md">{t('form.disciplines')}</Text>
          <Text size="sm" c="dimmed" mb="md">{t('form.disciplinesHint')}</Text>

          <SimpleGrid cols={{ base: 2, sm: 3 }} spacing="xs">
            {disciplines.map((d) => (
              <Checkbox
                key={d.code}
                label={d.name}
                name="disciplines"
                value={d.code}
              />
            ))}
          </SimpleGrid>
        </Paper>

        <Button type="submit" color="dark" size="md">
          {t('form.submit')}
        </Button>
      </Stack>
    </form>
  )
}
