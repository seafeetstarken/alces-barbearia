-- ==============================================
-- ALCES BARBEARIA - SEED DATA (REAL DATA)
-- ==============================================

DO $$
DECLARE
    escola_agricola_id UUID;
    itoupava_seca_id UUID;
BEGIN
    -- ==========================================
    -- 1. UNIDADES (STORES)
    -- ==========================================
    
    -- Inserir ou obter Unidade Escola Agrícola
    SELECT id INTO escola_agricola_id FROM public.stores WHERE name = 'Unidade Escola Agrícola' LIMIT 1;
    IF escola_agricola_id IS NULL THEN
        INSERT INTO public.stores (name, address, phone) 
        VALUES (
            'Unidade Escola Agrícola', 
            'Rua Benjamin Constant, 939 (Anexo ao Rede Top) Bairro Escola Agrícola, Blumenau - SC', 
            '(47) 99615-5719'
        )
        RETURNING id INTO escola_agricola_id;
    END IF;

    -- Inserir ou obter Unidade Itoupava Seca
    SELECT id INTO itoupava_seca_id FROM public.stores WHERE name = 'Unidade Itoupava Seca' LIMIT 1;
    IF itoupava_seca_id IS NULL THEN
        INSERT INTO public.stores (name, address, phone) 
        VALUES (
            'Unidade Itoupava Seca', 
            'Rua Erich Steinbach, 22, Sala 2 (Em frente à praça) Bairro Itoupava Seca, Blumenau - SC', 
            '(47) 99615-5719'
        )
        RETURNING id INTO itoupava_seca_id;
    END IF;

    -- ==========================================
    -- 2. BARBEIROS (PROFISSIONAIS)
    -- ==========================================
    
    -- Barbeiros - Escola Agrícola
    INSERT INTO public.barbers (store_id, name, avatar_url, is_active) VALUES 
    (escola_agricola_id, 'Jorge Henrique Funke', 'https://i.pravatar.cc/150?img=11', true),
    (escola_agricola_id, 'Peterson', 'https://i.pravatar.cc/150?img=12', true),
    (escola_agricola_id, 'Ryan', 'https://i.pravatar.cc/150?img=13', true)
    ON CONFLICT DO NOTHING;

    -- Barbeiros - Itoupava Seca
    INSERT INTO public.barbers (store_id, name, avatar_url, is_active) VALUES 
    (itoupava_seca_id, 'Gabriel', 'https://i.pravatar.cc/150?img=14', true),
    (itoupava_seca_id, 'Jerffeson', 'https://i.pravatar.cc/150?img=15', true),
    (itoupava_seca_id, 'Thiago Ferreira', 'https://i.pravatar.cc/150?img=16', true),
    (itoupava_seca_id, 'Lucas Pelizer', 'https://i.pravatar.cc/150?img=17', true)
    ON CONFLICT DO NOTHING;

    -- ==========================================
    -- 3. SERVIÇOS
    -- ==========================================
    
    INSERT INTO public.services (name, description, price, duration_minutes) VALUES 
    ('Corte cabelo', 'Corte de cabelo', 50.00, 30),
    ('Barba', 'Serviço de barba', 45.00, 30),
    ('Limpeza de Ouvido Cone Hindu', 'Limpeza relaxante', 40.00, 30),
    ('Platinado / Luzes', 'Descoloração e tonalização', 200.00, 30),
    ('Corte Kids', 'Corte infantil', 50.00, 30),
    ('Sobrancelha Navalha', 'Alinhamento de sobrancelha', 10.00, 15),
    ('Limpeza Nariz Na Cera', 'Depilação nasal', 25.00, 15),
    ('Limpeza Ouvido Na Cera', 'Depilação da orelha', 25.00, 15),
    ('Selagem', 'Desfrute de um cabelo liso e saudável sem danos!', 60.00, 30),
    ('Pigmentação Cabelo', 'Tonalizar os fios brancos com um toque mais jovem', 60.00, 15),
    ('Pigmentação Barba', 'Tonalize os fios da barba sem uma tintura forçada', 40.00, 15),
    ('Hidratação Capilar', 'Hidrate e renove os fios do seu cabelo', 35.00, 15),
    ('Hidratação De Pele', 'Cuidado para a pele do rosto', 40.00, 15)
    ON CONFLICT DO NOTHING;

    -- ==========================================
    -- 4. PRODUTOS (CATÁLOGO)
    -- ==========================================
    
    INSERT INTO public.products (name, description, price, image_url, category, stock_quantity) VALUES 
    ('Água Sem Gás', '500ml', 4.00, 'assets/images/product.png', 'Bebidas', 50),
    ('Água Com Gás', '500ml', 4.50, 'assets/images/product.png', 'Bebidas', 50),
    ('BALM PÓS BARBA 120G', 'Hidrata e acalma a pele', 45.00, 'assets/images/product.png', 'Cuidados', 20),
    ('Corona Extra', 'Cerveja Long Neck', 12.00, 'assets/images/product.png', 'Bebidas', 30),
    ('Energético Heign', '473ml', 15.00, 'assets/images/product.png', 'Bebidas', 20),
    ('Bom Bom', 'Chocolate', 3.00, 'assets/images/product.png', 'Doces', 50),
    ('Biz Xtra Oreo', 'Chocolate', 5.00, 'assets/images/product.png', 'Doces', 50),
    ('Biz Xtra', 'Chocolate', 5.00, 'assets/images/product.png', 'Doces', 50),
    ('Blend Capilar', 'Shampoo + spray', 89.90, 'assets/images/product.png', 'Cuidados', 10),
    ('Cerveja Eisenbahn', '355ml', 10.00, 'assets/images/product.png', 'Bebidas', 30),
    ('Bolacha Oreo', 'Pacote', 6.00, 'assets/images/product.png', 'Doces', 20),
    ('Coca-Cola Zero', 'Lata 350ml', 6.00, 'assets/images/product.png', 'Bebidas', 40),
    ('Coca-Cola', 'Lata 350ml', 6.00, 'assets/images/product.png', 'Bebidas', 40)
    ON CONFLICT DO NOTHING;

END $$;
