-- ==============================================
-- CORREÇÃO DE LOGIN: CONFIRMAÇÃO DE EMAIL MVP
-- Rode isso no SQL Editor do Supabase
-- ==============================================

-- 1. Confirma todos os usuários que já tentaram criar conta e ficaram travados
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- 2. (Opcional) Cria um gatilho para auto-confirmar os próximos usuários que se cadastrarem
CREATE OR REPLACE FUNCTION public.auto_confirm_users()
RETURNS TRIGGER AS $$
BEGIN
  NEW.email_confirmed_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created_confirm ON auth.users;

CREATE TRIGGER on_auth_user_created_confirm
BEFORE INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_users();
