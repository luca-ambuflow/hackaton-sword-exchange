"use server"

import { z } from 'zod'
import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale } from 'next-intl/server'
import { redirect } from '@/i18n/navigation'

const profileSchema = z.object({
  full_name: z.string().min(1, 'Name is required').max(120),
  preferred_language: z.enum(['it', 'en', 'de']).optional().nullable(),
  timezone: z.string().max(120).optional().nullable(),
})

export async function updateProfileAction(formData: FormData) {
  const supabase = await createSupabaseServerClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    const locale = await getLocale()
    redirect({ href: '/auth/sign-in', locale })
  }

  const parsed = profileSchema.safeParse({
    full_name: formData.get('full_name')?.toString() ?? '',
    preferred_language: formData.get('preferred_language')?.toString() ?? null,
    timezone: formData.get('timezone')?.toString() ?? null,
  })

  if (!parsed.success) {
    throw new Error('Invalid profile data')
  }

  const { error } = await supabase
    .from('profiles')
    .update({
      full_name: parsed.data.full_name,
      preferred_language: parsed.data.preferred_language ?? null,
      timezone: parsed.data.timezone ?? null,
    })
    .eq('id', user!.id)

  if (error) {
    throw new Error(error.message)
  }

  // Redirect back to account page to show updated data
  const locale = await getLocale()
  redirect({ href: '/account', locale })
}
