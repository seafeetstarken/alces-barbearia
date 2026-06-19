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

-- Insert Real Plans
INSERT INTO public.plans (name, description, price, features) VALUES 
('Plano Essencial', 'O básico bem feito', 99.90, '["2 Cortes de Cabelo por mês", "Desconto de 5% em produtos", "Agendamento prioritário"]'::jsonb),
('Plano Premium', 'Cabelo e Barba impecáveis', 149.90, '["2 Cortes de Cabelo por mês", "2 Barbas por mês", "Desconto de 10% em produtos", "Agendamento VIP"]'::jsonb),
('Plano VIP Alce', 'A experiência completa e ilimitada', 299.90, '["Cortes Ilimitados", "Barbas Ilimitadas", "Desconto de 20% em produtos", "Bebida por conta da casa", "Agendamento VIP"]'::jsonb)
ON CONFLICT DO NOTHING;
