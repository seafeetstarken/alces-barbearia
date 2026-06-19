/**
 * Script para seed de dados básicos da Alce's
 * Execute com: npx tsx scripts/seed-data.ts
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// Ler .env
function loadEnv() {
    try {
        const envPath = resolve(process.cwd(), '.env');
        const envContent = readFileSync(envPath, 'utf-8');
        const lines = envContent.split('\n');

        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed && !trimmed.startsWith('#')) {
                const [key, ...valueParts] = trimmed.split('=');
                const value = valueParts.join('=');
                process.env[key] = value;
            }
        }
    } catch {
        console.error('❌ Não foi possível ler .env');
    }
}

loadEnv();

const supabaseUrl = process.env.VITE_SUPABASE_URL!;
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function seedData() {
    console.log('🌱 Iniciando seed de dados...\n');

    // Login como admin primeiro
    console.log('🔑 Fazendo login como admin...');
    let { error: loginError } = await supabase.auth.signInWithPassword({
        email: 'admin@alces.com.br',
        password: 'Alces@2026',
    });

    if (loginError) {
        console.log('  ⚠️ admin@alces.com.br com Alces@2026 falhou, tentando admin@alces.com.br com alces123...');
        const secondTry = await supabase.auth.signInWithPassword({
            email: 'admin@alces.com.br',
            password: 'alces123',
        });
        loginError = secondTry.error;
    }

    if (loginError) {
        console.error('❌ Erro no login:', loginError.message);
        console.log('💡 Execute primeiro: npx tsx scripts/create-admin.ts');
        process.exit(1);
    }
    console.log('  ✅ Logado como admin\n');

    // 1. Verificar ou criar as lojas
    const { data: existingStores, error: fetchStoresError } = await supabase
        .from('stores')
        .select('id, name');

    if (fetchStoresError) {
        console.error('❌ Erro ao buscar lojas:', fetchStoresError.message);
        process.exit(1);
    }

    let storeId: string = ''; // Matriz
    let escolaAgricolaStoreId: string = ''; // Escola Agrícola

    const matrizStore = existingStores?.find(s => s.name.toLowerCase().includes('matriz'));
    const eaStore = existingStores?.find(s => s.name.toLowerCase().includes('escola'));

    if (!matrizStore) {
        console.log('📍 Criando loja Matriz...');
        const { data: newStore, error } = await supabase
            .from('stores')
            .insert({
                name: "Alce's Barbearia - Matriz",
                phone: '5547996155719',
                address: 'R. Erich Steinbach, 22 – sl 02 – Itoupava Seca, Blumenau – SC',
                open_time: '08:30',
                close_time: '20:00',
            })
            .select()
            .single();

        if (error) {
            console.error('❌ Erro ao criar loja Matriz:', error.message);
            process.exit(1);
        }
        storeId = newStore.id;
        console.log('  ✅ Matriz criada:', storeId);
    } else {
        storeId = matrizStore.id;
        console.log('📍 Loja Matriz encontrada:', storeId);
    }

    if (!eaStore) {
        console.log('📍 Criando loja Escola Agrícola...');
        const { data: newStore, error } = await supabase
            .from('stores')
            .insert({
                name: "Alce's Barbearia - Escola Agrícola",
                phone: '5547996155719',
                address: 'R. Benjamin Constant, 939 – Escola Agrícola, Blumenau – SC',
                open_time: '08:30',
                close_time: '20:00',
            })
            .select()
            .single();

        if (error) {
            console.error('❌ Erro ao criar loja Escola Agrícola:', error.message);
            process.exit(1);
        }
        escolaAgricolaStoreId = newStore.id;
        console.log('  ✅ Escola Agrícola criada:', escolaAgricolaStoreId);
    } else {
        escolaAgricolaStoreId = eaStore.id;
        console.log('📍 Loja Escola Agrícola encontrada:', escolaAgricolaStoreId);
    }

    // Gaspar removal: kept to 2 units (Matriz, Escola Agrícola)

    // Inserir serviços se não existirem
    console.log('\n💇 Criando Serviços...');
    // Matriz
    const { data: existingServices } = await supabase.from('services').select('id').eq('store_id', storeId).limit(1);
    if (!existingServices || existingServices.length === 0) {
        await supabase.from('services').insert([
            { store_id: storeId, name: 'Corte', price: 45.00, duration_minutes: 30, points: 1 },
            { store_id: storeId, name: 'Corte + Barba', price: 65.00, duration_minutes: 45, points: 2 },
            { store_id: storeId, name: 'Barba', price: 35.00, duration_minutes: 20, points: 1 },
            { store_id: storeId, name: 'Pigmentação', price: 80.00, duration_minutes: 40, points: 2 },
        ]);
        console.log('  ✅ Serviços criados para a Matriz');
    } else {
        console.log('  ✅ Serviços já existem na Matriz');
    }

    // Escola Agrícola
    const { data: existingServicesEa } = await supabase.from('services').select('id').eq('store_id', escolaAgricolaStoreId).limit(1);
    if (!existingServicesEa || existingServicesEa.length === 0) {
        await supabase.from('services').insert([
            { store_id: escolaAgricolaStoreId, name: 'Corte', price: 45.00, duration_minutes: 30, points: 1 },
            { store_id: escolaAgricolaStoreId, name: 'Corte + Barba', price: 65.00, duration_minutes: 45, points: 2 },
            { store_id: escolaAgricolaStoreId, name: 'Barba', price: 35.00, duration_minutes: 20, points: 1 },
            { store_id: escolaAgricolaStoreId, name: 'Pigmentação', price: 80.00, duration_minutes: 40, points: 2 },
        ]);
        console.log('  ✅ Serviços criados para a Escola Agrícola');
    } else {
        console.log('  ✅ Serviços já existem na Escola Agrícola');
    }

    // Inserir níveis de carreira se não existirem
    console.log('\n📈 Criando Níveis de Carreira...');
    // Matriz
    const { data: existingLevels } = await supabase.from('career_levels').select('id').eq('store_id', storeId).limit(1);
    if (!existingLevels || existingLevels.length === 0) {
        await supabase.from('career_levels').insert([
            { store_id: storeId, name: 'Júnior', level_order: 1, multiplier: 0.8, min_months: 0, min_services: 0, benefits: 'Treinamento básico' },
            { store_id: storeId, name: 'Profissional', level_order: 2, multiplier: 1.0, min_months: 6, min_services: 500, benefits: 'Comissão padrão' },
            { store_id: storeId, name: 'Sênior', level_order: 3, multiplier: 1.2, min_months: 18, min_services: 2000, benefits: 'Bônus de 20% + benefícios' },
            { store_id: storeId, name: 'Master', level_order: 4, multiplier: 1.5, min_months: 36, min_services: 5000, benefits: 'Bônus de 50% + liderança' },
        ]);
        console.log('  ✅ Níveis de carreira criados para a Matriz');
    } else {
        console.log('  ✅ Níveis já existem na Matriz');
    }

    // Escola Agrícola
    const { data: existingLevelsEa } = await supabase.from('career_levels').select('id').eq('store_id', escolaAgricolaStoreId).limit(1);
    if (!existingLevelsEa || existingLevelsEa.length === 0) {
        await supabase.from('career_levels').insert([
            { store_id: escolaAgricolaStoreId, name: 'Júnior', level_order: 1, multiplier: 0.8, min_months: 0, min_services: 0, benefits: 'Treinamento básico' },
            { store_id: escolaAgricolaStoreId, name: 'Profissional', level_order: 2, multiplier: 1.0, min_months: 6, min_services: 500, benefits: 'Comissão padrão' },
            { store_id: escolaAgricolaStoreId, name: 'Sênior', level_order: 3, multiplier: 1.2, min_months: 18, min_services: 2000, benefits: 'Bônus de 20% + benefícios' },
            { store_id: escolaAgricolaStoreId, name: 'Master', level_order: 4, multiplier: 1.5, min_months: 36, min_services: 5000, benefits: 'Bônus de 50% + liderança' },
        ]);
        console.log('  ✅ Níveis de carreira criados para a Escola Agrícola');
    } else {
        console.log('  ✅ Níveis já existem na Escola Agrícola');
    }

    // 2. Inserir Barbers
    console.log('\n👤 Criando Barbers...');
    const barbers = [
        // Matriz (Itoupava Seca)
        { store_id: storeId, name: 'Gabriel Becker', initials: 'GB', level: 'master', level_multiplier: 1.5, is_leader: true, phone: '47991234561' },
        { store_id: storeId, name: 'Jerffeson', initials: 'JF', level: 'senior', level_multiplier: 1.2, is_leader: false, phone: '47991234562' },
        { store_id: storeId, name: 'Thiago Ferreira', initials: 'TF', level: 'professional', level_multiplier: 1.0, is_leader: false, phone: '47991234563' },
        { store_id: storeId, name: 'Lucas Pelizer', initials: 'LP', level: 'junior', level_multiplier: 0.8, is_leader: false, phone: '47991234564' },
        // Escola Agrícola
        { store_id: escolaAgricolaStoreId, name: 'Jorge Henrique Funke', initials: 'JH', level: 'master', level_multiplier: 1.5, is_leader: true, phone: '47992345671' },
        { store_id: escolaAgricolaStoreId, name: 'Peterson', initials: 'PT', level: 'senior', level_multiplier: 1.2, is_leader: false, phone: '47992345672' },
        { store_id: escolaAgricolaStoreId, name: 'Ryan', initials: 'RY', level: 'professional', level_multiplier: 1.0, is_leader: false, phone: '47992345673' },
    ];

    for (const barber of barbers) {
        const { data: existing } = await supabase
            .from('barbers')
            .select('id')
            .eq('store_id', barber.store_id)
            .eq('name', barber.name)
            .limit(1);

        if (existing && existing.length > 0) {
            console.log(`  ✅ ${barber.name} (já existe)`);
        } else {
            const { error } = await supabase.from('barbers').insert(barber);
            if (error) {
                console.log(`  ⚠️ ${barber.name}: ${error.message}`);
            } else {
                console.log(`  ✅ ${barber.name} (${barber.level})`);
            }
        }
    }

    // 3. Inserir Clientes
    console.log('\n👥 Criando Clientes...');
    const clients = [
        { store_id: storeId, name: 'João Mendes', phone: '47999887766', status: 'active' },
        { store_id: storeId, name: 'Marcos Ferreira', phone: '47999776655', status: 'active' },
        { store_id: storeId, name: 'André Lima', phone: '47999665544', status: 'active' },
        { store_id: storeId, name: 'Bruno Souza', phone: '47999554433', status: 'active' },
        { store_id: storeId, name: 'Felipe Alves', phone: '47999443322', status: 'inactive' },
    ];

    for (const client of clients) {
        const { data: existing } = await supabase
            .from('clients')
            .select('id')
            .eq('store_id', client.store_id)
            .eq('name', client.name)
            .limit(1);

        if (existing && existing.length > 0) {
            console.log(`  ✅ ${client.name} (já existe)`);
        } else {
            const { error } = await supabase.from('clients').insert(client);
            if (error) {
                console.log(`  ⚠️ ${client.name}: ${error.message}`);
            } else {
                console.log(`  ✅ ${client.name}`);
            }
        }
    }

    // 4. Inserir Produtos
    console.log('\n📦 Criando Produtos...');
        { store_id: storeId, name: 'Água Sem Gás 500ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Água Com Gás 500ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'BALM PÓS BARBA 120G', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Corona Extra', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Energético Heign 473ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Bom Bom', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Biz Xtra Oreo', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Blend Capilar', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Cerveja Eisenbahn 355ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Bolacha Oreo', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Coca-Cola Zero 350ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Cerveja Sol 330ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Creme Ativador De Cachos', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Energético Monster 473ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Gel Garden', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Hair Spray', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Halls', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Messy Hair', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'OLÉO ARGAN FOR MEN GARDEN', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'POMADA MATTE FOR MEN GARDEN', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'POMADA TEIA FOR MEN GARDEN', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pomada Alces Teia 70g', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pomada Alces Mate', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pomada Alces Brilho', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pomada Alces Caramelo', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pomada em Pó Alces', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Óleo Alces LV', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Balm Alces CA', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Pós Barba Alces', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Shampoo Limpeza Profunda Alces', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },
        { store_id: storeId, name: 'Energético Red Bull 355ml', price: 0.0, cost: 0.0, stock_quantity: 10, min_stock: 2 },


    for (const product of products) {
        const { data: existing } = await supabase
            .from('products')
            .select('id')
            .eq('store_id', product.store_id)
            .eq('name', product.name)
            .limit(1);

        if (existing && existing.length > 0) {
            console.log(`  ✅ ${product.name} (já existe)`);
        } else {
            const { error } = await supabase.from('products').insert(product);
            if (error) {
                console.log(`  ⚠️ ${product.name}: ${error.message}`);
            } else {
                console.log(`  ✅ ${product.name} - R$${product.price.toFixed(2)} (${product.stock_quantity} un)`);
            }
        }
    }

    // 5. Criar Settings para as lojas
    console.log('\n⚙️ Configurando Settings (White Label)...');
    const settingsMatriz = {
        store_id: storeId,
        logo_url: '/assets/Logo_Alces_Barbershop.png',
        primary_color: '#D4A03C',
        secondary_color: '#6B7280',
        background_color: '#1A1614',
        card_color: '#26211E',
        font_family: 'Source Sans Pro',
        theme: 'dark',
        commission_percentage: 43,
    };
    const settingsEa = {
        store_id: escolaAgricolaStoreId,
        logo_url: '/assets/Logo_Alces_Barbershop.png',
        primary_color: '#D4A03C',
        secondary_color: '#6B7280',
        background_color: '#1A1614',
        card_color: '#26211E',
        font_family: 'Source Sans Pro',
        theme: 'dark',
        commission_percentage: 43,
    };

    const { error: settingsMatrizError } = await supabase
        .from('settings')
        .upsert(settingsMatriz, { onConflict: 'store_id' });

    if (settingsMatrizError) {
        console.log(`  ⚠️ Matriz Settings: ${settingsMatrizError.message}`);
    } else {
        console.log('  ✅ Configurações Matriz salvas');
    }

    const { error: settingsEaError } = await supabase
        .from('settings')
        .upsert(settingsEa, { onConflict: 'store_id' });

    if (settingsEaError) {
        console.log(`  ⚠️ Escola Agrícola Settings: ${settingsEaError.message}`);
    } else {
        console.log('  ✅ Configurações Escola Agrícola salvas');
    }

    console.log('\n✅ Seed concluído com sucesso!\n');
    console.log('📊 Resumo:');
    console.log(`   - ${barbers.length} Barbers`);
    console.log(`   - ${clients.length} Clientes`);
    console.log(`   - ${products.length} Produtos`);
    console.log('   - 8 Serviços');
    console.log('   - 8 Níveis de carreira');
    console.log('   - Configurações White Label');
}

seedData();
