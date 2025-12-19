'use server'

import { createSupabaseServerClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

export async function approveSocietyAction(formData: FormData) {
  const societyId = formData.get('societyId') as string

  if (!societyId) {
    throw new Error('Society ID is required')
  }

  const supabase = await createSupabaseServerClient()

  // Check if user is platform admin
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    throw new Error('Not authenticated')
  }

  const { data: roles } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', user.id)
    .eq('role', 'platform_admin')
    .single()

  if (!roles) {
    throw new Error('Not authorized')
  }

  // Call the approve_society function
  const { error } = await supabase.rpc('approve_society', {
    society_id_param: societyId,
  })

  if (error) {
    console.error('Error approving society:', error)
    throw new Error('Failed to approve society')
  }

  revalidatePath('/admin/societies')
  revalidatePath('/societies')
}

export async function rejectSocietyAction(formData: FormData) {
  const societyId = formData.get('societyId') as string

  if (!societyId) {
    throw new Error('Society ID is required')
  }

  const supabase = await createSupabaseServerClient()

  // Check if user is platform admin
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    throw new Error('Not authenticated')
  }

  const { data: roles } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', user.id)
    .eq('role', 'platform_admin')
    .single()

  if (!roles) {
    throw new Error('Not authorized')
  }

  // Soft delete the society
  const { error } = await supabase
    .from('societies')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', societyId)

  if (error) {
    console.error('Error rejecting society:', error)
    throw new Error('Failed to reject society')
  }

  revalidatePath('/admin/societies')
  revalidatePath('/societies')
}
