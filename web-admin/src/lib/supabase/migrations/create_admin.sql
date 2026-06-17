-- Habilita a extensão de criptografia (padrão do Supabase)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  new_user_id UUID := gen_random_uuid();
BEGIN
  -- Limpa a tentativa anterior caso exista para não dar erro de e-mail duplicado
  DELETE FROM auth.users WHERE email = 'admin@alces.com.br';

  -- 1. Cria o usuário Admin no sistema de Autenticação do Supabase
  INSERT INTO auth.users (
    instance_id, 
    id, 
    aud, 
    role, 
    email, 
    encrypted_password, 
    email_confirmed_at, 
    raw_app_meta_data, 
    raw_user_meta_data, 
    created_at, 
    updated_at
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    new_user_id,
    'authenticated',
    'authenticated',
    'admin@alces.com.br',
    crypt('alces123', gen_salt('bf')),
    current_timestamp,
    '{"provider":"email","providers":["email"]}',
    '{"full_name": "Administrador", "role": "owner"}',
    current_timestamp,
    current_timestamp
  );

  -- 2. Cria a Identidade do provedor (Obrigatório no Supabase atual)
  INSERT INTO auth.identities (
    id, 
    user_id, 
    provider_id, 
    identity_data, 
    provider, 
    last_sign_in_at, 
    created_at, 
    updated_at
  ) VALUES (
    gen_random_uuid(),
    new_user_id,
    new_user_id,
    format('{"sub":"%s","email":"admin@alces.com.br"}', new_user_id)::jsonb,
    'email',
    current_timestamp,
    current_timestamp,
    current_timestamp
  );
END $$;
