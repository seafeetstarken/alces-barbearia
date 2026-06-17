# Plano de Implementação Detalhado — SaaS de Barbearia Multi-Tenant

## 1) Objetivo do documento

Transformar o produto atual em um SaaS comercializável com foco em:

- Multi-tenant real e seguro
- Cobrança recorrente B2B com Asaas
- Operação core sem mocks
- CRM enxuto com alto impacto comercial
- Experiência de uso forte para dono, barbeiro e cliente final

Este plano é orientado para execução em paralelo por agentes, com entregas pequenas e integráveis.

---

## 2) Princípios de produto (sem feature bloat)

1. **Primeiro receita e retenção**: tudo que não impacta ativação, cobrança, operação e retenção fica para depois.
2. **Mínimo Lovável**: resolver ponta a ponta dos fluxos críticos antes de adicionar “camadas premium”.
3. **Dados confiáveis antes de IA**: sem base de dados consistente não existe IA útil.
4. **Escala por arquitetura, não por retrabalho**: tenancy, RLS e billing corretos desde já.
5. **Velocidade com segurança**: paralelismo máximo sem abrir mão de isolamento de dados.

---

## 3) Escopo de MVP (o que entra e o que não entra)

## 3.1 Entra no MVP

- Estrutura multi-tenant com vínculo usuário-loja e isolamento por tenant
- RBAC por loja (super_admin, owner, manager, leader, barber)
- Billing B2B com Asaas (assinatura, status, webhook e bloqueio por inadimplência)
- Operação core real:
  - cadastro e gestão de serviços/produtos/clientes
  - caixa (abertura/fechamento, lançamentos)
  - agendamento funcional
  - checkout funcional
- CRM básico de vendas:
  - segmentação simples
  - campanhas
  - reativação de clientes
- Cashback baseado em regras objetivas
- Polimento de UX nos principais fluxos

## 3.2 Não entra no MVP

- CRM com IA avançada (predição/automações complexas)
- Marketplace
- App mobile nativo
- White-label avançado por franquia com customizações profundas

---

## 4) Contexto atual (base aproveitável)

- Há schema com entidades operacionais e `store_id`
- Há autenticação e papéis básicos
- Há hooks de dados funcionando em boa parte do admin
- Há telas importantes ainda mockadas no fluxo cliente e em caixa
- Há necessidade de endurecer RLS para tenancy real

---

## 5) Arquitetura alvo (alto nível)

## 5.1 Tenancy e autorização

- Modelo lógico:
  - `organizations` (opcional agora, recomendado para evolução)
  - `stores`
  - `user_store_memberships` (N:N usuário x loja)
- Todas as tabelas de negócio com `store_id`
- Policies RLS sempre filtrando por membership + role

## 5.2 Billing

- Tabelas:
  - `subscriptions`
  - `subscription_invoices`
  - `billing_events`
- Fonte de verdade do ciclo de vida: webhook Asaas
- Estados mínimos:
  - `trialing`
  - `active`
  - `past_due`
  - `canceled`

## 5.3 Core operacional

- Fluxo de atendimento gera transação e impacto financeiro
- Fluxo de agendamento atualiza agenda e histórico de cliente
- Fluxo de checkout confirma pagamento e baixa pendências

## 5.4 CRM e cashback

- CRM:
  - tabela de campanhas
  - público-alvo por filtros
  - resultado por campanha
- Cashback:
  - regras parametrizáveis por loja
  - lançamentos em ledger
  - histórico auditável

---

## 6) Plano de execução por frentes paralelas (agentes)

## Frente A — Tenant & Segurança (prioridade máxima)

### Entregas

- Criar membership usuário↔loja
- Reescrever policies RLS para isolamento por tenant
- Remover fallback single-tenant implícito
- Ajustar seleção de loja para dados reais

### Critérios de pronto

- Usuário sem vínculo não acessa dados da loja
- Usuário com vínculo só vê dados da(s) loja(s) permitida(s)
- Super admin mantém visão administrativa global controlada

### Riscos

- Quebra de consultas antigas sem filtro de tenant
- Regressão de permissões por papel

### Mitigação

- Testes de política por role
- Rollout progressivo por módulo crítico com checklist de regressão

---

## Frente B — Billing B2B + Asaas

### Entregas

- Cadastro de plano e assinatura por loja
- Checkout de assinatura
- Webhook de confirmação/cobrança/falha/cancelamento
- Regra de bloqueio por inadimplência

### Critérios de pronto

- Nova barbearia consegue iniciar assinatura
- Mudança de status por webhook atualiza acesso em minutos
- Histórico de eventos de billing disponível para auditoria

### Riscos

- Falha em webhook e inconsistência de estado

### Mitigação

- Retry idempotente + fila de reprocessamento
- Logs estruturados de billing

---

## Frente C — Core sem Mock (Admin + Cliente)

### Entregas

- Conectar caixa UI ao hook real
- Conectar booking/checkout/subscription/wallet a dados reais
- Resolver inconsistências de domínio
- Fechar fluxo ponta a ponta:
  - agendamento
  - atendimento
  - pagamento
  - histórico

### Critérios de pronto

- Fluxo completo testado sem dados mock
- Totais financeiros batendo com transações
- Histórico de cliente e agenda consistentes

### Riscos

- Dados antigos incompatíveis

### Mitigação

- Scripts de migração e saneamento
- Backfill com validação

---

## Frente D — CRM de Vendas Enxuto

### Entregas

- Segmentação (ativos, inativos, recorrência, ticket)
- Campanha com objetivo e público
- Registro de resultado (entregue/aberto/convertido)
- Reativação de clientes inativos

### Critérios de pronto

- Time da barbearia cria campanha sem apoio técnico
- Conversão por campanha mensurável

### Riscos

- Vira “painel bonito sem ação”

### Mitigação

- Templates de campanha orientados a resultado
- Dashboard comercial focado em ações recomendadas

---

## Frente E — Cashback & Promoções

### Entregas

- Motor de regras de cashback:
  - chegou no horário
  - fechamento de plano 3/6/12 meses
  - promoções da loja
- Ledger de créditos/débitos
- Uso de saldo em checkout elegível

### Critérios de pronto

- Regra aplicada de forma determinística
- Cliente vê saldo e extrato claros
- Loja mede impacto em retenção e recorrência

### Riscos

- Fraude de pontualidade/uso indevido

### Mitigação

- Janela de tolerância + validação por evento de check-in
- Limites de crédito por período

---

## 7) Sequência de merge recomendada (PRs)

## PR-01 — Tenancy Foundation

- Memberships
- RLS por tenant
- Ajustes mínimos de consulta e contexto de loja

## PR-02 — Billing Foundation

- Estruturas de assinatura
- Integração Asaas inicial
- Webhook + update de status

## PR-03 — Operação Core Real

- Caixa conectado
- Agendamento real
- Checkout real
- Limpeza de mocks críticos

## PR-04 — CRM Enxuto

- Segmentação
- Campanhas
- Dashboard de resultados

## PR-05 — Cashback & Promoções

- Regras
- Ledger
- Resgate e visualização

## PR-06 — Polimento UX e Hardening

- Estados de erro/sucesso/loading
- QA de fluxos críticos
- Ajustes finais de performance

---

## 8) Definição de pronto por camada

## Produto

- Fluxos críticos completos sem intervenção manual
- Mensagens claras para dono, barbeiro e cliente

## Engenharia

- Lint e typecheck sem erro
- Migrações versionadas e reversíveis
- Sem endpoints críticos sem proteção por tenant

## Dados

- Integridade referencial preservada
- Backfill executado quando necessário
- Métricas auditáveis

## Operação

- Runbook de incidentes de billing
- Procedimento de suporte para inadimplência

---

## 9) Métricas (KPIs) obrigatórias

## Aquisição e ativação

- % de barbearias que completam onboarding
- Tempo até primeiro atendimento registrado

## Receita

- MRR
- Taxa de conversão trial → pago
- Inadimplência e recuperação

## Operação

- % de atendimentos registrados no sistema
- Tempo de fechamento de caixa
- No-show rate

## Retenção e expansão

- Churn B2B mensal
- Uso de CRM (campanhas/mês por loja)
- Taxa de retorno de clientes

---

## 10) Riscos maiores e plano de contingência

1. **RLS mal configurado**
   - Contingência: bateria de testes por role + revisão dupla antes de merge
2. **Webhook instável**
   - Contingência: retries idempotentes + fila de dead-letter + tela de reconciliação
3. **Dados legados inconsistentes**
   - Contingência: scripts de saneamento e validação pré-deploy
4. **Escopo crescendo no meio**
   - Contingência: gate de priorização com critério “impacto em receita/retenção”

---

## 11) Plano de execução turbo (agentes em paralelo)

Este bloco é para execução agressiva, com várias frentes rodando ao mesmo tempo.

## Janela 1 — Fundação

- Rodar Frente A + base da Frente B
- Saída esperada: tenancy seguro + billing inicial pronto para integrar

## Janela 2 — Fluxo que fatura

- Rodar Frente C e finalizar B
- Saída esperada: fluxo ponta a ponta cobrando e operando

## Janela 3 — Crescimento

- Rodar Frente D + E + polimento final
- Saída esperada: retenção e vendas recorrentes acelerando

---

## 12) Checklist final de go-live

- [ ] Tenancy testado por role
- [ ] Billing Asaas com webhook validado ponta a ponta
- [ ] Caixa e checkout sem mock
- [ ] CRM básico publicável
- [ ] Cashback com regras auditáveis
- [ ] KPIs coletando no dia 1
- [ ] Runbook de suporte disponível

---

## 13) Resultado esperado

Ao final, o produto deixa de ser “interface promissora” e vira **máquina operacional e comercial**:

- segura para escalar multi-tenant
- com monetização ativa
- com operação real sem planilha paralela
- com mecanismo de retenção (CRM + cashback)
- com base sólida para adicionar IA que realmente gere valor

---

## 14) Matriz de dependências entre frentes

- Frente A depende de: definição final de papéis e escopo de tenancy
- Frente B depende de: Frente A estável para associar assinatura por loja
- Frente C depende de: Frente A para segurança e Frente B para status de acesso
- Frente D depende de: Frente C para dados transacionais confiáveis
- Frente E depende de: Frente C e D para gatilhos e mensuração de impacto

## Regra de integração

- Nenhuma frente avança para produção sem contrato estável de dados compartilhados
- Alteração de schema em tabela compartilhada exige PR de compatibilidade retroativa

---

## 15) Segurança, LGPD e auditoria

## Segurança

- Forçar segregação de tenant em todas as queries de escrita e leitura
- Minimizar privilégios administrativos por papel
- Proibir exposição de dados sensíveis em logs

## LGPD

- Registrar base legal dos dados coletados
- Disponibilizar processo de anonimização/exclusão quando aplicável
- Definir política de retenção de dados por tipo de informação

## Auditoria

- Auditoria mínima para:
  - alterações de permissões
  - mudanças de configuração financeira
  - créditos/débitos de cashback
  - eventos de assinatura e cobrança

---

## 16) Observabilidade e SLOs operacionais

## SLOs mínimos

- Disponibilidade dos fluxos críticos: login, atendimento, checkout e cobrança
- Latência de operações críticas:
  - abertura de caixa
  - confirmação de pagamento
  - consulta de agenda

## Alertas obrigatórios

- pico de erro em autenticação
- falha consecutiva em webhook de cobrança
- aumento anormal de transações recusadas
- degradação de performance em endpoints críticos

## Dashboards operacionais

- Painel de saúde de billing
- Painel de saúde de tenancy/permissões
- Painel de funil operacional (agendamento → atendimento → pagamento)

---

## 17) Plano de rollback e continuidade

## Rollback técnico

- Toda migration crítica deve ter rollback mapeado antes do deploy
- Releases devem ser pequenos para facilitar reversão
- Estratégia de reversão funcional para desligar módulos novos sem parar a operação

## Rollback de negócio

- Se billing falhar, sistema entra em modo de contingência com registro local de cobranças pendentes
- Se cashback falhar, pausar crédito automático e manter ledger em fila de reconciliação

## Continuidade operacional

- Procedimento manual de emergência para fechamento de caixa
- Procedimento de reconciliação diária de eventos financeiros
- Playbook de comunicação para lojas impactadas

---

## 18) Plano de modernização e FODAlização de UI (mobile first)

Direção principal: experiência premium, rápida e muito clara para dono, barbeiro e cliente, com prioridade para uso em celular.

## 18.1 Diagnóstico visual atual do produto

- A base visual premium já existe no cliente (dark + gold + tipografia forte)
- O admin está funcional, mas com pouca hierarquia visual para ações críticas
- Falta consistência de estados: vazio, erro, carregamento e sucesso
- Falta padronização de padrões mobile de navegação entre admin e cliente
- Fluxos principais ainda misturam telas reais e mock, quebrando percepção de confiança

## 18.2 Princípios de UX para versão FODA

- Mobile first real: desenhar primeiro em 360–430px
- Zero dúvida de ação: sempre uma CTA principal por tela
- Densidade inteligente: informação importante sem poluição
- Feedback instantâneo: toda ação tem retorno visual imediato
- Fluxos curtos: meta de no máximo 3 passos para ações frequentes

## 18.3 Sistema de interface e componentes (UI Foundation)

- Definir tokens finais de spacing, tipografia, raio, sombra e contraste
- Consolidar variantes de botão para:
  - CTA principal
  - ação secundária
  - ação destrutiva
- Criar padrões reutilizáveis de:
  - TopBar mobile
  - Bottom action bar
  - Sheet de ação rápida
  - Card de métrica com estado
  - Lista com ações contextuais
- Padronizar estados:
  - loading skeleton
  - vazio orientado à ação
  - erro recuperável
  - sucesso com próximo passo

## 18.4 Arquitetura de navegação mobile-first

- Admin:
  - Home operacional com cards acionáveis
  - Navegação por prioridades do dia e não por menu longo
  - Ações rápidas fixas para caixa, agendamento e cobrança
- Cliente:
  - Home com agenda/promos/carteira como blocos principais
  - Checkout em fluxo linear com confirmação clara
  - Wallet e assinatura com leitura de valor percebido
- Barbeiro:
  - Tela de hoje, com agenda, meta e comissão prevista
  - Entrada rápida de atendimento e status do cliente

---

## 19) Features propostas com necessidade explícita de UI

## 19.1 Lista de espera inteligente + auto-preenchimento

- UI necessária:
  - tela de fila de espera por serviço/profissional
  - modal de encaixe com sugestão de clientes
  - notificação de oferta com tempo de aceite
  - status visual: aceito, recusado, expirado

## 19.2 No-show fee configurável

- UI necessária:
  - card de política de ausência em configurações
  - régua visual de prazos e penalidades
  - confirmação transparente no agendamento/checkout
  - histórico de cobranças de ausência

## 19.3 Packs 3/6/12 meses e pré-pagos

- UI necessária:
  - landing de planos com comparação clara
  - seletor de ciclo com economia destacada
  - carteira de créditos restantes
  - extrato de consumo por pacote

## 19.4 Split + conciliação de pagamento online

- UI necessária:
  - resumo de transação com breakdown de taxa
  - conciliação diária com estados
  - alerta de divergência com ação recomendada
  - exportação simplificada de fechamento

## 19.5 Programa de indicação

- UI necessária:
  - tela “indique e ganhe” com código/link
  - régua de progresso de recompensa
  - histórico de indicações e status de crédito

## 19.6 Promoções por comportamento

- UI necessária:
  - construtor de promoção por regra
  - preview de quem é elegível
  - ativação rápida e calendário promocional
  - visual de impacto (uso, retorno, receita)

## 19.7 Campanhas automáticas por gatilho

- UI necessária:
  - biblioteca de templates de campanha
  - editor de copy com variantes
  - agenda de disparo e painel de performance
  - funil entregue > aberto > convertido

## 19.8 NPS/CSAT transacional

- UI necessária:
  - micro-pesquisa pós-atendimento
  - painel de sentimento por período/profissional
  - fila de follow-up para detratores

## 19.9 Copiloto comercial e IA prática

- UI necessária:
  - widget “próxima melhor ação” no dashboard
  - explicação curta do motivo da recomendação
  - ação com 1 clique para executar campanha/promo

---

## 20) Roadmap de modernização visual por ondas

## Onda 1 — Base visual e consistência

- Consolidar tokens, componentes e estados de feedback
- Refatorar layout mobile do admin para tarefas de alto uso
- Ajustar home cliente para foco em conversão de agendamento

## Onda 2 — Fluxos de receita e retenção

- UX completa para assinatura/packs/cashback/wallet
- UX completa para no-show fee e conciliação
- UX de campanhas e promoções com foco em ação rápida

## Onda 3 — Diferenciação premium

- Copiloto comercial com UI explicável
- Painel executivo com storytelling de negócio
- Microinterações de confiança em fluxos financeiros

---

## 21) Critérios de qualidade para UI FODA

- Tempo de entendimento da tela principal em até 5 segundos
- Ação principal da tela sempre evidente sem scroll excessivo
- Taxa de conclusão dos fluxos críticos acima da linha de base atual
- Erro recuperável sem saída de contexto
- Contraste, foco e navegação por teclado em conformidade de acessibilidade

---

## 22) Resultado esperado da modernização

- Dono toma decisão diária mais rápido e com confiança
- Barbeiro registra e acompanha performance sem fricção
- Cliente percebe valor premium e retorna com mais frequência
- Produto ganha percepção de plataforma madura, não de protótipo

---

## 23) Pitacos práticos de UX baseado no estado atual do repo

- O app cliente já tem linguagem premium forte; usar isso como referência visual para o admin
- O admin precisa sair da lógica de “menu lateral grande” para “prioridade do dia + ação rápida”
- As páginas com maior impacto de negócio devem ter layout de decisão:
  - Caixa
  - Agenda
  - Clientes
  - Checkout
  - Assinaturas
- Padrão visual único entre módulos: hoje há boas telas isoladas, mas pouca coerência de jornada
- Objetivo macro: reduzir cliques e reduzir dúvida, não apenas “embelezar”

---

## 24) Backlog de UI mobile-first por persona e tela

## 24.1 Dono / Gestor (Admin)

- **Dashboard Operacional (novo foco)**
  - bloco “Hoje” com faturamento, ocupação, no-show, cobrança pendente
  - CTA fixa: abrir/fechar caixa, criar promoção, disparar campanha, ajustar agenda
- **Caixa**
  - layout em cards empilhados mobile
  - botão flutuante para nova movimentação
  - fechamento guiado passo a passo
- **Clientes (CRM)**
  - segmentação em chips horizontais (ativos, inativos, VIP, risco)
  - ficha do cliente em sheet com histórico e ação comercial imediata
- **Relatórios**
  - visão executiva simplificada com 3 perguntas:
    - como vendemos hoje?
    - onde estamos perdendo dinheiro?
    - qual ação gera ganho agora?

## 24.2 Barbeiro

- **Minha Rotina**
  - agenda do dia por timeline
  - próximo cliente com CTA de check-in e finalização
  - meta diária e comissão prevista em tempo real
- **Atendimento Rápido**
  - fluxo de 3 passos: serviço > pagamento > conclusão
  - confirmação visual imediata de pontos/comissão

## 24.3 Cliente Final

- **Home**
  - bloco principal de agendar agora
  - promoções personalizadas por comportamento
  - carteira e assinatura com benefício claro
- **Checkout**
  - resumo fixo no rodapé
  - 1 CTA primária por etapa
  - confirmação de sucesso com próximo passo recomendado
- **Assinaturas e Packs**
  - comparação simples entre mensal e 3/6/12
  - economia destacada e regras transparentes

---

## 25) Catálogo de componentes UI necessários para as features propostas

- AppShell mobile-first por persona (admin, barbeiro, cliente)
- TopBar contextual com título dinâmico + CTA contextual
- Bottom action bar fixa em fluxos transacionais
- Sheet universal para ações rápidas
- Card de KPI com estado (normal, alerta, crítico)
- Stepper para fluxos de checkout e fechamento de caixa
- Timeline para agenda e histórico
- Builder de campanha/promo com preview em tempo real
- Empty states orientados por ação comercial
- Feedback stack (loading, sucesso, erro) padronizado

---

## 26) Microinterações e percepção premium

- Estados hover/press/focus consistentes em todos os CTAs principais
- Feedback visual imediato após ações críticas (ex.: atendimento registrado, pagamento confirmado)
- Transições curtas e previsíveis em troca de contexto
- Indicadores de progresso em fluxos multi-etapa
- Destaque animado discreto para “próxima melhor ação”

---

## 27) Requisitos de UX performance para mobile

- Primeira interação útil da tela em até poucos segundos em 4G padrão
- Evitar layout shift em listas e dashboards
- Skeletons em todos os módulos de consulta recorrente
- Ações críticas sempre ao alcance do polegar
- Evitar modais profundos em cascata; preferir sheet única com contexto

---

## 28) Sequência de implementação da FODAlização (UI-first)

- **UI-01**
  - consolidar UI Foundation, estados e componentes globais
- **UI-02**
  - refatorar Dashboard + Caixa + Agenda em mobile-first
- **UI-03**
  - refatorar Clientes/CRM + Campanhas + Promoções
- **UI-04**
  - refatorar Cliente Home + Checkout + Assinatura/Packs + Wallet
- **UI-05**
  - implantar camada de copiloto comercial com visual explicável

Critério final: a experiência tem que parecer produto premium maduro em qualquer tela, com clareza de ação e conversão alta sem treinamento.

---

## 29) Plano enxuto para agentes (backend + frontend) sem complexidade

## Missão única

Subir rápido um produto com experiência premium e fluxo real, evitando arquitetura desnecessária.

## Bloco A — Backend primeiro destrava Front

- **A1 Tenancy mínimo viável**
  - Entrega: membership + RLS por loja
  - Saída para front: contexto de loja confiável em todas as consultas
- **A2 Billing mínimo viável**
  - Entrega: assinatura por loja + status + webhook Asaas
  - Saída para front: endpoint/status para bloquear ou liberar ações
- **A3 Core transacional**
  - Entrega: agendamento, transação, caixa e histórico consistentes
  - Saída para front: dados reais para telas críticas sem mock

## Bloco B — Frontend mobile-first em paralelo

- **B1 UI Foundation**
  - Entrega: layout base, estados e componentes reutilizáveis
  - Saída para produto: consistência visual entre admin, barbeiro e cliente
- **B2 Fluxos críticos**
  - Entrega: Dashboard operacional, Caixa, Agenda, Checkout, Assinatura
  - Saída para negócio: conversão e operação com fricção baixa
- **B3 CRM e retenção**
  - Entrega: segmentação, campanha, promo e cashback com UI clara
  - Saída para crescimento: ações comerciais executáveis sem suporte técnico

---

## 30) Contrato simples entre back e front (não travar time)

## Entidades obrigatórias para P0

- `store`
- `membership`
- `subscription`
- `appointment`
- `transaction`
- `cash_register`
- `client`
- `campaign`
- `cashback_ledger`

## Regras de contrato

- Todo endpoint retorna:
  - `data`
  - `error`
  - `meta` mínimo (pagina/timestamp quando aplicável)
- IDs sempre estáveis e string
- Datas em ISO
- Status com enum fechado por domínio
- Front não depende de campos opcionais para renderizar ação principal

## Estados de UI que o back precisa suportar

- vazio real (lista sem itens)
- carregando (query em andamento)
- erro recuperável (mensagem + retry)
- sucesso com confirmação acionável

---

## 31) Blueprint mobile-first por fluxo crítico (execução rápida)

## Fluxo 1 — Caixa

- Tela 1: resumo do caixa do dia
- Tela 2: nova movimentação (sheet)
- Tela 3: fechamento guiado
- CTA principal sempre fixa no rodapé

## Fluxo 2 — Agenda

- Tela 1: timeline do dia
- Tela 2: detalhe do atendimento
- Tela 3: concluir atendimento e registrar pagamento

## Fluxo 3 — Checkout Cliente

- Tela 1: resumo do pedido
- Tela 2: método de pagamento
- Tela 3: confirmação e próximo passo

## Fluxo 4 — Assinaturas e Packs

- Tela 1: comparação de planos/packs
- Tela 2: confirmação
- Tela 3: carteira de benefícios ativos

## Fluxo 5 — CRM e Campanhas

- Tela 1: segmentos prontos
- Tela 2: criar campanha/promo
- Tela 3: resultado com ação sugerida

---

## 32) Regras anti-complexidade para acelerar entrega

- Não criar camada nova se já existe hook/tabela cobrindo 80% do caso
- Não criar abstração genérica antes do segundo uso real
- Não abrir feature nova enquanto fluxo crítico atual tiver mock
- Uma tela = uma ação principal
- Evitar wizard longo; quebrar em passos curtos com confirmação
- Priorizar clareza e velocidade sobre personalização avançada

---

## 33) Handoff operacional entre agentes

## Backend entrega para Front

- contrato de payload validado
- exemplos reais de resposta
- enum de status fechado

## Front entrega para Backend

- lista de campos realmente usados na UI
- fallback de render para campos opcionais
- mapa de erros críticos por fluxo

## QA conjunto

- smoke test dos 5 fluxos críticos mobile
- validação visual de estados (vazio, erro, sucesso, loading)
- validação de regra de negócio visível na interface

---

## 34) Definição de “pronto de verdade” para esse plano

- Usuário consegue operar fluxo crítico completo no celular com uma mão
- Gestor entende o que fazer em cada tela sem treinamento
- Não existem telas críticas com dados mock
- A jornada principal de receita (agendar → pagar → reter) roda ponta a ponta

---

## 35) Separação de execução por perfil (Back e Front)

## Backend Engineer (escopo)

- Dono dos domínios: tenancy, billing, agenda, caixa, transações, CRM, cashback
- Entrega sempre em formato de contrato estável para consumo do front
- Prioridade: consistência de regra de negócio e dados reais sem mock

## Frontend Engineer (escopo)

- Dono da experiência mobile-first por fluxo e por persona
- Entrega UI com ação principal clara, feedback imediato e baixa fricção
- Prioridade: conversão dos fluxos críticos e percepção premium consistente

---

## 36) Prompt pronto — Backend Engineer

Use este prompt para acionar um agente focado em backend:

```text
Você é Backend Engineer deste projeto SaaS de barbearia.

Contexto:
- Stack atual: Supabase + React Query no front.
- O plano oficial está em .rules/implementation-plan.md.
- Objetivo: destravar front com dados reais e regras consistentes, sem overengineering.

Sua missão:
1) Implementar o bloco backend mínimo viável para mobile-first:
   - tenancy por loja (membership + RLS),
   - billing com Asaas (assinatura/status/webhook),
   - core transacional (agenda, caixa, transações, histórico),
   - base CRM/cashback para consumo de UI.
2) Entregar contratos simples e estáveis para o front:
   - data/error/meta,
   - IDs string estáveis,
   - datas ISO,
   - enums fechados.
3) Eliminar dependências de mock nos fluxos críticos.

Restrições:
- Não criar abstração nova sem necessidade real.
- Reaproveitar estrutura existente do repo.
- Priorizar clareza de domínio e velocidade de entrega.

Formato de saída esperado:
- Lista de arquivos alterados (migrations, hooks, queries, tipos),
- Endpoints/consultas disponíveis por fluxo,
- Checklist de validação funcional para front integrar sem bloqueio.
```

---

## 37) Prompt pronto — Frontend Engineer

Use este prompt para acionar um agente focado em frontend:

```text
Você é Frontend Engineer deste projeto SaaS de barbearia.

Contexto:
- O plano oficial está em .rules/implementation-plan.md.
- Objetivo: experiência FODA, mobile-first, com foco em conversão e clareza.
- Back vai entregar contratos estáveis de dados reais.

Sua missão:
1) Implementar UI mobile-first dos fluxos críticos:
   - Dashboard operacional,
   - Caixa,
   - Agenda,
   - Checkout,
   - Assinatura/Packs/Wallet,
   - CRM/Campanhas/Promoções.
2) Aplicar UI Foundation do plano:
   - componentes reutilizáveis,
   - estados loading/vazio/erro/sucesso,
   - CTA principal por tela,
   - ação crítica ao alcance do polegar.
3) Remover acoplamento com dados mock nas telas críticas.

Restrições:
- Não redesenhar o produto do zero.
- Reaproveitar linguagem visual premium já existente.
- Evitar complexidade de navegação e fluxos longos.

Formato de saída esperado:
- Lista de telas/componentes alterados,
- Fluxos validados ponta a ponta com dados reais,
- Pendências objetivas para integração final com backend.
```

---

## 38) Prompt pronto — Integração final Back + Front

Use este prompt depois dos dois blocos concluídos:

```text
Você é o integrador técnico final entre backend e frontend.

Objetivo:
Conectar os fluxos críticos do SaaS de barbearia com dados reais e UX mobile-first sem regressão.

Tarefas:
1) Validar contrato back↔front em todos os fluxos:
   - agenda, caixa, checkout, assinatura/packs, CRM, cashback.
2) Corrigir divergências de payload, status e tratamento de erro.
3) Executar smoke test funcional dos 5 fluxos críticos mobile.
4) Fechar com checklist de pronto:
   - sem mock em tela crítica,
   - CTA principal clara,
   - regra de negócio refletida na interface.

Formato de saída:
- Matriz fluxo x status (ok/ajuste),
- Ajustes aplicados,
- Lista final de riscos residuais para próxima iteração.
```

---

## 39) Estrutura final de execução paralela (arquivos separados)

Para rodar em paralelo sem conflito:

- Backend usa: `.rules/implementation-backend.md`
- Frontend usa: `.rules/implementation-frontend.md`
- Integração final usa: `.rules/implementation-integration.md`

Ordem prática:

1) Backend e Frontend executam em paralelo com contratos simples.
2) Integrador Senior consolida, corrige divergências e fecha smoke test.
3) Só depois disso considerar o ciclo como concluído.
