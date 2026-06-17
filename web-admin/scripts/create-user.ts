/**
 * Script para criar usuários com diferentes papéis
 * Execute com: npx tsx scripts/create-user.ts <email> <senha> <nome> <role>
 * 
 * Exemplos:
 *   npx tsx scripts/create-user.ts barber@alces.com 123456 "João Silva" barber
 *   npx tsx scripts/create-user.ts gestor@alces.com 123456 "Maria Costa" manager
 *   npx tsx scripts/create-user.ts lider@alces.com 123456 "Pedro Santos" leader
 *   npx tsx scripts/create-user.ts super@alces.com 123456 "Super Admin" super_admin
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { resolve } from 'path';

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

const validRoles = ['owner', 'manager', 'leader', 'barber', 'super_admin'];

const roleNames: Record<string, string> = {
    owner: 'Dono',
    manager: 'Gestor',
    leader: 'Líder',
    barber: 'Barber',
    super_admin: 'Super Admin',
};

async function createUser() {
    const args = process.argv.slice(2);

    if (args.length < 4) {
        console.log('📖 Uso: npx tsx scripts/create-user.ts <email> <senha> <nome> <role>\n');
        console.log('Roles disponíveis:');
        validRoles.forEach((role) => {
            console.log(`  - ${role} (${roleNames[role]})`);
        });
        console.log('\nExemplos:');
        console.log('  npx tsx scripts/create-user.ts barber@alces.com 123456 "João Silva" barber');
        console.log('  npx tsx scripts/create-user.ts gestor@alces.com 123456 "Maria Costa" manager');
        process.exit(0);
    }

    const [email, password, fullName, role] = args;

    if (!validRoles.includes(role)) {
        console.error(`❌ Role inválida: ${role}`);
        console.log(`Roles válidas: ${validRoles.join(', ')}`);
        process.exit(1);
    }

    if (password.length < 6) {
        console.error('❌ Senha deve ter pelo menos 6 caracteres');
        process.exit(1);
    }

    console.log('🔐 Criando usuário...\n');

    const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
            data: {
                full_name: fullName,
                role,
            },
        },
    });

    if (error) {
        console.error('❌ Erro ao criar usuário:', error.message);

        if (error.message.includes('already registered')) {
            console.log('\n💡 Este email já está cadastrado.');
        }

        process.exit(1);
    }

    console.log('✅ Usuário criado com sucesso!\n');
    console.log('📧 Email:', email);
    console.log('🔑 Senha:', password);
    console.log('👤 Nome:', fullName);
    console.log('🎭 Papel:', `${role} (${roleNames[role]})`);

    // Se for barber ou leader, perguntar sobre vincular a uma loja
    if (role === 'barber' || role === 'leader') {
        console.log('\n💡 Para vincular este profissional a uma loja, use o sistema ou rode:');
        console.log('   npx tsx scripts/link-barber.ts <barber_email> <store_id>');
    }

    if (role === 'super_admin') {
        console.log('\n🔧 Super Admin pode acessar /admin para gerenciar White Label');
    }

    console.log('\n🚀 Usuário pode fazer login no sistema!');
}

createUser();
