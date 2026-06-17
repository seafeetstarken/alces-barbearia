# Product Requirements Document (PRD)
# Salão Justo - Sistema de Gestão para Barbearias e Salões

**Versão:** 1.0  
**Data:** Janeiro 2026  
**Status:** Em Desenvolvimento

---

## 1. Resumo Executivo

O **Salão Justo** é uma plataforma SaaS completa para gestão de barbearias e salões de beleza. O produto oferece duas interfaces principais: um painel administrativo para gestores e profissionais, e um aplicativo voltado para clientes finais.

### 1.1 Proposta de Valor

- **Para Gestores**: Controle total das operações do negócio em uma única plataforma
- **Para Profissionais**: Sistema justo de comissões baseado em pontos
- **Para Clientes**: Conveniência no agendamento, compras e fidelização

### 1.2 Objetivo do Produto

Eliminar a complexidade operacional de barbearias e salões através de um sistema unificado que automatiza processos, fornece insights de negócio e melhora a experiência do cliente.

---

## 2. Escopo do Produto

### 2.1 Público-Alvo

| Persona | Descrição | Necessidades |
|---------|-----------|--------------|
| **Dono/Gestor** | Proprietário ou gerente do estabelecimento | Controle financeiro, gestão de equipe, relatórios |
| **Barbeiro/Estilista** | Profissional que atende clientes | Ver comissões, agenda pessoal, metas |
| **Cliente** | Consumidor final dos serviços | Agendar, comprar, fidelização |

### 2.2 Plataformas Suportadas

- **Web App** (Desktop e Mobile responsivo)
- **PWA** (Progressive Web App - futura implementação)
- **iOS/Android** (futura implementação via React Native)

---

## 3. Requisitos Funcionais

### 3.1 Módulo Administrativo

#### 3.1.1 Dashboard
- **RF-001**: Exibir métricas em tempo real (faturamento do dia, atendimentos, profissionais ativos)
- **RF-002**: Mostrar tendências comparativas (vs. dia anterior)
- **RF-003**: Listar últimos serviços realizados
- **RF-004**: Exibir ranking de performance dos profissionais
- **RF-005**: Status do caixa (aberto/fechado, saldo)

#### 3.1.2 Caixa (PDV)
- **RF-006**: Abrir e fechar caixa com valor inicial
- **RF-007**: Registrar vendas de serviços
- **RF-008**: Registrar vendas de produtos
- **RF-009**: Suportar múltiplas formas de pagamento (PIX, Cartão, Dinheiro)
- **RF-010**: Registrar sangrias e reforços de caixa
- **RF-011**: Relatório de fechamento de caixa

#### 3.1.3 Comissões
- **RF-012**: Sistema de pontos por serviço
- **RF-013**: Cálculo automático de comissões
- **RF-014**: Histórico de comissões por período
- **RF-015**: Exportação de relatório de comissões

#### 3.1.4 Gestão de Equipe (Barbeiros)
- **RF-016**: Cadastro de profissionais
- **RF-017**: Definir especialidades e serviços habilitados
- **RF-018**: Configurar horários de trabalho
- **RF-019**: Ativar/desativar profissionais

#### 3.1.5 Agenda
- **RF-020**: Visualização em calendário (dia/semana/mês)
- **RF-021**: Criar agendamentos manuais
- **RF-022**: Bloquear horários
- **RF-023**: Notificações de agendamentos

#### 3.1.6 Clientes
- **RF-024**: Cadastro de clientes
- **RF-025**: Histórico de atendimentos por cliente
- **RF-026**: Preferências do cliente (profissional favorito, serviços)
- **RF-027**: Segmentação e tags

#### 3.1.7 Catálogo (Serviços e Produtos)
- **RF-028**: Cadastro de serviços com preço, duração e pontos
- **RF-029**: Categorização de serviços
- **RF-030**: Cadastro de produtos para venda
- **RF-031**: Gestão de estoque/inventário
- **RF-032**: Alertas de estoque baixo

#### 3.1.8 Financeiro
- **RF-033**: Registro de despesas
- **RF-034**: Categorização de despesas
- **RF-035**: Fluxo de caixa (entradas x saídas)
- **RF-036**: Relatório de lucratividade

#### 3.1.9 Metas
- **RF-037**: Definir metas de faturamento (diária/semanal/mensal)
- **RF-038**: Metas individuais por profissional
- **RF-039**: Acompanhamento visual de progresso
- **RF-040**: Gamificação com conquistas

#### 3.1.10 Relatórios
- **RF-041**: Relatório de vendas por período
- **RF-042**: Performance por profissional
- **RF-043**: Produtos mais vendidos
- **RF-044**: Horários de pico
- **RF-045**: Taxa de retorno de clientes
- **RF-046**: Exportação em PDF/Excel

### 3.2 Aplicativo do Cliente

#### 3.2.1 Agendamento
- **RF-047**: Escolher serviço(s)
- **RF-048**: Escolher profissional ou "qualquer disponível"
- **RF-049**: Selecionar data e horário
- **RF-050**: Confirmar/cancelar agendamentos
- **RF-051**: Notificações e lembretes

#### 3.2.2 Loja Virtual
- **RF-052**: Catálogo de produtos
- **RF-053**: Carrinho de compras
- **RF-054**: Checkout com múltiplas formas de pagamento
- **RF-055**: Histórico de pedidos

#### 3.2.3 Wallet (Carteira Digital)
- **RF-056**: Saldo disponível
- **RF-057**: Adicionar créditos
- **RF-058**: Utilizar saldo para pagamentos
- **RF-059**: Programa de cashback
- **RF-060**: Extrato de movimentações

#### 3.2.4 Assinaturas
- **RF-061**: Visualizar planos disponíveis
- **RF-062**: Assinar plano mensal/anual
- **RF-063**: Gerenciar assinatura (upgrade, cancelamento)
- **RF-064**: Benefícios exclusivos (descontos, prioridade)

#### 3.2.5 Perfil
- **RF-065**: Editar dados pessoais
- **RF-066**: Histórico de atendimentos
- **RF-067**: Profissional favorito
- **RF-068**: Preferências de notificação

---

## 4. Requisitos Não-Funcionais

### 4.1 Performance
- **RNF-001**: Tempo de carregamento inicial < 3 segundos
- **RNF-002**: Resposta de API < 500ms
- **RNF-003**: Suportar 1000 usuários simultâneos

### 4.2 Segurança
- **RNF-004**: Autenticação via JWT
- **RNF-005**: Dados sensíveis criptografados
- **RNF-006**: HTTPS obrigatório
- **RNF-007**: Conformidade com LGPD

### 4.3 Disponibilidade
- **RNF-008**: SLA 99.5% uptime
- **RNF-009**: Backup diário

### 4.4 Usabilidade
- **RNF-010**: Design responsivo (mobile-first)
- **RNF-011**: Acessibilidade WCAG 2.1 AA
- **RNF-012**: Suporte a modo escuro

### 4.5 Escalabilidade
- **RNF-013**: Arquitetura multi-tenant
- **RNF-014**: Suportar múltiplos estabelecimentos por conta

---

## 5. Arquitetura Técnica

### 5.1 Frontend
- **Framework**: React 18 + TypeScript
- **Build**: Vite
- **UI**: Tailwind CSS + shadcn/ui
- **Estado**: TanStack Query
- **Formulários**: React Hook Form + Zod
- **Roteamento**: React Router v6

### 5.2 Backend (Proposta)
- **Opção 1**: Supabase (Auth + PostgreSQL + Realtime + Storage)
- **Opção 2**: Firebase (Auth + Firestore)
- **API**: REST ou GraphQL

### 5.3 Infraestrutura (Proposta)
- **Hosting**: Vercel / Netlify (frontend)
- **Backend**: Supabase / Firebase
- **CDN**: CloudFlare

---

## 6. Modelo de Negócio

### 6.1 Planos de Assinatura (B2B)

| Plano | Preço/mês | Profissionais | Funcionalidades |
|-------|-----------|---------------|-----------------|
| **Starter** | R$ 99 | Até 3 | Agenda, Caixa, Clientes |
| **Professional** | R$ 199 | Até 8 | + Comissões, Metas, Relatórios |
| **Enterprise** | R$ 399 | Ilimitado | + Multi-unidade, API, Suporte prioritário |

### 6.2 Receitas Adicionais
- Taxa sobre transações de wallet (2%)
- Marketplace de produtos (comissão 10%)
- White-label para franquias

---

## 7. Roadmap

### Fase 1: MVP (Atual)
- [x] Interface administrativa completa
- [x] Interface do cliente
- [x] Sistema de pontos e comissões
- [ ] Integração com backend

### Fase 2: Lançamento
- [ ] Autenticação de usuários
- [ ] Persistência de dados
- [ ] Agendamento funcional
- [ ] Pagamentos integrados (PIX, Cartão)

### Fase 3: Crescimento
- [ ] App mobile nativo
- [ ] Programa de fidelidade avançado
- [ ] Integrações (Google Calendar, WhatsApp)
- [ ] Multi-unidade

### Fase 4: Escala
- [ ] Marketplace de produtos
- [ ] White-label
- [ ] API pública
- [ ] Internacionalização

---

## 8. Métricas de Sucesso (KPIs)

| Métrica | Meta Fase 1 | Meta Fase 2 |
|---------|-------------|-------------|
| Salões ativos | 50 | 500 |
| MAU (clientes) | 1.000 | 10.000 |
| Agendamentos/mês | 5.000 | 50.000 |
| NPS | > 40 | > 50 |
| Churn mensal | < 5% | < 3% |

---

## 9. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Baixa adoção | Média | Alto | Onboarding assistido, trial gratuito |
| Concorrência | Alta | Médio | Foco em UX e sistema de comissões justo |
| Problemas de pagamento | Média | Alto | Múltiplos gateways, fallback manual |
| Escalabilidade | Baixa | Alto | Arquitetura serverless desde o início |

---

## 10. Stakeholders

| Nome | Papel | Responsabilidade |
|------|-------|------------------|
| Product Owner | Priorização | Definir backlog e aceitar entregas |
| Tech Lead | Arquitetura | Decisões técnicas e qualidade |
| Designer | UX/UI | Experiência do usuário |
| Desenvolvedor | Implementação | Codificação e testes |

---

## Histórico de Revisões

| Versão | Data | Autor | Alterações |
|--------|------|-------|------------|
| 1.0 | Jan/2026 | Gemini | Documento inicial |

---

**Aprovado por:** _________________________________  
**Data de Aprovação:** _________________________________
