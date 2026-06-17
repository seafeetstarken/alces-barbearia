# Salão Justo

Sistema completo de gestão para barbearias e salões de beleza. Uma plataforma SaaS moderna que oferece tanto um painel administrativo para gestores quanto um aplicativo para clientes realizarem agendamentos e compras.

## 🎯 Visão Geral

O Salão Justo é uma solução all-in-one que permite:
- **Gestores**: Controlar operações, comissões, estoque, metas e relatórios
- **Clientes**: Agendar serviços, comprar produtos, gerenciar assinaturas e wallet

## ✨ Funcionalidades

### Painel Administrativo

| Módulo | Descrição |
|--------|-----------|
| **Dashboard** | Visão geral com métricas, faturamento diário e performance dos profissionais |
| **Caixa** | Controle de transações, abrir/fechar caixa, formas de pagamento |
| **Comissões** | Sistema de pontos e cálculo automático de comissões |
| **Barbeiros** | Cadastro e gestão da equipe de profissionais |
| **Agenda** | Gerenciamento de horários e agendamentos |
| **Clientes** | Base de clientes e histórico de atendimentos |
| **Serviços** | Catálogo de serviços com preços e duração |
| **Produtos** | Cadastro de produtos para venda |
| **Estoque** | Controle de inventário |
| **Despesas** | Registro e categorização de gastos |
| **Metas** | Definição e acompanhamento de objetivos |
| **Relatórios** | Análises e insights do negócio |
| **Configurações** | Personalização do sistema |

### Aplicativo do Cliente

| Funcionalidade | Descrição |
|----------------|-----------|
| **Home** | Página inicial com destaques e ofertas |
| **Agendamento** | Sistema de booking com escolha de profissional e horário |
| **Serviços** | Visualização de todos os serviços disponíveis |
| **Loja** | E-commerce de produtos do salão |
| **Carrinho** | Gestão de itens para compra |
| **Checkout** | Finalização de compras |
| **Wallet** | Carteira digital com saldo e cashback |
| **Assinaturas** | Planos de fidelidade e mensalidades |
| **Perfil** | Dados do cliente e histórico |
| **Meus Agendamentos** | Visualização e gestão de horários marcados |

## 🛠️ Stack Tecnológica

- **Frontend Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Estilização**: Tailwind CSS
- **Componentes UI**: shadcn/ui (Radix UI primitives)
- **Roteamento**: React Router DOM v6
- **Gerenciamento de Estado**: TanStack Query (React Query)
- **Formulários**: React Hook Form + Zod
- **Gráficos**: Recharts
- **Ícones**: Lucide React

## 🚀 Como Executar

### Pré-requisitos

- Node.js 18+ instalado
- npm, yarn, pnpm ou bun

### Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd sal-o-justo

# Instale as dependências
npm install
# ou
bun install

# Inicie o servidor de desenvolvimento
npm run dev
```

O aplicativo estará disponível em `http://localhost:5173`

### Scripts Disponíveis

| Comando | Descrição |
|---------|-----------|
| `npm run dev` | Inicia servidor de desenvolvimento |
| `npm run build` | Gera build de produção |
| `npm run build:dev` | Build em modo desenvolvimento |
| `npm run preview` | Preview do build de produção |
| `npm run lint` | Executa ESLint |
| `npm run test` | Executa testes |
| `npm run test:watch` | Testes em modo watch |

## 📁 Estrutura do Projeto

```
src/
├── components/
│   ├── ui/           # Componentes shadcn/ui
│   ├── dashboard/    # Componentes do dashboard
│   ├── layout/       # Layouts (DashboardLayout)
│   └── settings/     # Componentes de configurações
├── pages/
│   ├── client/       # Páginas do app cliente
│   └── *.tsx         # Páginas administrativas
├── hooks/            # Custom hooks
├── lib/              # Utilitários
└── test/             # Testes
```

## 🔜 Roadmap

- [ ] Integração com backend (Supabase/Firebase)
- [ ] Autenticação de usuários
- [ ] Multi-tenancy para múltiplos salões
- [ ] Notificações push
- [ ] Integração com gateways de pagamento
- [ ] App mobile (React Native)

## 📄 Licença

Este projeto é proprietário e de uso restrito.

---

Desenvolvido por **Ferramentas Tecnologia**
