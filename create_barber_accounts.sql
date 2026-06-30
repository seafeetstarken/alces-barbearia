-- ========================================================
-- ALCE'S BARBEARIA - CREATE BARBER ACCOUNTS AND LINK PROFILES
-- Execute este script no SQL Editor do Supabase
-- ========================================================

-- Habilitar pgcrypto se ainda não estiver habilitado
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  jorge_id UUID := gen_random_uuid();
  peterson_id UUID := gen_random_uuid();
  ryan_id UUID := gen_random_uuid();
  gabriel_id UUID := gen_random_uuid();
  jerffeson_id UUID := gen_random_uuid();
  thiago_id UUID := gen_random_uuid();
  lucas_id UUID := gen_random_uuid();
BEGIN

  -- 1. Inserir usuários na tabela auth.users se não existirem
  -- Jorge
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'jorge@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      jorge_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'jorge@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Jorge Henrique Funke"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO jorge_id FROM auth.users WHERE email = 'jorge@alces.com.br';
  END IF;

  -- Peterson
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'peterson@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      peterson_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'peterson@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Peterson"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO peterson_id FROM auth.users WHERE email = 'peterson@alces.com.br';
  END IF;

  -- Ryan
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'ryan@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      ryan_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'ryan@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Ryan"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO ryan_id FROM auth.users WHERE email = 'ryan@alces.com.br';
  END IF;

  -- Gabriel
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'gabriel@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      gabriel_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'gabriel@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Gabriel"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO gabriel_id FROM auth.users WHERE email = 'gabriel@alces.com.br';
  END IF;

  -- Jerffeson
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'jerffeson@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      jerffeson_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'jerffeson@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Jerffeson"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO jerffeson_id FROM auth.users WHERE email = 'jerffeson@alces.com.br';
  END IF;

  -- Thiago Ferreira
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'thiago@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      thiago_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'thiago@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Thiago Ferreira"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO thiago_id FROM auth.users WHERE email = 'thiago@alces.com.br';
  END IF;

  -- Lucas Pelizer
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'lucas@alces.com.br') THEN
    INSERT INTO auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, 
      raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at
    ) VALUES (
      lucas_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 
      'lucas@alces.com.br', crypt('Alces2026!', gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"full_name":"Lucas Pelizer"}'::jsonb,
      false, now(), now()
    );
  ELSE
    SELECT id INTO lucas_id FROM auth.users WHERE email = 'lucas@alces.com.br';
  END IF;

  -- 2. Vincular o profile_id na tabela public.barbers
  -- (Caso a conta tenha acabado de ser criada ou já existisse)
  UPDATE public.barbers SET profile_id = jorge_id WHERE name = 'Jorge Henrique Funke';
  UPDATE public.barbers SET profile_id = peterson_id WHERE name = 'Peterson';
  UPDATE public.barbers SET profile_id = ryan_id WHERE name = 'Ryan';
  UPDATE public.barbers SET profile_id = gabriel_id WHERE name = 'Gabriel';
  UPDATE public.barbers SET profile_id = jerffeson_id WHERE name = 'Jerffeson';
  UPDATE public.barbers SET profile_id = thiago_id WHERE name = 'Thiago Ferreira';
  UPDATE public.barbers SET profile_id = lucas_id WHERE name = 'Lucas Pelizer';

  -- 3. Garantir que o email esteja preenchido na tabela public.profiles (para o app ler corretamente)
  UPDATE public.profiles p SET email = u.email FROM auth.users u WHERE p.id = u.id AND u.email LIKE '%@alces.com.br';

  RAISE NOTICE 'Barbeiros criados e vinculados com sucesso!';
END $$;
