-- ==============================================
-- ALCES BARBEARIA - MOCK DATA INSERTION
-- ==============================================

-- 1. Get the Matriz Store ID
DO $$
DECLARE
    matriz_id UUID;
BEGIN
    -- Obter a loja Matriz (criada no script anterior) ou criar se não existir
    SELECT id INTO matriz_id FROM public.stores WHERE name = 'Alce''s Barbearia - Matriz' LIMIT 1;
    
    IF matriz_id IS NULL THEN
        INSERT INTO public.stores (name, address, phone) 
        VALUES ('Alce''s Barbearia - Matriz', 'Rua Principal, 1000', '11999999999')
        RETURNING id INTO matriz_id;
    END IF;

    -- 2. Insert Barbers
    INSERT INTO public.barbers (store_id, name, avatar_url) VALUES 
    (matriz_id, 'Thiago Silva', 'https://i.pravatar.cc/150?img=11'),
    (matriz_id, 'Marcos Oliveira', 'https://i.pravatar.cc/150?img=12'),
    (matriz_id, 'Bruno Costa', 'https://i.pravatar.cc/150?img=14')
    ON CONFLICT DO NOTHING;

    -- 3. Insert Services
    INSERT INTO public.services (name, description, price, duration_minutes) VALUES 
    ('Corte Clássico', 'Corte em tesoura e máquina com finalização.', 45.00, 30),
    ('Barba Terapia', 'Aparo, toalha quente e balm.', 35.00, 30),
    ('Corte + Barba', 'O combo completo para o visual alinhado.', 70.00, 60),
    ('Sobrancelha', 'Limpeza na navalha.', 15.00, 15)
    ON CONFLICT DO NOTHING;

    -- 4. Insert Products
    INSERT INTO public.products (name, description, price, image_url, category, stock_quantity) VALUES 
    ('Pomada Matte', 'Fixação forte e efeito seco.', 49.90, 'assets/images/product.png', 'Modeladores', 10),
    ('Óleo para Barba', 'Hidratação e brilho intenso.', 39.90, 'assets/images/product.png', 'Cuidados', 15),
    ('Shampoo Ice', 'Refrescância para o couro cabeludo.', 34.90, 'assets/images/product.png', 'Limpeza', 20)
    ON CONFLICT DO NOTHING;

END $$;
