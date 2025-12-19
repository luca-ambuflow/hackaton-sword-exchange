'use server'

import { createSupabaseServerClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

export async function grantAdminRoleAction(formData: FormData) {
  const userId = formData.get('userId') as string

  if (!userId) {
    throw new Error('User ID is required')
  }

  const supabase = await createSupabaseServerClient()

  // Check if current user is platform admin
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

  // Grant platform_admin role
  const { error } = await supabase
    .from('user_roles')
    .insert({
      user_id: userId,
      role: 'platform_admin',
    })

  if (error) {
    console.error('Error granting admin role:', error)
    throw new Error('Failed to grant admin role')
  }

  revalidatePath('/admin/users')
}

export async function revokeAdminRoleAction(formData: FormData) {
  const userId = formData.get('userId') as string

  if (!userId) {
    throw new Error('User ID is required')
  }

  const supabase = await createSupabaseServerClient()

  // Check if current user is platform admin
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

  // Prevent self-revocation
  if (userId === user.id) {
    throw new Error('Cannot revoke your own admin role')
  }

  // Revoke platform_admin role
  const { error } = await supabase
    .from('user_roles')
    .delete()
    .eq('user_id', userId)
    .eq('role', 'platform_admin')

  if (error) {
    console.error('Error revoking admin role:', error)
    throw new Error('Failed to revoke admin role')
  }

  revalidatePath('/admin/users')
}
