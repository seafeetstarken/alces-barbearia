-- Migration to add 'super_admin' role to profiles table
-- Date: 2026-01-27

-- 1. Update the check constraint on the profiles table
-- First, we need to drop the old constraint and add a new one
ALTER TABLE profiles 
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE profiles 
ADD CONSTRAINT profiles_role_check 
CHECK (role IN ('owner', 'manager', 'leader', 'barber', 'super_admin'));

-- 2. Ensure RLS policies include super_admin if needed
-- Note: Currently policies use EXISTS(SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'owner')
-- We might want Super Admins to have access to everything

-- Allow Super Admin full access to everything (optional but recommended for a Super Admin)
CREATE POLICY "Super Admins can do everything" ON profiles FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'));

CREATE POLICY "Super Admins can manage stores" ON stores FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'));

CREATE POLICY "Super Admins can manage settings" ON settings FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'super_admin'));

-- Repeat for other tables if necessary, but for now this fixes the role issue.
