-- Vincula o seu usuário de Admin a todas as lojas criadas no banco
INSERT INTO user_store_memberships (user_id, store_id, role, is_active)
SELECT u.id, s.id, 'owner', true
FROM auth.users u
CROSS JOIN stores s
WHERE u.email = 'admin@alces.com.br'
ON CONFLICT (user_id, store_id) DO UPDATE SET role = 'owner', is_active = true;
