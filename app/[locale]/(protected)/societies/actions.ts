"use server"

import { z } from 'zod'
import { createSupabaseServerClient } from '@/lib/supabase/server'
import { getLocale } from 'next-intl/server'
import { redirect } from '@/i18n/navigation'

const societySchema = z.object({
  name: z.string().min(2).max(160),
  ragione_sociale: z.string().min(2).max(255),
  codice_fiscale: z.string().min(11).max(16), // Italian tax code: 11 digits (companies) or 16 alphanumeric (individuals)
  sede: z.string().min(2).max(255),
  city: z.string().max(120).optional().nullable(),
  province: z.string().max(120).optional().nullable(),
  description: z.string().max(2000).optional().nullable(),
})

function slugify(input: string) {
  return input
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)+/g, '')
}

async function generateUniqueSlug(base: string) {
  const supabase = await createSupabaseServerClient()
  let slug = slugify(base)
  let attempt = 0
  // Try up to a reasonable number of suffixes
  while (attempt < 50) {
    const candidate = attempt === 0 ? slug : `${slug}-${attempt}`
    const { data, error } = await supabase
      .from('societies')
      .select('id')
      .eq('slug', candidate)
      .maybeSingle()
    if (error) break
    if (!data) return candidate
    attempt += 1
  }
  // Fallback with timestamp
  return `${slug}-${Date.now()}`
}

export async function createSocietyAction(
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
  }

  const parsed = societySchema.safeParse({
    name: formData.get('name')?.toString() ?? '',
    ragione_sociale: formData.get('ragione_sociale')?.toString() ?? '',
    codice_fiscale: formData.get('codice_fiscale')?.toString() ?? '',
    sede: formData.get('sede')?.toString() ?? '',
    city: formData.get('city')?.toString() ?? null,
    province: formData.get('province')?.toString() ?? null,
    description: formData.get('description')?.toString() ?? null,
  })

  if (!parsed.success) {
    const errors = parsed.error.flatten().fieldErrors
    const errorMessage = Object.entries(errors)
      .map(([field, msgs]) => `${field}: ${msgs?.join(', ')}`)
      .join('; ')
    return { error: errorMessage || 'Invalid data' }
  }

  const slug = await generateUniqueSlug(parsed.data.name)

  const { data, error } = await supabase
    .from('societies')
    .insert({
      name: parsed.data.name,
      ragione_sociale: parsed.data.ragione_sociale,
      codice_fiscale: parsed.data.codice_fiscale,
      sede: parsed.data.sede,
      slug,
      city: parsed.data.city ?? null,
      province: parsed.data.province ?? null,
      description: parsed.data.description ?? null,
      // approved defaults to false in the database
    })
    .select('slug')
    .single()

  if (error) {
    console.error(error)
    return { error: error.message }
  }

  const locale = await getLocale()
  redirect({ href: `/societies/${data.slug}` as any, locale })
}
