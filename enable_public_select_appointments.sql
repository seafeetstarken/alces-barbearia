-- ========================================================
-- ALCE'S BARBEARIA - SQL MIGRATION & BUG FIXES
-- ========================================================

-- 1. Dropar a tabela antiga se existir e criá-la do zero para garantir todas as chaves estrangeiras
DROP TABLE IF EXISTS public.user_store_memberships CASCADE;

CREATE TABLE public.user_store_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'manager', 'leader', 'barber')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, store_id)
);

-- Habilitar RLS na tabela
ALTER TABLE public.user_store_memberships ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS memberships_select ON public.user_store_memberships;
DROP POLICY IF EXISTS memberships_insert ON public.user_store_memberships;
DROP POLICY IF EXISTS memberships_update ON public.user_store_memberships;
DROP POLICY IF EXISTS memberships_delete ON public.user_store_memberships;

-- Criar políticas robustas de acesso sem dependência de funções externas
CREATE POLICY memberships_select ON public.user_store_memberships 
FOR SELECT USING (
  user_id = auth.uid() 
  OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY memberships_insert ON public.user_store_memberships 
FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY memberships_update ON public.user_store_memberships 
FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY memberships_delete ON public.user_store_memberships 
FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

-- 2. Remover as políticas antigas de agendamento se existirem e criar a nova pública
DROP POLICY IF EXISTS "Users can view own appointments" ON public.appointments;
DROP POLICY IF EXISTS "Anyone can view appointments to see occupied slots" ON public.appointments;

CREATE POLICY "Anyone can view appointments to see occupied slots"
ON public.appointments FOR SELECT
USING (true);
-- Adicionar as colunas de permissão e plano na tabela de perfis (profiles) se não existirem
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'barber',
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS active_plan TEXT,
ADD COLUMN IF NOT EXISTS active_subscription_status TEXT DEFAULT 'INACTIVE';

-- Atualizar/criar restrição (constraint) de valores para role
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('owner', 'manager', 'leader', 'barber', 'super_admin'));

-- Sincronizar assinaturas ativas existentes com a tabela de perfis
UPDATE public.profiles p
SET 
  active_plan = pl.name,
  active_subscription_status = 'ACTIVE'
FROM public.user_subscriptions us
JOIN public.plans pl ON us.plan_id = pl.id
WHERE us.user_id = p.id
  AND us.status = 'Ativo';

-- Vincular todos os administradores (is_admin = true) a todas as lojas criadas no banco
INSERT INTO public.user_store_memberships (user_id, store_id, role, is_active)
SELECT p.id, s.id, 'owner', true
FROM public.profiles p
CROSS JOIN public.stores s
WHERE p.is_admin = true
ON CONFLICT (user_id, store_id) DO UPDATE SET role = 'owner', is_active = true;
