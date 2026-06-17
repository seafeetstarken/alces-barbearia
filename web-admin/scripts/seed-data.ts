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
    const { error: loginError } = await supabase.auth.signInWithPassword({
        email: 'admin@alces.com',
        password: 'Alces@2026',
    });

    if (loginError) {
        console.error('❌ Erro no login:', loginError.message);
        console.log('💡 Execute primeiro: npx tsx scripts/create-admin.ts');
        process.exit(1);
    }
    console.log('  ✅ Logado como admin\n');

    // 1. Verificar ou criar a loja matriz
    const { data: stores } = await supabase
        .from('stores')
        .select('id')
        .ilike('name', '%Matriz%')
        .limit(1);

    let storeId: string;

    if (!stores || stores.length === 0) {
        console.log('📍 Criando lojas da Alce\'s...');

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
            console.error('❌ Erro ao criar loja:', error.message);
            process.exit(1);
        }

        storeId = newStore.id;
        console.log('  ✅ Matriz criada');

        // Criar outras filiais
        await supabase.from('stores').insert([
            { name: "Alce's Barbearia - Escola Agrícola", phone: '5547996155719', address: 'R. Benjamin Constant, 939 – Escola Agrícola, Blumenau – SC' },
            { name: "Alce's Barbearia - Gaspar", phone: '5547996155719', address: 'Av. Das Comunidades, 995 – Centro, Gaspar – SC' },
        ]);
        console.log('  ✅ Filiais criadas');
    } else {
        storeId = stores[0].id;
        console.log('📍 Loja encontrada:', storeId);
    }

    // Inserir serviços se não existirem
    console.log('\n💇 Criando Serviços...');
    const { data: existingServices } = await supabase.from('services').select('id').eq('store_id', storeId).limit(1);

    if (!existingServices || existingServices.length === 0) {
        await supabase.from('services').insert([
            { store_id: storeId, name: 'Corte', price: 45.00, duration_minutes: 30, points: 1 },
            { store_id: storeId, name: 'Corte + Barba', price: 65.00, duration_minutes: 45, points: 2 },
            { store_id: storeId, name: 'Barba', price: 35.00, duration_minutes: 20, points: 1 },
            { store_id: storeId, name: 'Pigmentação', price: 80.00, duration_minutes: 40, points: 2 },
        ]);
        console.log('  ✅ Serviços criados');
    } else {
        console.log('  ✅ Serviços já existem');
    }

    // Inserir níveis de carreira se não existirem
    console.log('\n📈 Criando Níveis de Carreira...');
    const { data: existingLevels } = await supabase.from('career_levels').select('id').eq('store_id', storeId).limit(1);

    if (!existingLevels || existingLevels.length === 0) {
        await supabase.from('career_levels').insert([
            { store_id: storeId, name: 'Júnior', level_order: 1, multiplier: 0.8, min_months: 0, min_services: 0, benefits: 'Treinamento básico' },
            { store_id: storeId, name: 'Profissional', level_order: 2, multiplier: 1.0, min_months: 6, min_services: 500, benefits: 'Comissão padrão' },
            { store_id: storeId, name: 'Sênior', level_order: 3, multiplier: 1.2, min_months: 18, min_services: 2000, benefits: 'Bônus de 20% + benefícios' },
            { store_id: storeId, name: 'Master', level_order: 4, multiplier: 1.5, min_months: 36, min_services: 5000, benefits: 'Bônus de 50% + liderança' },
        ]);
        console.log('  ✅ Níveis de carreira criados');
    } else {
        console.log('  ✅ Níveis já existem');
    }

    // 2. Inserir Barbers
    console.log('\n👤 Criando Barbers...');
    const barbers = [
        { store_id: storeId, name: 'Carlos Silva', initials: 'CS', level: 'senior', level_multiplier: 1.2, is_leader: true, phone: '47991234567' },
        { store_id: storeId, name: 'Pedro Santos', initials: 'PS', level: 'professional', level_multiplier: 1.0, is_leader: false, phone: '47992345678' },
        { store_id: storeId, name: 'Lucas Oliveira', initials: 'LO', level: 'junior', level_multiplier: 0.8, is_leader: false, phone: '47993456789' },
        { store_id: storeId, name: 'Rafael Costa', initials: 'RC', level: 'master', level_multiplier: 1.5, is_leader: true, phone: '47994567890' },
    ];

    for (const barber of barbers) {
        const { error } = await supabase.from('barbers').insert(barber);
        if (error && !error.message.includes('duplicate')) {
            console.log(`  ⚠️ ${barber.name}: ${error.message}`);
        } else {
            console.log(`  ✅ ${barber.name} (${barber.level})`);
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
        const { error } = await supabase.from('clients').insert(client);
        if (error && !error.message.includes('duplicate')) {
            console.log(`  ⚠️ ${client.name}: ${error.message}`);
        } else {
            console.log(`  ✅ ${client.name}`);
        }
    }

    // 4. Inserir Produtos
    console.log('\n📦 Criando Produtos...');
    const products = [
        { store_id: storeId, name: 'Pomada Modeladora', price: 45.00, cost: 20.00, stock_quantity: 15, min_stock: 5 },
        { store_id: storeId, name: 'Óleo para Barba', price: 55.00, cost: 25.00, stock_quantity: 10, min_stock: 3 },
        { store_id: storeId, name: 'Shampoo Masculino', price: 35.00, cost: 15.00, stock_quantity: 20, min_stock: 5 },
        { store_id: storeId, name: 'Cera Matte', price: 50.00, cost: 22.00, stock_quantity: 8, min_stock: 3 },
        { store_id: storeId, name: 'Balm para Barba', price: 40.00, cost: 18.00, stock_quantity: 12, min_stock: 4 },
    ];

    for (const product of products) {
        const { error } = await supabase.from('products').insert(product);
        if (error && !error.message.includes('duplicate')) {
            console.log(`  ⚠️ ${product.name}: ${error.message}`);
        } else {
            console.log(`  ✅ ${product.name} - R$${product.price.toFixed(2)} (${product.stock_quantity} un)`);
        }
    }

    // 5. Criar Settings para a loja
    console.log('\n⚙️ Configurando Settings (White Label)...');
    const settings = {
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

    const { error: settingsError } = await supabase
        .from('settings')
        .upsert(settings, { onConflict: 'store_id' });

    if (settingsError) {
        console.log(`  ⚠️ ${settingsError.message}`);
    } else {
        console.log('  ✅ Configurações salvas');
    }

    console.log('\n✅ Seed concluído com sucesso!\n');
    console.log('📊 Resumo:');
    console.log(`   - ${barbers.length} Barbers`);
    console.log(`   - ${clients.length} Clientes`);
    console.log(`   - ${products.length} Produtos`);
    console.log('   - 4 Serviços');
    console.log('   - 4 Níveis de carreira');
    console.log('   - Configurações White Label');
}

seedData();
