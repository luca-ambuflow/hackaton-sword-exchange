-- =====================================================
-- Migration: 011_admin_role_management.sql
-- Description: Add RLS policies for platform admins to manage user roles
-- =====================================================

-- =====================================================
-- HELPER FUNCTION to check if user is platform admin
-- =====================================================
-- This function bypasses RLS to prevent infinite recursion
CREATE OR REPLACE FUNCTION public.is_platform_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_roles.user_id = is_platform_admin.user_id
    AND user_roles.role = 'platform_admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- UPDATE RLS POLICIES for user_roles
-- =====================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Platform admins can view all user roles" ON public.user_roles;
DROP POLICY IF EXISTS "Platform admins can insert user roles" ON public.user_roles;
DROP POLICY IF EXISTS "Platform admins can delete user roles" ON public.user_roles;

-- Platform admins can view all user roles
CREATE POLICY "Platform admins can view all user roles"
  ON public.user_roles FOR SELECT
  USING (public.is_platform_admin(auth.uid()));

-- Platform admins can insert user roles (grant roles)
CREATE POLICY "Platform admins can insert user roles"
  ON public.user_roles FOR INSERT
  WITH CHECK (public.is_platform_admin(auth.uid()));

-- Platform admins can delete user roles (revoke roles)
CREATE POLICY "Platform admins can delete user roles"
  ON public.user_roles FOR DELETE
  USING (public.is_platform_admin(auth.uid()));

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON POLICY "Platform admins can view all user roles" ON public.user_roles IS 'Allows platform admins to view all user roles for management purposes';
COMMENT ON POLICY "Platform admins can insert user roles" ON public.user_roles IS 'Allows platform admins to grant roles to users';
COMMENT ON POLICY "Platform admins can delete user roles" ON public.user_roles IS 'Allows platform admins to revoke roles from users';
