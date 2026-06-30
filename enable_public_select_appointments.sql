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

-- ========================================================
-- 3. AJUSTES DE TABELAS EXISTENTES (Serviços, Produtos, Barbeiros)
-- ========================================================

-- Adicionar colunas na tabela de serviços (services) se não existirem
ALTER TABLE public.services 
ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS points INTEGER DEFAULT 1;

-- Adicionar colunas na tabela de produtos (products) se não existirem
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS min_stock INTEGER DEFAULT 5;

-- Adicionar colunas na tabela de barbeiros (barbers) se não existirem
ALTER TABLE public.barbers 
ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS initials TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS hire_date DATE,
ADD COLUMN IF NOT EXISTS level TEXT DEFAULT 'junior',
ADD COLUMN IF NOT EXISTS level_multiplier DECIMAL DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS is_leader BOOLEAN DEFAULT FALSE;

-- Atualizar/criar restrição (constraint) de level na tabela barbers
ALTER TABLE public.barbers DROP CONSTRAINT IF EXISTS barbers_level_check;
ALTER TABLE public.barbers ADD CONSTRAINT barbers_level_check CHECK (level IN ('junior', 'professional', 'senior', 'master'));

-- Preencher store_id padrão (vincula os registros órfãos à primeira loja do banco)
UPDATE public.services SET store_id = (SELECT id FROM public.stores LIMIT 1) WHERE store_id IS NULL;
UPDATE public.products SET store_id = (SELECT id FROM public.stores LIMIT 1) WHERE store_id IS NULL;
UPDATE public.barbers SET store_id = (SELECT id FROM public.stores LIMIT 1) WHERE store_id IS NULL;

-- ========================================================
-- 4. CRIAÇÃO DAS TABELAS DO WEB ADMIN QUE FALTAM NO BANCO
-- ========================================================

-- settings
CREATE TABLE IF NOT EXISTS public.settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
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

-- clients
CREATE TABLE IF NOT EXISTS public.clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blacklisted', 'overdue')),
  preferred_barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
  total_visits INTEGER DEFAULT 0,
  last_visit_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- cash_registers
CREATE TABLE IF NOT EXISTS public.cash_registers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  opened_by UUID REFERENCES public.profiles(id),
  closed_by UUID REFERENCES public.profiles(id),
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  opening_balance DECIMAL DEFAULT 0,
  closing_balance DECIMAL,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed'))
);

-- transactions
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  cash_register_id UUID REFERENCES public.cash_registers(id) ON DELETE SET NULL,
  barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
  client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('service', 'product', 'expense', 'withdrawal', 'deposit')),
  description TEXT,
  amount DECIMAL NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('cash', 'card', 'pix')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- transaction_items
CREATE TABLE IF NOT EXISTS public.transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
  service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL NOT NULL,
  points INTEGER DEFAULT 0
);

-- points
CREATE TABLE IF NOT EXISTS public.points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
  points INTEGER NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW()
);

-- commissions
CREATE TABLE IF NOT EXISTS public.commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_points INTEGER DEFAULT 0,
  base_value DECIMAL DEFAULT 0,
  multiplier DECIMAL DEFAULT 1.0,
  final_value DECIMAL DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- expenses
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  cash_register_id UUID REFERENCES public.cash_registers(id) ON DELETE SET NULL,
  category TEXT NOT NULL,
  description TEXT,
  amount DECIMAL NOT NULL,
  expense_date DATE DEFAULT CURRENT_DATE,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- goals
CREATE TABLE IF NOT EXISTS public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('revenue', 'services', 'products')),
  target_value DECIMAL NOT NULL,
  current_value DECIMAL DEFAULT 0,
  period TEXT DEFAULT 'monthly' CHECK (period IN ('daily', 'weekly', 'monthly')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_achieved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- schedules
CREATE TABLE IF NOT EXISTS public.schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

-- career_levels
CREATE TABLE IF NOT EXISTS public.career_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  level_order INTEGER NOT NULL,
  multiplier DECIMAL DEFAULT 1.0,
  min_months INTEGER DEFAULT 0,
  min_services INTEGER DEFAULT 0,
  min_rating DECIMAL DEFAULT 0,
  benefits TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================================
-- 5. ATIVAÇÃO DE SEGURANÇA E POLÍTICAS DE RLS (Web Admin)
-- ========================================================

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
ALTER TABLE public.career_levels ENABLE ROW LEVEL SECURITY;

-- Excluir políticas antigas para evitar duplicidade
DROP POLICY IF EXISTS settings_select ON public.settings;
DROP POLICY IF EXISTS settings_all ON public.settings;
DROP POLICY IF EXISTS clients_select ON public.clients;
DROP POLICY IF EXISTS clients_all ON public.clients;
DROP POLICY IF EXISTS cash_registers_select ON public.cash_registers;
DROP POLICY IF EXISTS cash_registers_all ON public.cash_registers;
DROP POLICY IF EXISTS transactions_select ON public.transactions;
DROP POLICY IF EXISTS transactions_all ON public.transactions;
DROP POLICY IF EXISTS transaction_items_select ON public.transaction_items;
DROP POLICY IF EXISTS transaction_items_all ON public.transaction_items;
DROP POLICY IF EXISTS points_select ON public.points;
DROP POLICY IF EXISTS points_all ON public.points;
DROP POLICY IF EXISTS commissions_select ON public.commissions;
DROP POLICY IF EXISTS commissions_all ON public.commissions;
DROP POLICY IF EXISTS expenses_select ON public.expenses;
DROP POLICY IF EXISTS expenses_all ON public.expenses;
DROP POLICY IF EXISTS goals_select ON public.goals;
DROP POLICY IF EXISTS goals_all ON public.goals;
DROP POLICY IF EXISTS schedules_select ON public.schedules;
DROP POLICY IF EXISTS schedules_all ON public.schedules;
DROP POLICY IF EXISTS career_levels_select ON public.career_levels;
DROP POLICY IF EXISTS career_levels_all ON public.career_levels;

-- Criar novas políticas robustas de acesso
CREATE POLICY settings_select ON public.settings FOR SELECT TO authenticated USING (true);
CREATE POLICY settings_all ON public.settings FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY clients_select ON public.clients FOR SELECT TO authenticated USING (true);
CREATE POLICY clients_all ON public.clients FOR ALL TO authenticated USING (true);

CREATE POLICY cash_registers_select ON public.cash_registers FOR SELECT TO authenticated USING (true);
CREATE POLICY cash_registers_all ON public.cash_registers FOR ALL TO authenticated USING (true);

CREATE POLICY transactions_select ON public.transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY transactions_all ON public.transactions FOR ALL TO authenticated USING (true);

CREATE POLICY transaction_items_select ON public.transaction_items FOR SELECT TO authenticated USING (true);
CREATE POLICY transaction_items_all ON public.transaction_items FOR ALL TO authenticated USING (true);

CREATE POLICY points_select ON public.points FOR SELECT TO authenticated USING (true);
CREATE POLICY points_all ON public.points FOR ALL TO authenticated USING (true);

CREATE POLICY commissions_select ON public.commissions FOR SELECT TO authenticated USING (true);
CREATE POLICY commissions_all ON public.commissions FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY expenses_select ON public.expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY expenses_all ON public.expenses FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY goals_select ON public.goals FOR SELECT TO authenticated USING (true);
CREATE POLICY goals_all ON public.goals FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY schedules_select ON public.schedules FOR SELECT TO authenticated USING (true);
CREATE POLICY schedules_all ON public.schedules FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

CREATE POLICY career_levels_select ON public.career_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY career_levels_all ON public.career_levels FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

