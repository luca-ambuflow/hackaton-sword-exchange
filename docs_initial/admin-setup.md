# Admin Interface Setup Guide

## Overview

This document describes the admin interface implementation for the historical fencing portal, including:
1. Society approval workflow
2. Admin user management interface

## Features Implemented

### 1. Society Approval System

**Database Changes:**
- Added `approved` flag to societies table (default: `false`)
- Added `approved_by` and `approved_at` fields to track who approved and when
- Updated RLS policies so only approved societies are publicly visible
- Society admins can still view their own unapproved societies

**Workflow:**
1. When a user creates a new society, it starts with `approved = false`
2. The society is NOT visible on the public societies list
3. Platform admins can see pending societies in the admin panel
4. Platform admins can approve or reject (soft delete) societies
5. Once approved, the society becomes publicly visible

### 2. Admin Interface

**Access Control:**
- Admin routes are under `/admin/*`
- Only users with `platform_admin` role can access
- Non-admin users are redirected to home page

**Admin Pages:**

#### Dashboard (`/admin`)
- Overview statistics (pending societies, pending manager requests, totals)
- Quick action links

#### Society Approvals (`/admin/societies`)
- List of pending societies awaiting approval
- Society details (name, tax code, location, creator)
- Approve/Reject buttons
- List of recently approved societies

#### User Role Management (`/admin/users`)
- List of all platform admins
- List of all regular users
- Grant/Revoke admin role buttons
- Note: Includes UI for granting admin roles, but manual database setup is recommended for security

## Database Migrations

Three new migrations were created:

1. **010_societies_approval.sql**
   - Adds `approved`, `approved_by`, `approved_at` columns to societies
   - Updates RLS policies for approval workflow
   - Creates `approve_society()` and `unapprove_society()` functions
   - Creates `pending_society_approvals` view

2. **011_admin_role_management.sql**
   - Adds RLS policies for platform admins to manage user_roles table
   - Allows admins to view, insert, and delete user roles

## Setting Up the First Admin User

### Method 1: Direct Database Insert (Recommended)

Connect to your Supabase database and run:

```sql
-- Get the user ID for the email you want to make admin
SELECT id, email FROM auth.users WHERE email = 'your-email@example.com';

-- Grant platform_admin role
INSERT INTO public.user_roles (user_id, role)
VALUES ('[user-uuid-from-above]', 'platform_admin')
ON CONFLICT (user_id, role) DO NOTHING;
```

### Method 2: Using Supabase Dashboard

1. Go to Supabase Dashboard → Table Editor
2. Open the `user_roles` table
3. Click "Insert row"
4. Fill in:
   - `user_id`: The UUID of the user (from `auth.users` or `profiles` table)
   - `role`: Select `platform_admin`
5. Save

### Method 3: Using the Admin Interface (After First Admin)

Once you have at least one platform admin:
1. Log in as the admin user
2. Go to `/admin/users`
3. Find the user you want to promote
4. Click "Grant Admin" button

## Accessing the Admin Panel

1. Ensure you have the `platform_admin` role (see setup above)
2. Navigate to `/admin` (or any locale like `/en/admin`, `/it/admin`)
3. You'll see the admin dashboard with navigation to:
   - Dashboard
   - Society Approvals
   - User Roles

## Security Notes

1. **Admin Role Assignment**: The `platform_admin` role should be granted carefully. It's recommended to do this manually in the database rather than through the UI.

2. **RLS Policies**: All admin operations are protected by Row Level Security policies that check for the `platform_admin` role.

3. **Self-Revocation Protection**: Admins cannot revoke their own admin role through the UI.

4. **Society Visibility**: Unapproved societies are hidden from public view but visible to:
   - Platform admins (all societies)
   - Society administrators (their own society)

## Testing the Implementation

### Test Society Approval Workflow

1. Create a test user account
2. Log in and create a new society
3. Verify the society does NOT appear on the public societies list
4. Log in as platform admin
5. Go to `/admin/societies`
6. Verify the new society appears in "Pending Approvals"
7. Click "Approve"
8. Verify the society now appears on the public societies list

### Test Admin Access Control

1. Try accessing `/admin` without being logged in → should redirect to sign-in
2. Try accessing `/admin` as a regular user → should redirect to home
3. Try accessing `/admin` as platform admin → should show admin dashboard

## File Structure

```
app/[locale]/(admin)/
├── layout.tsx                    # Admin layout with auth check
├── admin/
│   ├── page.tsx                  # Dashboard
│   ├── societies/
│   │   ├── page.tsx             # Society approvals list
│   │   └── actions.ts           # Approve/reject actions
│   └── users/
│       ├── page.tsx             # User role management
│       └── actions.ts           # Grant/revoke admin actions

supabase/migrations/
├── 010_societies_approval.sql
└── 011_admin_role_management.sql
```

## Troubleshooting

### "Not authorized" error when approving societies
- Verify your user has the `platform_admin` role in the `user_roles` table
- Check that the RLS policies are applied correctly

### Societies not appearing after approval
- Check that `approved = true` in the database
- Verify the RLS policies allow public viewing of approved societies
- Try refreshing the page or clearing cache

### Cannot access admin panel
- Verify you're logged in
- Check that your user has `platform_admin` role
- Check browser console for any errors
