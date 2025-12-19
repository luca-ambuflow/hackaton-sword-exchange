"use server"

import { z } from 'zod'
import { createSupabaseServerClient } from '@/lib/supabase/server'
import { redirect } from '@/i18n/navigation'
import { getLocale } from 'next-intl/server'

const authSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
})

export async function signInAction(formData: FormData) {
  const parsed = authSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  })

  if (!parsed.success) {
    // In a real app, you'd want to handle this error better
    // For now, we'll just throw to show the error
    throw new Error('Invalid credentials format')
  }

  const supabase = createSupabaseServerClient()
  const { error } = await supabase.auth.signInWithPassword(parsed.data)

  if (error) {
    throw new Error(error.message)
  }

  // Get current locale and redirect to societies page
  const locale = await getLocale()
  redirect({ href: '/societies', locale })
}

export async function signUpAction(formData: FormData) {
  const parsed = authSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  })

  if (!parsed.success) {
    throw new Error('Invalid credentials format')
  }

  const supabase = createSupabaseServerClient()
  const { error } = await supabase.auth.signUp({
    email: parsed.data.email,
    password: parsed.data.password,
  })

  if (error) {
    throw new Error(error.message)
  }

  // After sign up, user may need to verify email depending on Supabase settings
  // Redirect to sign-in page
  const locale = await getLocale()
  redirect({ href: '/auth/sign-in', locale })
}
