-- ==============================================
-- MIGRAÇÃO DE PAGAMENTOS: ASAAS GATEWAY
-- Execute este script no SQL Editor do Supabase
-- ==============================================

-- 1. Tabela Profiles: Adicionando IDs de cliente Asaas
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS asaas_customer_id TEXT,
ADD COLUMN IF NOT EXISTS active_subscription_id TEXT,
ADD COLUMN IF NOT EXISTS active_subscription_status TEXT;

-- 2. Tabela Appointments: Adicionando tracking de pagamento
ALTER TABLE public.appointments 
ADD COLUMN IF NOT EXISTS asaas_payment_id TEXT,
ADD COLUMN IF NOT EXISTS asaas_payment_url TEXT,
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'PENDING';

-- 3. (Opcional) Criação de tabela de logs de Webhooks
CREATE TABLE IF NOT EXISTS public.asaas_webhooks_log (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  event_type TEXT,
  payment_id TEXT,
  payload JSONB
);
