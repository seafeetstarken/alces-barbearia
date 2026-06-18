# Status do Projeto: Alce's Barbearia (Handoff)

Este documento contém o resumo do estado atual do projeto `alces-barbearia` para que você possa continuar de onde parou em uma próxima sessão (vibecoding ou manualmente).

## 1. O que foi concluído até o momento

### Backend (Supabase & Web-Admin)
- **Tabelas e Schema:** O banco de dados Supabase está configurado com as tabelas de `stores`, `barbers`, `services`, `products`, `clients`, `career_levels`, e `whitelabel_settings`.
- **Seed de Dados Reais:** O script `seed-data.ts` foi refatorado para suportar múltiplas lojas. Ele agora insere/atualiza os dados **reais** das unidades **Matriz (Itoupava Seca)** e **Escola Agrícola**.
- **Profissionais Reais:** O banco de dados foi alimentado com os barbeiros reais, suas especialidades e URLs de avatares corretos, vinculados às suas respectivas unidades.
- **Usuário Admin:** Foi criado e garantido o usuário administrador padrão (`admin@alces.com`) usando o script `create-admin.ts`.

### Aplicativo Mobile (Flutter)
- **Mock Data Atualizado:** O arquivo `mobile/lib/data/mock_data.dart` foi atualizado para refletir os profissionais reais, correspondendo exatamente com o que está no banco de dados.
- O aplicativo já possui modelos e interface para listagem de barbeiros, agendamento e informações de perfil.

## 2. O que falta fazer / Próximos Passos (Next Steps)

### A. Setup para iOS (TestFlight)
- **Gerar a pasta iOS:** A pasta `mobile/ios` ainda não existe (foi constatado na verificação). Será necessário rodar `flutter create .` (ou `flutter create --platforms=ios .`) dentro da pasta `mobile` para gerar o projeto iOS nativo.
- **Conta Apple Developer:** Você precisará fornecer os acessos à sua conta Apple Developer para criar o App ID (Bundle ID) e os certificados.
- **CI/CD via GitHub Actions:** 
  1. Criar o diretório `.github/workflows`.
  2. Adicionar o script YAML para fazer build do `.ipa` usando o `macos-latest`.
  3. Configurar as *Secrets* no GitHub (App Store Connect API Key, certificados, etc).
  4. Disparar a action para publicar no TestFlight automaticamente.

### B. Funcionalidades do App
- **Conectar o Flutter ao Supabase:** O app Flutter ainda está usando `mock_data.dart`. O próximo grande passo para o app é integrar o SDK do Supabase no Flutter para buscar os dados das lojas e barbeiros dinamicamente em vez de usar os arquivos estáticos.
- **Agendamento Real:** Gravar os agendamentos feitos no app mobile diretamente na tabela `appointments` do Supabase.

## 3. Como retomar o trabalho
Na sua próxima sessão, você pode simplesmente pedir para o assistente:
> *"Leia o arquivo `handoff_status.md` na raiz do projeto e vamos continuar com a configuração do GitHub Actions para o TestFlight."*
OU
> *"Leia o arquivo `handoff_status.md` e vamos começar a integrar o Supabase no app Flutter para substituir o mock_data."*
