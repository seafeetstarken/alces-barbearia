-- Idempotent query to fix demo user roles
-- Run this in Supabase SQL Editor

-- Update admin@alces.com to owner role
UPDATE profiles 
SET role = 'owner', updated_at = NOW()
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'admin@alces.com'
)
AND (role IS NULL OR role != 'owner');

-- Update gestor@alces.com to manager role
UPDATE profiles 
SET role = 'manager', updated_at = NOW()
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'gestor@alces.com'
)
AND (role IS NULL OR role != 'manager');

-- Update lider@alces.com to leader role
UPDATE profiles 
SET role = 'leader', updated_at = NOW()
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'lider@alces.com'
)
AND (role IS NULL OR role != 'leader');

-- Update barber@alces.com to barber role
UPDATE profiles 
SET role = 'barber', updated_at = NOW()
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'barber@alces.com'
)
AND (role IS NULL OR role != 'barber');

-- Update superadmin@alces.com to super_admin role
UPDATE profiles 
SET role = 'super_admin', updated_at = NOW()
WHERE id IN (
    SELECT id FROM auth.users WHERE email = 'superadmin@alces.com'
)
AND (role IS NULL OR role != 'super_admin');

-- View current state
SELECT 
    u.email,
    p.full_name,
    p.role,
    p.updated_at
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email LIKE '%@alces.com'
ORDER BY 
    CASE p.role 
        WHEN 'super_admin' THEN 1
        WHEN 'owner' THEN 2
        WHEN 'manager' THEN 3
        WHEN 'leader' THEN 4
        WHEN 'barber' THEN 5
        ELSE 6
    END;
