# Plano Operacional Backend — Execução Paralela

## Objetivo

Entregar a base de dados e regras de negócio para o frontend operar sem mock, com foco em velocidade e previsibilidade.

## Escopo fechado do backend

- Tenancy por loja com isolamento real
- Billing com Asaas (assinatura, status e webhook)
- Core transacional (agenda, caixa, transações, histórico)
- Base de CRM/cashback para consumo de UI

## Entregas por bloco

## BE-01 Tenancy mínimo viável

- Criar vínculo usuário↔loja
- Aplicar políticas de acesso por loja e papel
- Garantir que todas as consultas críticas respeitam contexto de loja

### Critério de pronto

- Usuário só lê/escreve dados de loja autorizada
- Perfis de acesso batem com regras de papel

## BE-02 Billing mínimo viável

- Estruturas de assinatura por loja
- Integração inicial Asaas
- Webhook de atualização de status

### Critério de pronto

- Status de assinatura atualizado por evento real
- Bloqueio/liberação de ações baseado em status

## BE-03 Core transacional

- Agenda funcional com persistência
- Fluxo de caixa com abertura, movimentação e fechamento
- Registro de transações com histórico

### Critério de pronto

- Fluxo de atendimento e pagamento fecha sem mock
- Histórico consistente para cliente e gestão

## BE-04 Base CRM e cashback

- Segmentação mínima de clientes
- Registro de campanha e resultado
- Ledger de cashback com créditos/débitos

### Critério de pronto

- Front consegue renderizar segmentos, campanhas e saldo de cashback com dados reais

---

## Contrato obrigatório para frontend

Todo retorno deve seguir:

- `data`
- `error`
- `meta` (quando aplicável)

Padrões:

- IDs sempre string estável
- Datas sempre ISO
- Status com enum fechado

---

## Prompt pronto — Backend Senior Agent

```text
Você é o Backend Senior deste projeto SaaS de barbearia.

Leia e siga estes arquivos:
- .rules/implementation-plan.md
- .rules/implementation-backend.md

Objetivo:
Entregar backend mínimo viável para destravar frontend mobile-first sem mock.

Escopo:
1) Tenancy por loja com isolamento real.
2) Billing com Asaas (assinatura/status/webhook).
3) Core transacional: agenda, caixa, transações, histórico.
4) Base CRM/cashback para UI.

Regras de execução:
- Não criar abstrações desnecessárias.
- Reaproveitar estrutura já existente no repositório.
- Manter contratos estáveis para o front.
- Sempre priorizar clareza de regra de negócio.

Formato da entrega:
- Lista de arquivos alterados.
- Lista de contratos disponíveis por fluxo.
- Checklist de validação para front integrar.
```
