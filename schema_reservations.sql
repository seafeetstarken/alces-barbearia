-- ==============================================
-- ALCES BARBEARIA - PRODUCT RESERVATIONS
-- ==============================================

CREATE TABLE public.product_reservations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    store_id UUID REFERENCES public.stores(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'Aguardando Retirada' CHECK (status IN ('Aguardando Retirada', 'Retirado', 'Cancelado')),
    total_amount DECIMAL(10,2) NOT NULL,
    items JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Row Level Security (RLS)
ALTER TABLE public.product_reservations ENABLE ROW LEVEL SECURITY;

-- Policies for Reservations
CREATE POLICY "Users can view own reservations" ON public.product_reservations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reservations" ON public.product_reservations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reservations" ON public.product_reservations FOR UPDATE USING (auth.uid() = user_id);
