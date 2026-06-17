# Plano de Integração Final — Back + Front

## Responsável pela interligação

**Responsável recomendado:** Tech Lead / Integrador Senior.

Motivo:

- visão de ponta a ponta
- capacidade de destravar conflito de contrato rapidamente
- decisão técnica rápida sem criar retrabalho

## Missão da integração

Conectar os fluxos críticos com dados reais, validar UX mobile-first e fechar o ciclo de receita sem regressão.

## Fluxos obrigatórios para integração

- Agenda
- Caixa
- Checkout
- Assinatura/Packs
- CRM/Campanhas
- Cashback

## Checklist de integração

- Contrato back↔front validado em todos os fluxos
- Tratamento de erro consistente na UI
- Sem telas críticas com mock
- Regras de negócio refletidas visualmente
- Smoke test mobile concluído

## Matriz de handoff

## Backend → Frontend

- payload final por fluxo
- status/enum fechado
- exemplos reais de resposta

## Frontend → Integrador

- telas prontas por fluxo
- casos de erro e fallback
- pontos de bloqueio de contrato

## Integrador → Time

- matriz final fluxo x status
- ajustes aplicados
- riscos residuais da próxima iteração

---

## Prompt pronto — Integrador Senior Agent

```text
Você é o Integrador Senior deste projeto SaaS de barbearia.

Leia e siga estes arquivos:
- .rules/implementation-plan.md
- .rules/implementation-backend.md
- .rules/implementation-frontend.md
- .rules/implementation-integration.md

Objetivo:
Conectar backend e frontend com dados reais, sem regressão nos fluxos críticos mobile-first.

Tarefas:
1) Validar contrato de dados em agenda, caixa, checkout, assinatura/packs, CRM e cashback.
2) Corrigir divergências de payload, status e tratamento de erro.
3) Rodar smoke test dos fluxos críticos no mobile.
4) Entregar checklist final de pronto.

Formato da entrega:
- Matriz fluxo x status (ok/ajuste).
- Lista de ajustes aplicados.
- Lista curta de riscos residuais.
```
