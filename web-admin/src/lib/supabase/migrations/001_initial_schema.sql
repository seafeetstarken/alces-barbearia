-- ============================================
-- Salão Justo - Initial Database Schema
-- White Label: Alce's Barbearia (first client)
-- ============================================
-- Run this in Supabase SQL Editor for each new client

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES (extends auth.users)
-- ============================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'barber' CHECK (role IN ('owner', 'manager', 'leader', 'barber')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'barber')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STORES
-- ============================================
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  open_time TIME DEFAULT '08:30',
  close_time TIME DEFAULT '20:00',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default store for Alce's
INSERT INTO stores (name, phone, address, open_time, close_time) VALUES
  ('Alce''s Barbearia - Matriz', '5547996155719', 'R. Erich Steinbach, 22 – sl 02 – Itoupava Seca, Blumenau – SC', '08:30', '20:00'),
  ('Alce''s Barbearia - Escola Agrícola', '5547996155719', 'R. Benjamin Constant, 939 – Escola Agrícola, Blumenau – SC', '08:30', '20:00');

-- ============================================
-- SETTINGS (White Label)
-- ============================================
CREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  logo_url TEXT,
  primary_color TEXT DEFAULT '#D4A03C', -- Alce's gold/amber color
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

-- ============================================
-- BARBERS
-- ============================================
CREATE TABLE barbers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  initials TEXT,
  phone TEXT,
  email TEXT,
  hire_date DATE,
  level TEXT DEFAULT 'junior' CHECK (level IN ('junior', 'professional', 'senior', 'master')),
  level_multiplier DECIMAL DEFAULT 1.0,
  is_leader BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SERVICES
-- ============================================
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL NOT NULL,
  duration_minutes INTEGER DEFAULT 30,
  points INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Default services for barbershop
INSERT INTO services (store_id, name, price, duration_minutes, points)
SELECT id, 'Corte', 45.00, 30, 1 FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO services (store_id, name, price, duration_minutes, points)
SELECT id, 'Corte + Barba', 65.00, 45, 2 FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO services (store_id, name, price, duration_minutes, points)
SELECT id, 'Barba', 35.00, 20, 1 FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO services (store_id, name, price, duration_minutes, points)
SELECT id, 'Pigmentação', 80.00, 40, 2 FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

-- ============================================
-- PRODUCTS
-- ============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL NOT NULL,
  cost DECIMAL,
  stock_quantity INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 5,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CLIENTS
-- ============================================
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  notes TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blacklisted', 'overdue')),
  preferred_barber_id UUID REFERENCES barbers(id) ON DELETE SET NULL,
  total_visits INTEGER DEFAULT 0,
  last_visit_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CASH REGISTERS
-- ============================================
CREATE TABLE cash_registers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  opened_by UUID REFERENCES profiles(id),
  closed_by UUID REFERENCES profiles(id),
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  opening_balance DECIMAL DEFAULT 0,
  closing_balance DECIMAL,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed'))
);

-- ============================================
-- TRANSACTIONS
-- ============================================
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  cash_register_id UUID REFERENCES cash_registers(id) ON DELETE SET NULL,
  barber_id UUID REFERENCES barbers(id) ON DELETE SET NULL,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  type TEXT NOT NULL CHECK (type IN ('service', 'product', 'expense', 'withdrawal', 'deposit')),
  description TEXT,
  amount DECIMAL NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('cash', 'card', 'pix')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TRANSACTION ITEMS
-- ============================================
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL NOT NULL,
  points INTEGER DEFAULT 0
);

-- ============================================
-- POINTS (per service)
-- ============================================
CREATE TABLE points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES barbers(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
  points INTEGER NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- COMMISSIONS
-- ============================================
CREATE TABLE commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES barbers(id) ON DELETE CASCADE,
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

-- ============================================
-- EXPENSES
-- ============================================
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  cash_register_id UUID REFERENCES cash_registers(id) ON DELETE SET NULL,
  category TEXT NOT NULL,
  description TEXT,
  amount DECIMAL NOT NULL,
  expense_date DATE DEFAULT CURRENT_DATE,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- GOALS
-- ============================================
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES barbers(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('revenue', 'services', 'products')),
  target_value DECIMAL NOT NULL,
  current_value DECIMAL DEFAULT 0,
  period TEXT DEFAULT 'monthly' CHECK (period IN ('daily', 'weekly', 'monthly')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_achieved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SCHEDULES
-- ============================================
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES barbers(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

-- ============================================
-- CAREER LEVELS
-- ============================================
CREATE TABLE career_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  level_order INTEGER NOT NULL,
  multiplier DECIMAL DEFAULT 1.0,
  min_months INTEGER DEFAULT 0,
  min_services INTEGER DEFAULT 0,
  min_rating DECIMAL DEFAULT 0,
  benefits TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Default career levels
INSERT INTO career_levels (store_id, name, level_order, multiplier, min_months, min_services, benefits)
SELECT id, 'Júnior', 1, 0.8, 0, 0, 'Treinamento básico' FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO career_levels (store_id, name, level_order, multiplier, min_months, min_services, benefits)
SELECT id, 'Profissional', 2, 1.0, 6, 500, 'Comissão padrão' FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO career_levels (store_id, name, level_order, multiplier, min_months, min_services, benefits)
SELECT id, 'Sênior', 3, 1.2, 18, 2000, 'Bônus de 20% + benefícios' FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

INSERT INTO career_levels (store_id, name, level_order, multiplier, min_months, min_services, benefits)
SELECT id, 'Master', 4, 1.5, 36, 5000, 'Bônus de 50% + liderança de equipe' FROM stores WHERE name LIKE 'Alce%' LIMIT 1;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE barbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_registers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE points ENABLE ROW LEVEL SECURITY;
ALTER TABLE commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_levels ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (allow authenticated users to read all, owners can do everything)
-- For simplicity in White Label deploy-per-client model, all authenticated users can read

CREATE POLICY "Authenticated can read profiles" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

CREATE POLICY "Authenticated can read stores" ON stores FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can manage stores" ON stores FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'owner'));

CREATE POLICY "Authenticated can read settings" ON settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can manage settings" ON settings FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'owner'));

CREATE POLICY "Authenticated can read barbers" ON barbers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage barbers" ON barbers FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read services" ON services FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage services" ON services FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read products" ON products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage products" ON products FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read clients" ON clients FOR SELECT TO authenticated USING (true);
CREATE POLICY "All staff can manage clients" ON clients FOR ALL TO authenticated USING (true);

CREATE POLICY "Authenticated can read cash_registers" ON cash_registers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage cash_registers" ON cash_registers FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read transactions" ON transactions FOR SELECT TO authenticated USING (true);
CREATE POLICY "All staff can create transactions" ON transactions FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated can read transaction_items" ON transaction_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "All staff can create transaction_items" ON transaction_items FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated can read points" ON points FOR SELECT TO authenticated USING (true);
CREATE POLICY "System can manage points" ON points FOR ALL TO authenticated USING (true);

CREATE POLICY "Authenticated can read commissions" ON commissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage commissions" ON commissions FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read expenses" ON expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage expenses" ON expenses FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read goals" ON goals FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage goals" ON goals FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read schedules" ON schedules FOR SELECT TO authenticated USING (true);
CREATE POLICY "Managers+ can manage schedules" ON schedules FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('owner', 'manager')));

CREATE POLICY "Authenticated can read career_levels" ON career_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can manage career_levels" ON career_levels FOR ALL TO authenticated 
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'owner'));

-- ============================================
-- INDEXES for performance
-- ============================================
CREATE INDEX idx_barbers_store ON barbers(store_id);
CREATE INDEX idx_services_store ON services(store_id);
CREATE INDEX idx_products_store ON products(store_id);
CREATE INDEX idx_clients_store ON clients(store_id);
CREATE INDEX idx_transactions_store ON transactions(store_id);
CREATE INDEX idx_transactions_date ON transactions(created_at);
CREATE INDEX idx_points_barber ON points(barber_id);
CREATE INDEX idx_commissions_barber ON commissions(barber_id);
CREATE INDEX idx_schedules_barber ON schedules(barber_id);
