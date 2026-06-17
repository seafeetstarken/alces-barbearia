/**
 * Script para criar usuário Super Admin (White Label)
 * Execute com: npx tsx scripts/create-super-admin.ts <email> <senha> <nome>
 * 
 * Exemplo:
 *   npx tsx scripts/create-super-admin.ts admin@alces.com Alces@2026 "Super Admin Alce's"
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

async function createSuperAdmin() {
    const args = process.argv.slice(2);

    if (args.length < 3) {
        console.log('📖 Uso: npx tsx scripts/create-super-admin.ts <email> <senha> <nome>\n');
        console.log('Exemplo:');
        console.log('  npx tsx scripts/create-super-admin.ts admin@alces.com Alces@2026 "Super Admin Alce\'s"');
        process.exit(0);
    }

    const [email, password, fullName] = args;
    const role = 'super_admin';

    console.log('🔐 Criando usuário Super Admin...\n');

    const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
            data: {
                full_name: fullName,
                role: role,
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

    console.log('✅ Super Admin criado com sucesso!\n');
    console.log('📧 Email:', email);
    console.log('🔑 Senha:', password);
    console.log('👤 Nome:', fullName);
    console.log('🎭 Papel:', 'Super Admin (super_admin)');
    console.log('\n⚠️ IMPORTANTE: Certifique-se de aplicar a migração 002_add_super_admin_role.sql no Supabase SQL Editor antes de tentar logar!');
    console.log('\n🚀 Agora você pode fazer login e acessar /admin!');
}

createSuperAdmin();
