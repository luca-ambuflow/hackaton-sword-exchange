"use server"

import { z } from 'zod'
import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale } from 'next-intl/server'
import { redirect } from '@/i18n/navigation'

const eventSchema = z.object({
  title: z.string().min(3).max(200),
  description: z.string().max(5000).optional().nullable(),
  event_type: z.enum(['gara', 'sparring', 'seminario', 'allenamento_aperto']),
  external_link: z.string().url().optional().nullable().or(z.literal('')),
  start_datetime: z.string().min(1, 'Start date is required'),
  end_datetime: z.string().optional().nullable().or(z.literal('')),
  timezone: z.string().default('Europe/Rome'),
  region: z.string().max(100).optional().nullable(),
  province: z.string().max(100).optional().nullable(),
  city: z.string().max(200).optional().nullable(),
  location_name: z.string().max(300).optional().nullable(),
  address: z.string().max(500).optional().nullable(),
  society_id: z.string().uuid().optional().nullable().or(z.literal('')),
  disciplines: z.array(z.string()).optional().nullable(),
})

export async function createEventAction(
  prevState: { error: string | null } | undefined,
  formData: FormData
) {
  const supabase = await createSupabaseServerClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    const locale = await getLocale()
    redirect({ href: '/auth/sign-in', locale })
    return { error: 'Not authenticated' }
  }

  // Parse disciplines from form data (multiple checkboxes)
  const disciplinesRaw = formData.getAll('disciplines')
  const disciplines = disciplinesRaw.length > 0
    ? disciplinesRaw.map(d => d.toString()).filter(Boolean)
    : null

  const parsed = eventSchema.safeParse({
    title: formData.get('title')?.toString() ?? '',
    description: formData.get('description')?.toString() || null,
    event_type: formData.get('event_type')?.toString() ?? 'seminario',
    external_link: formData.get('external_link')?.toString() || null,
    start_datetime: formData.get('start_datetime')?.toString() ?? '',
    end_datetime: formData.get('end_datetime')?.toString() || null,
    timezone: formData.get('timezone')?.toString() || 'Europe/Rome',
    region: formData.get('region')?.toString() || null,
    province: formData.get('province')?.toString() || null,
    city: formData.get('city')?.toString() || null,
    location_name: formData.get('location_name')?.toString() || null,
    address: formData.get('address')?.toString() || null,
    society_id: formData.get('society_id')?.toString() || null,
    disciplines,
  })

  if (!parsed.success) {
    const errors = parsed.error.flatten().fieldErrors
    const errorMessage = Object.entries(errors)
      .map(([field, msgs]) => `${field}: ${msgs?.join(', ')}`)
      .join('; ')
    return { error: errorMessage || 'Invalid data' }
  }

  const data = parsed.data

  // Convert local datetime to UTC for storage
  const startDatetime = new Date(data.start_datetime).toISOString()
  const endDatetime = data.end_datetime ? new Date(data.end_datetime).toISOString() : null

  const { data: event, error } = await supabase
    .from('events')
    .insert({
      title: data.title,
      description: data.description,
      event_type: data.event_type,
      external_link: data.external_link || null,
      start_datetime: startDatetime,
      end_datetime: endDatetime,
      timezone: data.timezone,
      region: data.region,
      province: data.province,
      city: data.city,
      location_name: data.location_name,
      address: data.address,
      society_id: data.society_id || null,
      disciplines: data.disciplines,
      creator_id: user.id,
    })
    .select('slug')
    .single()

  if (error) {
    console.error('Error creating event:', error)
    return { error: error.message }
  }

  const locale = await getLocale()
  redirect({ href: `/events/${event.slug}` as any, locale })
}
