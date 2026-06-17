-- 1. Recarrega o cache da API do Supabase (para evitar erros 500)
NOTIFY pgrst, 'reload schema';

-- 2. Garante que o vínculo foi criado para o e-mail exato do painel
INSERT INTO user_store_memberships (user_id, store_id, role, is_active)
SELECT u.id, s.id, 'owner', true
FROM auth.users u
CROSS JOIN stores s
WHERE u.email = 'admin@alces.com.br'
ON CONFLICT (user_id, store_id) DO UPDATE SET role = 'owner', is_active = true;
