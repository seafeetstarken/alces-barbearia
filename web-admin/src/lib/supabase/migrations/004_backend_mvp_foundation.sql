CREATE TABLE IF NOT EXISTS user_store_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'manager', 'leader', 'barber')),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, store_id)
);

INSERT INTO user_store_memberships (user_id, store_id, role, is_active)
SELECT
  b.profile_id,
  b.store_id,
  CASE
    WHEN p.role IN ('owner', 'manager', 'leader', 'barber') THEN p.role
    WHEN b.is_leader = TRUE THEN 'leader'
    ELSE 'barber'
  END,
  TRUE
FROM barbers b
LEFT JOIN profiles p ON p.id = b.profile_id
WHERE b.profile_id IS NOT NULL
ON CONFLICT (user_id, store_id) DO UPDATE SET
  role = EXCLUDED.role,
  is_active = TRUE,
  updated_at = NOW();

INSERT INTO user_store_memberships (user_id, store_id, role, is_active)
SELECT
  p.id,
  s.id,
  p.role,
  TRUE
FROM profiles p
CROSS JOIN LATERAL (
  SELECT id
  FROM stores
  ORDER BY created_at ASC
  LIMIT 1
) s
WHERE p.role IN ('owner', 'manager', 'leader', 'barber')
AND NOT EXISTS (
  SELECT 1
  FROM user_store_memberships m
  WHERE m.user_id = p.id
)
ON CONFLICT (user_id, store_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  billing_interval TEXT NOT NULL CHECK (billing_interval IN ('monthly', 'yearly')),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  trial_days INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS store_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES subscription_plans(id) ON DELETE SET NULL,
  provider TEXT NOT NULL DEFAULT 'asaas' CHECK (provider IN ('asaas')),
  provider_customer_id TEXT,
  provider_subscription_id TEXT UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('trialing', 'active', 'past_due', 'canceled')),
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscription_invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES store_subscriptions(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  provider_invoice_id TEXT UNIQUE,
  status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'overdue', 'canceled')),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  due_date DATE,
  paid_at TIMESTAMPTZ,
  raw_payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS billing_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
  provider TEXT NOT NULL DEFAULT 'asaas',
  event_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'received' CHECK (status IN ('received', 'processed', 'failed')),
  payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  error_message TEXT,
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(provider, event_id)
);

CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  barber_id UUID REFERENCES barbers(id) ON DELETE SET NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'checked_in', 'completed', 'canceled', 'no_show')),
  notes TEXT,
  source TEXT NOT NULL DEFAULT 'admin' CHECK (source IN ('admin', 'client')),
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (ends_at > starts_at)
);

CREATE TABLE IF NOT EXISTS appointment_services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price DECIMAL NOT NULL CHECK (unit_price >= 0),
  points INTEGER NOT NULL DEFAULT 0 CHECK (points >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cash_register_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  cash_register_id UUID NOT NULL REFERENCES cash_registers(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('opened', 'entry', 'withdrawal', 'expense', 'closed')),
  amount DECIMAL NOT NULL DEFAULT 0,
  description TEXT,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS client_visit_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  barber_id UUID REFERENCES barbers(id) ON DELETE SET NULL,
  amount DECIMAL NOT NULL DEFAULT 0,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS client_segments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  filters JSONB NOT NULL DEFAULT '{}'::JSONB,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(store_id, name)
);

CREATE TABLE IF NOT EXISTS campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  segment_id UUID REFERENCES client_segments(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  objective TEXT NOT NULL,
  channel TEXT NOT NULL CHECK (channel IN ('whatsapp', 'sms', 'email', 'manual')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'paused', 'completed')),
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS campaign_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  status TEXT NOT NULL CHECK (status IN ('delivered', 'opened', 'converted', 'failed')),
  revenue_amount DECIMAL NOT NULL DEFAULT 0,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB
);

CREATE TABLE IF NOT EXISTS cashback_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  trigger_type TEXT NOT NULL CHECK (trigger_type IN ('service_purchase', 'on_time_arrival', 'plan_renewal', 'manual')),
  amount_type TEXT NOT NULL CHECK (amount_type IN ('fixed', 'percentage')),
  amount_value DECIMAL NOT NULL CHECK (amount_value > 0),
  min_amount DECIMAL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cashback_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
  appointment_id UUID REFERENCES appointments(id) ON DELETE SET NULL,
  rule_id UUID REFERENCES cashback_rules(id) ON DELETE SET NULL,
  movement_type TEXT NOT NULL CHECK (movement_type IN ('credit', 'debit', 'expire', 'adjustment')),
  amount DECIMAL NOT NULL CHECK (amount > 0),
  description TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION set_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS user_store_memberships_set_updated_at ON user_store_memberships;
CREATE TRIGGER user_store_memberships_set_updated_at
BEFORE UPDATE ON user_store_memberships
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS subscription_plans_set_updated_at ON subscription_plans;
CREATE TRIGGER subscription_plans_set_updated_at
BEFORE UPDATE ON subscription_plans
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS store_subscriptions_set_updated_at ON store_subscriptions;
CREATE TRIGGER store_subscriptions_set_updated_at
BEFORE UPDATE ON store_subscriptions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS subscription_invoices_set_updated_at ON subscription_invoices;
CREATE TRIGGER subscription_invoices_set_updated_at
BEFORE UPDATE ON subscription_invoices
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS appointments_set_updated_at ON appointments;
CREATE TRIGGER appointments_set_updated_at
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS client_segments_set_updated_at ON client_segments;
CREATE TRIGGER client_segments_set_updated_at
BEFORE UPDATE ON client_segments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS campaigns_set_updated_at ON campaigns;
CREATE TRIGGER campaigns_set_updated_at
BEFORE UPDATE ON campaigns
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

DROP TRIGGER IF EXISTS cashback_rules_set_updated_at ON cashback_rules;
CREATE TRIGGER cashback_rules_set_updated_at
BEFORE UPDATE ON cashback_rules
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_column();

CREATE OR REPLACE FUNCTION is_super_admin(uid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM profiles p
    WHERE p.id = uid
      AND p.role = 'super_admin'
  );
$$;

CREATE OR REPLACE FUNCTION has_store_membership(
  target_store_id UUID,
  allowed_roles TEXT[] DEFAULT ARRAY['owner', 'manager', 'leader', 'barber']::TEXT[]
)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT
    is_super_admin(auth.uid())
    OR EXISTS (
      SELECT 1
      FROM user_store_memberships m
      WHERE m.user_id = auth.uid()
        AND m.store_id = target_store_id
        AND m.is_active = TRUE
        AND m.role = ANY(allowed_roles)
    );
$$;

CREATE OR REPLACE FUNCTION is_store_billing_active(target_store_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COALESCE((
    SELECT s.status IN ('trialing', 'active')
    FROM store_subscriptions s
    WHERE s.store_id = target_store_id
    ORDER BY s.created_at DESC
    LIMIT 1
  ), TRUE);
$$;

CREATE OR REPLACE FUNCTION get_cashback_balance(target_store_id UUID, target_client_id UUID)
RETURNS DECIMAL
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(
    SUM(
      CASE
        WHEN movement_type = 'credit' THEN amount
        WHEN movement_type IN ('debit', 'expire') THEN -amount
        ELSE 0
      END
    ),
    0
  )
  FROM cashback_ledger
  WHERE store_id = target_store_id
    AND client_id = target_client_id;
$$;

CREATE OR REPLACE FUNCTION apply_transaction_side_effects()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL AND NEW.type = 'service' THEN
    INSERT INTO client_visit_history (store_id, client_id, transaction_id, barber_id, amount, occurred_at)
    VALUES (NEW.store_id, NEW.client_id, NEW.id, NEW.barber_id, NEW.amount, NEW.created_at);

    UPDATE clients
    SET
      total_visits = COALESCE(total_visits, 0) + 1,
      last_visit_at = NEW.created_at
    WHERE id = NEW.client_id
      AND store_id = NEW.store_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS transaction_side_effects ON transactions;
CREATE TRIGGER transaction_side_effects
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION apply_transaction_side_effects();

CREATE OR REPLACE FUNCTION log_cash_register_lifecycle()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO cash_register_events (store_id, cash_register_id, event_type, amount, description, created_by)
    VALUES (NEW.store_id, NEW.id, 'opened', NEW.opening_balance, 'Abertura de caixa', NEW.opened_by);
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.status <> NEW.status AND NEW.status = 'closed' THEN
      INSERT INTO cash_register_events (store_id, cash_register_id, event_type, amount, description, created_by)
      VALUES (NEW.store_id, NEW.id, 'closed', COALESCE(NEW.closing_balance, 0), 'Fechamento de caixa', NEW.closed_by);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS cash_register_lifecycle_events ON cash_registers;
CREATE TRIGGER cash_register_lifecycle_events
AFTER INSERT OR UPDATE ON cash_registers
FOR EACH ROW
EXECUTE FUNCTION log_cash_register_lifecycle();

CREATE OR REPLACE FUNCTION api_store_subscription_status(target_store_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  subscription_row JSONB;
BEGIN
  IF NOT has_store_membership(target_store_id) THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', 'FORBIDDEN', 'message', 'Acesso não autorizado para a loja'),
      'meta', jsonb_build_object('store_id', target_store_id)
    );
  END IF;

  SELECT to_jsonb(s)
  INTO subscription_row
  FROM store_subscriptions s
  WHERE s.store_id = target_store_id
  ORDER BY s.created_at DESC
  LIMIT 1;

  RETURN jsonb_build_object(
    'data', COALESCE(subscription_row, '{}'::JSONB),
    'error', NULL,
    'meta', jsonb_build_object('store_id', target_store_id)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', SQLSTATE, 'message', SQLERRM),
      'meta', jsonb_build_object('store_id', target_store_id)
    );
END;
$$;

CREATE OR REPLACE FUNCTION api_cashback_statement(
  target_store_id UUID,
  target_client_id UUID,
  page_size INTEGER DEFAULT 20,
  page_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  statement_rows JSONB;
  balance_value DECIMAL;
BEGIN
  IF NOT has_store_membership(target_store_id) THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', 'FORBIDDEN', 'message', 'Acesso não autorizado para a loja'),
      'meta', jsonb_build_object('store_id', target_store_id)
    );
  END IF;

  SELECT COALESCE(jsonb_agg(to_jsonb(x)), '[]'::JSONB)
  INTO statement_rows
  FROM (
    SELECT *
    FROM cashback_ledger
    WHERE store_id = target_store_id
      AND client_id = target_client_id
    ORDER BY created_at DESC
    LIMIT GREATEST(page_size, 1)
    OFFSET GREATEST(page_offset, 0)
  ) x;

  balance_value := get_cashback_balance(target_store_id, target_client_id);

  RETURN jsonb_build_object(
    'data', jsonb_build_object('balance', balance_value, 'statement', statement_rows),
    'error', NULL,
    'meta', jsonb_build_object('store_id', target_store_id, 'client_id', target_client_id, 'limit', page_size, 'offset', page_offset)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', SQLSTATE, 'message', SQLERRM),
      'meta', jsonb_build_object('store_id', target_store_id, 'client_id', target_client_id)
    );
END;
$$;

CREATE OR REPLACE FUNCTION api_campaign_overview(target_store_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  campaign_rows JSONB;
BEGIN
  IF NOT has_store_membership(target_store_id) THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', 'FORBIDDEN', 'message', 'Acesso não autorizado para a loja'),
      'meta', jsonb_build_object('store_id', target_store_id)
    );
  END IF;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'status', c.status,
        'objective', c.objective,
        'channel', c.channel,
        'starts_at', c.starts_at,
        'ends_at', c.ends_at,
        'delivered', COALESCE(r.delivered, 0),
        'opened', COALESCE(r.opened, 0),
        'converted', COALESCE(r.converted, 0),
        'revenue_amount', COALESCE(r.revenue_amount, 0)
      )
    ),
    '[]'::JSONB
  )
  INTO campaign_rows
  FROM campaigns c
  LEFT JOIN LATERAL (
    SELECT
      COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
      COUNT(*) FILTER (WHERE status = 'opened') AS opened,
      COUNT(*) FILTER (WHERE status = 'converted') AS converted,
      COALESCE(SUM(revenue_amount), 0) AS revenue_amount
    FROM campaign_results cr
    WHERE cr.campaign_id = c.id
  ) r ON TRUE
  WHERE c.store_id = target_store_id;

  RETURN jsonb_build_object(
    'data', campaign_rows,
    'error', NULL,
    'meta', jsonb_build_object('store_id', target_store_id)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'data', NULL,
      'error', jsonb_build_object('code', SQLSTATE, 'message', SQLERRM),
      'meta', jsonb_build_object('store_id', target_store_id)
    );
END;
$$;

ALTER TABLE user_store_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_register_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_visit_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE cashback_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE cashback_ledger ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated can read profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Super Admins can do everything" ON profiles;
DROP POLICY IF EXISTS "Authenticated can read stores" ON stores;
DROP POLICY IF EXISTS "Owners can manage stores" ON stores;
DROP POLICY IF EXISTS "Super Admins can manage stores" ON stores;
DROP POLICY IF EXISTS "Authenticated can read settings" ON settings;
DROP POLICY IF EXISTS "Owners can manage settings" ON settings;
DROP POLICY IF EXISTS "Super Admins can manage settings" ON settings;
DROP POLICY IF EXISTS "Authenticated can read barbers" ON barbers;
DROP POLICY IF EXISTS "Managers+ can manage barbers" ON barbers;
DROP POLICY IF EXISTS "Authenticated can read services" ON services;
DROP POLICY IF EXISTS "Managers+ can manage services" ON services;
DROP POLICY IF EXISTS "Authenticated can read products" ON products;
DROP POLICY IF EXISTS "Managers+ can manage products" ON products;
DROP POLICY IF EXISTS "Authenticated can read clients" ON clients;
DROP POLICY IF EXISTS "Managers+ can manage clients" ON clients;
DROP POLICY IF EXISTS "Authenticated can read cash_registers" ON cash_registers;
DROP POLICY IF EXISTS "Managers+ can manage cash_registers" ON cash_registers;
DROP POLICY IF EXISTS "Authenticated can read transactions" ON transactions;
DROP POLICY IF EXISTS "Managers+ can manage transactions" ON transactions;
DROP POLICY IF EXISTS "Authenticated can read transaction_items" ON transaction_items;
DROP POLICY IF EXISTS "Managers+ can manage transaction_items" ON transaction_items;
DROP POLICY IF EXISTS "Authenticated can read points" ON points;
DROP POLICY IF EXISTS "Owners can manage points" ON points;
DROP POLICY IF EXISTS "Authenticated can read commissions" ON commissions;
DROP POLICY IF EXISTS "Owners can manage commissions" ON commissions;
DROP POLICY IF EXISTS "Authenticated can read expenses" ON expenses;
DROP POLICY IF EXISTS "Managers+ can manage expenses" ON expenses;
DROP POLICY IF EXISTS "Authenticated can read goals" ON goals;
DROP POLICY IF EXISTS "Managers+ can manage goals" ON goals;
DROP POLICY IF EXISTS "Authenticated can read schedules" ON schedules;
DROP POLICY IF EXISTS "Managers+ can manage schedules" ON schedules;
DROP POLICY IF EXISTS "Authenticated can read career_levels" ON career_levels;
DROP POLICY IF EXISTS "Owners can manage career_levels" ON career_levels;

CREATE POLICY profiles_self_or_superadmin_read
ON profiles
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
  OR is_super_admin(auth.uid())
);

CREATE POLICY profiles_self_or_superadmin_update
ON profiles
FOR UPDATE
TO authenticated
USING (
  id = auth.uid()
  OR is_super_admin(auth.uid())
)
WITH CHECK (
  id = auth.uid()
  OR is_super_admin(auth.uid())
);

CREATE POLICY memberships_select
ON user_store_memberships
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY memberships_insert
ON user_store_memberships
FOR INSERT
TO authenticated
WITH CHECK (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY memberships_update
ON user_store_memberships
FOR UPDATE
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
)
WITH CHECK (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY memberships_delete
ON user_store_memberships
FOR DELETE
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY stores_select
ON stores
FOR SELECT
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(id)
);

CREATE POLICY stores_insert
ON stores
FOR INSERT
TO authenticated
WITH CHECK (is_super_admin(auth.uid()));

CREATE POLICY stores_update
ON stores
FOR UPDATE
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(id, ARRAY['owner'])
)
WITH CHECK (
  is_super_admin(auth.uid())
  OR has_store_membership(id, ARRAY['owner'])
);

CREATE POLICY settings_select
ON settings
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY settings_write
ON settings
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager'])
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY barbers_select
ON barbers
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY barbers_write
ON barbers
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']));

CREATE POLICY services_select
ON services
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY services_write
ON services
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY products_select
ON products
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY products_write
ON products
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY clients_select
ON clients
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY clients_write
ON clients
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY cash_registers_select
ON cash_registers
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY cash_registers_write
ON cash_registers
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY transactions_select
ON transactions
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY transactions_write
ON transactions
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY transaction_items_select
ON transaction_items
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.id = transaction_items.transaction_id
      AND has_store_membership(t.store_id)
  )
);

CREATE POLICY transaction_items_write
ON transaction_items
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.id = transaction_items.transaction_id
      AND has_store_membership(t.store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
      AND is_store_billing_active(t.store_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.id = transaction_items.transaction_id
      AND has_store_membership(t.store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
      AND is_store_billing_active(t.store_id)
  )
);

CREATE POLICY points_select
ON points
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY points_write
ON points
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY commissions_select
ON commissions
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY commissions_write
ON commissions
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY expenses_select
ON expenses
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY expenses_write
ON expenses
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY goals_select
ON goals
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY goals_write
ON goals
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY schedules_select
ON schedules
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY schedules_write
ON schedules
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']));

CREATE POLICY career_levels_select
ON career_levels
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY career_levels_write
ON career_levels
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY subscription_plans_select
ON subscription_plans
FOR SELECT
TO authenticated
USING (TRUE);

CREATE POLICY subscription_plans_write
ON subscription_plans
FOR ALL
TO authenticated
USING (is_super_admin(auth.uid()))
WITH CHECK (is_super_admin(auth.uid()));

CREATE POLICY store_subscriptions_select
ON store_subscriptions
FOR SELECT
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY store_subscriptions_write
ON store_subscriptions
FOR ALL
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
)
WITH CHECK (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY subscription_invoices_select
ON subscription_invoices
FOR SELECT
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager']));

CREATE POLICY subscription_invoices_write
ON subscription_invoices
FOR ALL
TO authenticated
USING (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
)
WITH CHECK (
  is_super_admin(auth.uid())
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
);

CREATE POLICY billing_events_select
ON billing_events
FOR SELECT
TO authenticated
USING (
  store_id IS NULL
  OR has_store_membership(store_id, ARRAY['owner', 'manager'])
  OR is_super_admin(auth.uid())
);

CREATE POLICY billing_events_write
ON billing_events
FOR ALL
TO authenticated
USING (is_super_admin(auth.uid()))
WITH CHECK (is_super_admin(auth.uid()));

CREATE POLICY appointments_select
ON appointments
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY appointments_write
ON appointments
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY appointment_services_select
ON appointment_services
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.id = appointment_services.appointment_id
      AND has_store_membership(a.store_id)
  )
);

CREATE POLICY appointment_services_write
ON appointment_services
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.id = appointment_services.appointment_id
      AND has_store_membership(a.store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
      AND is_store_billing_active(a.store_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM appointments a
    WHERE a.id = appointment_services.appointment_id
      AND has_store_membership(a.store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
      AND is_store_billing_active(a.store_id)
  )
);

CREATE POLICY cash_register_events_select
ON cash_register_events
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY cash_register_events_write
ON cash_register_events
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY client_visit_history_select
ON client_visit_history
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY client_visit_history_write
ON client_visit_history
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY client_segments_select
ON client_segments
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY client_segments_write
ON client_segments
FOR ALL
TO authenticated
USING (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']))
WITH CHECK (has_store_membership(store_id, ARRAY['owner', 'manager', 'leader']));

CREATE POLICY campaigns_select
ON campaigns
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY campaigns_write
ON campaigns
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY campaign_results_select
ON campaign_results
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY campaign_results_write
ON campaign_results
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY cashback_rules_select
ON cashback_rules
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY cashback_rules_write
ON cashback_rules
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager'])
  AND is_store_billing_active(store_id)
);

CREATE POLICY cashback_ledger_select
ON cashback_ledger
FOR SELECT
TO authenticated
USING (has_store_membership(store_id));

CREATE POLICY cashback_ledger_write
ON cashback_ledger
FOR ALL
TO authenticated
USING (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
)
WITH CHECK (
  has_store_membership(store_id, ARRAY['owner', 'manager', 'leader', 'barber'])
  AND is_store_billing_active(store_id)
);

INSERT INTO subscription_plans (code, name, billing_interval, amount_cents, trial_days, is_active)
VALUES
  ('starter_monthly', 'Starter Mensal', 'monthly', 9900, 7, TRUE),
  ('professional_monthly', 'Professional Mensal', 'monthly', 19900, 7, TRUE),
  ('enterprise_monthly', 'Enterprise Mensal', 'monthly', 39900, 7, TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO store_subscriptions (
  store_id,
  plan_id,
  provider,
  status,
  current_period_start,
  current_period_end
)
SELECT
  s.id,
  p.id,
  'asaas',
  'trialing',
  NOW(),
  NOW() + INTERVAL '7 days'
FROM stores s
CROSS JOIN LATERAL (
  SELECT id
  FROM subscription_plans
  WHERE code = 'starter_monthly'
  LIMIT 1
) p
WHERE NOT EXISTS (
  SELECT 1
  FROM store_subscriptions ss
  WHERE ss.store_id = s.id
);

CREATE INDEX IF NOT EXISTS idx_memberships_user ON user_store_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_store ON user_store_memberships(store_id);
CREATE INDEX IF NOT EXISTS idx_store_subscriptions_store ON store_subscriptions(store_id);
CREATE INDEX IF NOT EXISTS idx_store_subscriptions_provider_subscription ON store_subscriptions(provider_subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscription_invoices_store ON subscription_invoices(store_id);
CREATE INDEX IF NOT EXISTS idx_billing_events_store ON billing_events(store_id);
CREATE INDEX IF NOT EXISTS idx_billing_events_provider_event ON billing_events(provider, event_id);
CREATE INDEX IF NOT EXISTS idx_appointments_store_starts_at ON appointments(store_id, starts_at);
CREATE INDEX IF NOT EXISTS idx_appointments_barber_starts_at ON appointments(barber_id, starts_at);
CREATE INDEX IF NOT EXISTS idx_appointment_services_appointment ON appointment_services(appointment_id);
CREATE INDEX IF NOT EXISTS idx_cash_register_events_store_created_at ON cash_register_events(store_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_client_visit_history_store_client ON client_visit_history(store_id, client_id);
CREATE INDEX IF NOT EXISTS idx_campaigns_store_status ON campaigns(store_id, status);
CREATE INDEX IF NOT EXISTS idx_campaign_results_campaign ON campaign_results(campaign_id);
CREATE INDEX IF NOT EXISTS idx_cashback_ledger_store_client ON cashback_ledger(store_id, client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cashback_rules_store_active ON cashback_rules(store_id, is_active);
