-- ========================================================
-- ALCE'S BARBEARIA - SUPABASE MOBILE BARBER ROLE SUPPORT
-- Execute este script no SQL Editor do Supabase
-- ========================================================

-- 1. Garantir que profile_id exista na tabela barbers (vínculo do barbeiro com auth.users)
ALTER TABLE public.barbers
  ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2. Adicionar client_name como fallback para agendamentos manuais (walk-in)
ALTER TABLE public.appointments
  ADD COLUMN IF NOT EXISTS client_name TEXT;

-- 3. RLS: Barbeiros podem visualizar seus próprios agendamentos
-- Primeiro removemos as políticas antigas para evitar duplicidades
DROP POLICY IF EXISTS "Barbers can view their appointments" ON public.appointments;

CREATE POLICY "Barbers can view their appointments"
  ON public.appointments FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.barbers b
      WHERE b.profile_id = auth.uid()
        AND b.id = appointments.barber_id
    )
  );

-- 4. RLS: Barbeiros podem inserir agendamentos para seus clientes
DROP POLICY IF EXISTS "Barbers can insert appointments" ON public.appointments;

CREATE POLICY "Barbers can insert appointments"
  ON public.appointments FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.barbers b
      WHERE b.profile_id = auth.uid()
        AND b.is_active = true
    )
  );

-- 5. RLS: Barbeiros podem atualizar status dos seus agendamentos (Concluir/Cancelar)
DROP POLICY IF EXISTS "Barbers can update their appointment status" ON public.appointments;

CREATE POLICY "Barbers can update their appointment status"
  ON public.appointments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.barbers b
      WHERE b.profile_id = auth.uid()
        AND b.id = appointments.barber_id
    )
  );
