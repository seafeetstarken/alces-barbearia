-- =========================================================================
-- ADICIONA COLUNA CPF E ATUALIZA GATILHO DE NOVO USUÁRIO
-- Execute este script no SQL Editor do Supabase.
-- =========================================================================

-- 1. Adiciona a coluna CPF se ela não existir
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS cpf TEXT;

-- 2. Atualiza a função de cadastro de novo usuário para herdar E-mail e CPF
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone, email, cpf)
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.raw_user_meta_data->>'phone',
    new.email,
    new.raw_user_meta_data->>'cpf'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
