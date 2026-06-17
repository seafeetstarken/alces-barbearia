# Plano Operacional Frontend — Mobile First e UX FODA

## Objetivo

Entregar experiência premium, rápida e clara no celular, conectada aos dados reais do backend.

## Escopo fechado do frontend

- Dashboard operacional mobile-first
- Caixa, agenda e checkout com fluxo curto
- Assinaturas/packs/wallet com foco em conversão
- CRM/campanhas/promoções com execução simples
- Estados de UI padronizados (loading, vazio, erro, sucesso)

## Entregas por bloco

## FE-01 UI Foundation

- Consolidar componentes base reutilizáveis
- Padronizar estados de tela
- Garantir CTA principal evidente por tela

### Critério de pronto

- Todas as telas críticas usam mesmo padrão de layout e feedback

## FE-02 Fluxos críticos de operação

- Dashboard operacional
- Caixa
- Agenda
- Checkout

### Critério de pronto

- Fluxos funcionam em até 3 passos principais
- Sem dados mock em tela crítica

## FE-03 Fluxos de receita e retenção

- Assinaturas e packs
- Wallet e cashback
- CRM e campanhas

### Critério de pronto

- Gestor executa ação comercial sem suporte técnico
- Cliente entende benefício e conclui pagamento sem fricção

---

## Regras de UX mobile-first

- Projetar primeiro para 360–430px
- Ação principal no alcance do polegar
- Evitar navegação profunda
- Priorizar sheet e barras de ação inferiores

---

## Dependências esperadas do backend

- Contrato estável por fluxo
- Enum fechado de status
- Campos obrigatórios sempre presentes para renderização principal

---

## Prompt pronto — Frontend Senior Agent

```text
Você é o Frontend Senior deste projeto SaaS de barbearia.

Leia e siga estes arquivos:
- .rules/implementation-plan.md
- .rules/implementation-frontend.md

Objetivo:
Entregar experiência mobile-first FODA com foco em conversão e clareza, sem overengineering.

Escopo:
1) UI Foundation com componentes e estados padronizados.
2) Fluxos críticos: dashboard, caixa, agenda, checkout.
3) Fluxos de retenção/receita: assinatura, packs, wallet, CRM/campanhas.
4) Remover acoplamento com mocks em telas críticas.

Regras de execução:
- Não redesenhar do zero.
- Reaproveitar linguagem visual premium já existente.
- Uma ação principal por tela.
- Fluxo curto e objetivo.

Formato da entrega:
- Lista de telas/componentes alterados.
- Mapa de fluxos validados ponta a ponta.
- Pendências objetivas para integração final.
```
