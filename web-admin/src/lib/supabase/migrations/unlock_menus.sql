-- Eleva o seu perfil criado manualmente para 'Dono da Rede' (super_admin)
-- para destravar todos os menus do painel lateral.

UPDATE profiles 
SET role = 'super_admin' 
WHERE id = (SELECT id FROM auth.users WHERE email = 'admin@alces.com.br');
