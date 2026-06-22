-- ==============================================
-- ALCES BARBEARIA - PLANS SCHEMA & DATA
-- ==============================================

-- 1. Plans Table
CREATE TABLE IF NOT EXISTS public.plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle TEXT DEFAULT 'mensal',
    features JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. User Subscriptions Table
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.plans(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Cancelado', 'Pendente')),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE
);

-- RLS Policies
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Plans are viewable by everyone" ON public.plans FOR SELECT USING (true);
CREATE POLICY "Users can view own subscriptions" ON public.user_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own subscriptions" ON public.user_subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Admin Policies for Subscriptions
CREATE POLICY "Admins can view all subscriptions" ON public.user_subscriptions FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);
CREATE POLICY "Admins can insert any subscription" ON public.user_subscriptions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);
CREATE POLICY "Admins can update any subscription" ON public.user_subscriptions FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
);

-- Insert Real Plans
INSERT INTO public.plans (name, price, billing_cycle, features, is_active) VALUES 
('Corte Ilimitado', 119.90, 'mensal', '["Corte ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, TRUE),
('Barba Ilimitado', 119.90, 'mensal', '["Barba ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, TRUE),
('Cabelo e Barba Ilimitado', 169.90, 'mensal', '["Corte ilimitado", "Barba ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, TRUE)
ON CONFLICT DO NOTHING;
