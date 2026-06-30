-- ========================================================
-- ALCE'S BARBEARIA - ENABLE APPOINTMENTS SELECT FOR PUBLIC/CLIENTS
-- Execute este script no SQL Editor do Supabase para corrigir
-- a falha de horários agendados por outros clientes não aparecerem
-- bloqueados no calendário.
-- ========================================================

-- Remover a política antiga restritiva se existir
DROP POLICY IF EXISTS "Users can view own appointments" ON public.appointments;

-- Criar a nova política que permite a qualquer usuário autenticado (ou anônimo) visualizar
-- os agendamentos cadastrados (necessário para o calendário poder checar quais slots estão ocupados)
CREATE POLICY "Anyone can view appointments to see occupied slots"
ON public.appointments FOR SELECT
USING (true);
