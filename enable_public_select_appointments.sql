-- ========================================================
-- ALCE'S BARBEARIA - ENABLE APPOINTMENTS SELECT FOR PUBLIC/CLIENTS
-- Execute este script no SQL Editor do Supabase para corrigir
-- a falha de horários agendados por outros clientes não aparecerem
-- bloqueados no calendário.
-- ========================================================

-- Remover a política antiga restritiva se existir
DROP POLICY IF EXISTS "Users can view own appointments" ON public.appointments;
DROP POLICY IF EXISTS "Anyone can view appointments to see occupied slots" ON public.appointments;

-- Criar a nova política que permite a qualquer usuário autenticado (ou anônimo) visualizar
-- os agendamentos cadastrados (necessário para o calendário poder checar quais slots estão ocupados)
CREATE POLICY "Anyone can view appointments to see occupied slots"
ON public.appointments FOR SELECT
USING (true);
-- Adicionar as colunas de plano na tabela de perfis (profiles) se não existirem
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS active_plan TEXT,
ADD COLUMN IF NOT EXISTS active_subscription_status TEXT DEFAULT 'INACTIVE';

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
