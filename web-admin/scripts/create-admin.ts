/**
 * Script para criar usuário admin inicial
 * Execute com: npx tsx scripts/create-admin.ts
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { resolve } from 'path';

// Ler .env manualmente
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
    } catch (e) {
        // Tentar .env.local também
        try {
            const envPath = resolve(process.cwd(), '.env.local');
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
            console.error('❌ Não foi possível ler .env ou .env.local');
        }
    }
}

loadEnv();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    console.error('❌ Variáveis de ambiente não encontradas.');
    console.log('Certifique-se de que VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY estão no .env');
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function createAdmin() {
    console.log('🔐 Criando usuário admin...\n');

    const { data, error } = await supabase.auth.signUp({
        email: 'admin@alces.com',
        password: 'Alces@2026',
        options: {
            data: {
                full_name: 'Administrador Alce\'s',
                role: 'owner',
            },
        },
    });

    if (error) {
        console.error('❌ Erro ao criar usuário:', error.message);

        if (error.message.includes('already registered')) {
            console.log('\n💡 Este email já está cadastrado. Tente fazer login.');
        }

        process.exit(1);
    }

    console.log('✅ Usuário criado com sucesso!\n');
    console.log('📧 Email:', 'admin@alces.com');
    console.log('🔑 Senha:', 'Alces@2026');
    console.log('👤 Nome:', 'Administrador Alce\'s');
    console.log('🎭 Papel:', 'owner');
    console.log('\n🚀 Agora você pode fazer login no sistema!');
}

createAdmin();
