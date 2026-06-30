-- ==============================================
-- ALCES BARBEARIA - REPARO DE ESQUEMA E RELACIONAMENTOS (SQL EDITOR)
-- Execute este script no SQL Editor do Supabase no banco oficial: baafdmeulyzpcgbqqeut
-- ==============================================

-- Habilitar extensão UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Garantir que as colunas adicionais existam em public.barbers
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS profile_id UUID;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS initials TEXT;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS hire_date DATE;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS level TEXT DEFAULT 'junior';
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS level_multiplier DECIMAL DEFAULT 1.0;
ALTER TABLE public.barbers ADD COLUMN IF NOT EXISTS is_leader BOOLEAN DEFAULT FALSE;

-- Adicionar FK de perfil nos barbeiros
ALTER TABLE public.barbers DROP CONSTRAINT IF EXISTS barbers_profile_id_fkey;
ALTER TABLE public.barbers ADD CONSTRAINT barbers_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- 2. Garantir que public.settings exista e tenha a FK correta
CREATE TABLE IF NOT EXISTS public.settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  logo_url TEXT,
  primary_color TEXT DEFAULT '#D4A03C',
  secondary_color TEXT DEFAULT '#6B7280',
  background_color TEXT DEFAULT '#1A1614',
  card_color TEXT DEFAULT '#26211E',
  font_family TEXT DEFAULT 'Source Sans Pro',
  border_radius TEXT DEFAULT '1',
  spacing TEXT DEFAULT 'normal',
  theme TEXT DEFAULT 'dark',
  custom_domain TEXT,
  commission_percentage DECIMAL DEFAULT 43,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(store_id)
);
ALTER TABLE public.settings DROP CONSTRAINT IF EXISTS settings_store_id_fkey;
ALTER TABLE public.settings ADD CONSTRAINT settings_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;

-- 3. Garantir que public.clients exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active',
  preferred_barber_id UUID,
  total_visits INTEGER DEFAULT 0,
  last_visit_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.clients DROP CONSTRAINT IF EXISTS clients_store_id_fkey;
ALTER TABLE public.clients ADD CONSTRAINT clients_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.clients DROP CONSTRAINT IF EXISTS clients_preferred_barber_id_fkey;
ALTER TABLE public.clients ADD CONSTRAINT clients_preferred_barber_id_fkey FOREIGN KEY (preferred_barber_id) REFERENCES public.barbers(id) ON DELETE SET NULL;

-- 4. Garantir que public.cash_registers exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.cash_registers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  opened_by UUID,
  closed_by UUID,
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  opening_balance DECIMAL DEFAULT 0,
  closing_balance DECIMAL,
  status TEXT DEFAULT 'open'
);
ALTER TABLE public.cash_registers DROP CONSTRAINT IF EXISTS cash_registers_store_id_fkey;
ALTER TABLE public.cash_registers ADD CONSTRAINT cash_registers_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.cash_registers DROP CONSTRAINT IF EXISTS cash_registers_opened_by_fkey;
ALTER TABLE public.cash_registers ADD CONSTRAINT cash_registers_opened_by_fkey FOREIGN KEY (opened_by) REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.cash_registers DROP CONSTRAINT IF EXISTS cash_registers_closed_by_fkey;
ALTER TABLE public.cash_registers ADD CONSTRAINT cash_registers_closed_by_fkey FOREIGN KEY (closed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- 5. Garantir que public.transactions exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  cash_register_id UUID,
  barber_id UUID,
  client_id UUID,
  type TEXT NOT NULL,
  description TEXT,
  amount DECIMAL NOT NULL,
  payment_method TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_store_id_fkey;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_cash_register_id_fkey;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_cash_register_id_fkey FOREIGN KEY (cash_register_id) REFERENCES public.cash_registers(id) ON DELETE SET NULL;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_barber_id_fkey;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_barber_id_fkey FOREIGN KEY (barber_id) REFERENCES public.barbers(id) ON DELETE SET NULL;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_client_id_fkey;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

-- 6. Garantir que public.transaction_items exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID,
  service_id UUID,
  product_id UUID,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL NOT NULL,
  points INTEGER DEFAULT 0
);
ALTER TABLE public.transaction_items DROP CONSTRAINT IF EXISTS transaction_items_transaction_id_fkey;
ALTER TABLE public.transaction_items ADD CONSTRAINT transaction_items_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;
ALTER TABLE public.transaction_items DROP CONSTRAINT IF EXISTS transaction_items_service_id_fkey;
ALTER TABLE public.transaction_items ADD CONSTRAINT transaction_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE SET NULL;
ALTER TABLE public.transaction_items DROP CONSTRAINT IF EXISTS transaction_items_product_id_fkey;
ALTER TABLE public.transaction_items ADD CONSTRAINT transaction_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;

-- 7. Garantir que public.points exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  barber_id UUID,
  transaction_id UUID,
  points INTEGER NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.points DROP CONSTRAINT IF EXISTS points_store_id_fkey;
ALTER TABLE public.points ADD CONSTRAINT points_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.points DROP CONSTRAINT IF EXISTS points_barber_id_fkey;
ALTER TABLE public.points ADD CONSTRAINT points_barber_id_fkey FOREIGN KEY (barber_id) REFERENCES public.barbers(id) ON DELETE CASCADE;
ALTER TABLE public.points DROP CONSTRAINT IF EXISTS points_transaction_id_fkey;
ALTER TABLE public.points ADD CONSTRAINT points_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;

-- 8. Garantir que public.commissions exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  barber_id UUID,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_points INTEGER DEFAULT 0,
  base_value DECIMAL DEFAULT 0,
  multiplier DECIMAL DEFAULT 1.0,
  final_value DECIMAL DEFAULT 0,
  status TEXT DEFAULT 'pending',
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.commissions DROP CONSTRAINT IF EXISTS commissions_store_id_fkey;
ALTER TABLE public.commissions ADD CONSTRAINT commissions_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.commissions DROP CONSTRAINT IF EXISTS commissions_barber_id_fkey;
ALTER TABLE public.commissions ADD CONSTRAINT commissions_barber_id_fkey FOREIGN KEY (barber_id) REFERENCES public.barbers(id) ON DELETE CASCADE;

-- 9. Garantir que public.expenses exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  cash_register_id UUID,
  category TEXT NOT NULL,
  description TEXT,
  amount DECIMAL NOT NULL,
  expense_date DATE DEFAULT CURRENT_DATE,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_store_id_fkey;
ALTER TABLE public.expenses ADD CONSTRAINT expenses_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_cash_register_id_fkey;
ALTER TABLE public.expenses ADD CONSTRAINT expenses_cash_register_id_fkey FOREIGN KEY (cash_register_id) REFERENCES public.cash_registers(id) ON DELETE SET NULL;
ALTER TABLE public.expenses DROP CONSTRAINT IF EXISTS expenses_created_by_fkey;
ALTER TABLE public.expenses ADD CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- 10. Garantir que public.goals exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  barber_id UUID,
  type TEXT NOT NULL,
  target_value DECIMAL NOT NULL,
  current_value DECIMAL DEFAULT 0,
  period TEXT DEFAULT 'monthly',
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_achieved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.goals DROP CONSTRAINT IF EXISTS goals_store_id_fkey;
ALTER TABLE public.goals ADD CONSTRAINT goals_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.goals DROP CONSTRAINT IF EXISTS goals_barber_id_fkey;
ALTER TABLE public.goals ADD CONSTRAINT goals_barber_id_fkey FOREIGN KEY (barber_id) REFERENCES public.barbers(id) ON DELETE CASCADE;

-- 11. Garantir que public.schedules exista e tenha as FKs corretas
CREATE TABLE IF NOT EXISTS public.schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID,
  barber_id UUID,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);
ALTER TABLE public.schedules DROP CONSTRAINT IF EXISTS schedules_store_id_fkey;
ALTER TABLE public.schedules ADD CONSTRAINT schedules_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id) ON DELETE CASCADE;
ALTER TABLE public.schedules DROP CONSTRAINT IF EXISTS schedules_barber_id_fkey;
ALTER TABLE public.schedules ADD CONSTRAINT schedules_barber_id_fkey FOREIGN KEY (barber_id) REFERENCES public.barbers(id) ON DELETE CASCADE;

-- 12. Habilitar RLS em todas as tabelas
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_registers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;

-- 13. Criar políticas de acesso amplo para usuários autenticados no web admin
DROP POLICY IF EXISTS settings_select ON public.settings;
DROP POLICY IF EXISTS settings_all ON public.settings;
CREATE POLICY settings_select ON public.settings FOR SELECT TO authenticated USING (true);
CREATE POLICY settings_all ON public.settings FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS clients_select ON public.clients;
DROP POLICY IF EXISTS clients_all ON public.clients;
CREATE POLICY clients_select ON public.clients FOR SELECT TO authenticated USING (true);
CREATE POLICY clients_all ON public.clients FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS cash_registers_select ON public.cash_registers;
DROP POLICY IF EXISTS cash_registers_all ON public.cash_registers;
CREATE POLICY cash_registers_select ON public.cash_registers FOR SELECT TO authenticated USING (true);
CREATE POLICY cash_registers_all ON public.cash_registers FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS transactions_select ON public.transactions;
DROP POLICY IF EXISTS transactions_all ON public.transactions;
CREATE POLICY transactions_select ON public.transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY transactions_all ON public.transactions FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS transaction_items_select ON public.transaction_items;
DROP POLICY IF EXISTS transaction_items_all ON public.transaction_items;
CREATE POLICY transaction_items_select ON public.transaction_items FOR SELECT TO authenticated USING (true);
CREATE POLICY transaction_items_all ON public.transaction_items FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS points_select ON public.points;
DROP POLICY IF EXISTS points_all ON public.points;
CREATE POLICY points_select ON public.points FOR SELECT TO authenticated USING (true);
CREATE POLICY points_all ON public.points FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS commissions_select ON public.commissions;
DROP POLICY IF EXISTS commissions_all ON public.commissions;
CREATE POLICY commissions_select ON public.commissions FOR SELECT TO authenticated USING (true);
CREATE POLICY commissions_all ON public.commissions FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS expenses_select ON public.expenses;
DROP POLICY IF EXISTS expenses_all ON public.expenses;
CREATE POLICY expenses_select ON public.expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY expenses_all ON public.expenses FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS goals_select ON public.goals;
DROP POLICY IF EXISTS goals_all ON public.goals;
CREATE POLICY goals_select ON public.goals FOR SELECT TO authenticated USING (true);
CREATE POLICY goals_all ON public.goals FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS schedules_select ON public.schedules;
DROP POLICY IF EXISTS schedules_all ON public.schedules;
CREATE POLICY schedules_select ON public.schedules FOR SELECT TO authenticated USING (true);
CREATE POLICY schedules_all ON public.schedules FOR ALL TO authenticated USING (true);

-- 14. Recarregar o cache do Postgrest
NOTIFY pgrst, 'reload schema';
