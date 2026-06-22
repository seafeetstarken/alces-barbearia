/**
 * Script para configurar secrets nas Edge Functions do Supabase
 * 
 * Como usar:
 * 1. Gere seu token pessoal em: https://supabase.com/dashboard/account/tokens
 * 2. Rode: node scripts/setup-supabase-secrets.js SEU_TOKEN_AQUI
 */

const https = require('https');

const PROJECT_REF = 'baafdmeulyzpcgbqqeut';

const secrets = [
  {
    name: 'ASAAS_API_KEY',
    value: 'SUA_CHAVE_AQUI
  },
  {
    name: 'ASAAS_ENVIRONMENT',
    value: 'sandbox'
  }
];

const token = process.argv[2] || process.env.SUPABASE_ACCESS_TOKEN;

if (!token) {
  console.error('❌ Token não fornecido!');
  console.error('');
  console.error('Uso: node scripts/setup-supabase-secrets.js SEU_TOKEN_PESSOAL');
  console.error('');
  console.error('Gere seu token em: https://supabase.com/dashboard/account/tokens');
  process.exit(1);
}

console.log('🔧 Configurando secrets nas Edge Functions do Supabase...');
console.log(`📋 Projeto: ${PROJECT_REF}`);
console.log(`🔑 Secrets a configurar: ${secrets.map(s => s.name).join(', ')}`);
console.log('');

const data = JSON.stringify(secrets);

const options = {
  hostname: 'api.supabase.com',
  path: `/v1/projects/${PROJECT_REF}/secrets`,
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
};

const req = https.request(options, (res) => {
  let body = '';
  res.on('data', d => body += d);
  res.on('end', () => {
    if (res.statusCode === 200 || res.statusCode === 201) {
      console.log('✅ Secrets configurados com sucesso!');
      console.log('');
      console.log('Próximos passos:');
      console.log('  1. Acesse https://supabase.com/dashboard/project/' + PROJECT_REF + '/functions');
      console.log('  2. Confirme que as funções checkout-single, checkout-subscription e create-customer estão ativas');
      console.log('  3. Teste o pagamento PIX no aplicativo!');
    } else {
      console.error(`❌ Erro ao configurar secrets. Status: ${res.statusCode}`);
      console.error('Resposta:', body);

      if (res.statusCode === 401) {
        console.error('');
        console.error('Token inválido ou expirado. Gere um novo em:');
        console.error('https://supabase.com/dashboard/account/tokens');
      }
    }
  });
});

req.on('error', (e) => {
  console.error('❌ Erro de conexão:', e.message);
});

req.write(data);
req.end();
