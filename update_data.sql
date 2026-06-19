-- ==============================================
-- UPDATE SCRIPT: UNIDADES, CORS E PLANOS
-- Execute este script no SQL Editor do Supabase
-- ==============================================

-- 1. Unidades: Deletar a Matriz
DELETE FROM public.stores WHERE name = 'Alce''s Barbearia - Matriz';

-- (Nota: A Unidade Escola Agrícola e Itoupava Seca continuam intactas)

-- 2. CORS (Imagens): Limpar as URLs quebradas do i.pravatar.cc
UPDATE public.barbers SET image_url = '';

-- 3. Planos: Atualizar os planos existentes ou recriá-los
-- Limpamos os antigos primeiro
DELETE FROM public.plans;

-- Inserimos os novos planos do Print 4
INSERT INTO public.plans (name, price, billing_cycle, features, is_active) VALUES
(
    'Corte Ilimitado', 
    119.90, 
    'mensal', 
    '["Corte ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, 
    TRUE
),
(
    'Barba Ilimitado', 
    119.90, 
    'mensal', 
    '["Barba ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, 
    TRUE
),
(
    'Cabelo e Barba Ilimitado', 
    169.90, 
    'mensal', 
    '["Corte ilimitado", "Barba ilimitado", "Descontos em empresas parceiras", "Desconto em serviços adicionais", "Até 30% de descontos em produtos"]'::jsonb, 
    TRUE
);
