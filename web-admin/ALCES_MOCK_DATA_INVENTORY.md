# Alces Mock Data Inventory

Base para o piloto em Flutter/TestFlight. Aqui fica o que ja existe no projeto e o que vamos reaproveitar no mock inicial da Alces Barbearia.

## 1. Lojas confirmadas

Fonte: `src/lib/supabase/migrations/001_initial_schema.sql`

Para o piloto da Alces, vamos considerar 2 unidades ativas:

- Unidade Itoupava Seca
- Unidade Escola Agricola

Observacao:
- No seed atual do projeto ainda existe uma terceira loja chamada `Alce's Barbearia - Gaspar`, mas ela nao entra no recorte do piloto que voce confirmou.

Dados comuns:
- Telefone: `5547996155719`
- Horario: `08:30` ate `20:00`
- Tema base: dourado/amber da Alces

## 2. Planos de assinatura

Fonte: `src/lib/supabase/migrations/004_backend_mvp_foundation.sql`

Planos ativos:

- `starter_monthly` - Starter Mensal - `R$ 99,00` - teste de 7 dias
- `professional_monthly` - Professional Mensal - `R$ 199,00` - teste de 7 dias
- `enterprise_monthly` - Enterprise Mensal - `R$ 399,00` - teste de 7 dias

Beneficios do clube hoje no app:

- 1 corte por mes
- 15% OFF em servicos
- 10% OFF na loja
- agendamento prioritario

## 3. Servicos confirmados no seed

Fonte: `src/lib/supabase/migrations/001_initial_schema.sql`

- Corte - `R$ 45,00` - `30 min` - `1 ponto`
- Corte + Barba - `R$ 65,00` - `45 min` - `2 pontos`
- Barba - `R$ 35,00` - `20 min` - `1 ponto`
- Pigmentacao - `R$ 80,00` - `40 min` - `2 pontos`

## 4. Servicos ja usados no mock atual

Fonte: `src/pages/client/ClientServices.tsx`

Esses nomes sao bons candidatos para o primeiro pacote visual do app:

- Corte Masculino - `R$ 45` - `30 min`
- Corte + Barba - `R$ 70` - `50 min`
- Barba - `R$ 35` - `25 min`
- Degrade - `R$ 55` - `40 min`
- Pigmentacao - `R$ 80` - `45 min`
- Sobrancelha - `R$ 20` - `15 min`
- Hidratacao - `R$ 40` - `30 min`
- Relaxamento - `R$ 90` - `60 min`

## 5. Produtos para loja

### 5.1 Mock atual do cliente

Fonte: `src/pages/client/ClientShop.tsx`

- Pomada Modeladora - `R$ 45` - `Finalizacao` - estoque `15`
- Oleo para Barba - `R$ 55` - `Barba` - estoque `8`
- Shampoo Antiqueda - `R$ 65` - `Cabelo` - estoque `12`
- Balm para Barba - `R$ 40` - `Barba` - estoque `6`
- Cera Matte - `R$ 50` - `Finalizacao` - estoque `10`
- Condicionador - `R$ 35` - `Cabelo` - estoque `20`

### 5.2 Mock de estoque interno

Fonte: `src/pages/Inventory.tsx`

- Pomada Modeladora - SKU `POM001` - estoque `15` - minimo `5`
- Oleo para Barba - SKU `OLE001` - estoque `8` - minimo `5`
- Shampoo Antiqueda - SKU `SHA001` - estoque `3` - minimo `5`
- Balm para Barba - SKU `BAL001` - estoque `12` - minimo `5`
- Cera Matte - SKU `CER001` - estoque `0` - minimo `5`
- Tonico Capilar - SKU `TON001` - estoque `6` - minimo `3`

## 6. Profissionais

### 6.1 Nomes ja usados no app

Fontes principais:
- `src/pages/client/ClientHome.tsx`
- `src/pages/Reports.tsx`
- `src/pages/Goals.tsx`
- `src/pages/client/ClientProfile.tsx`

Nomes que ja aparecem no projeto:

- Carlos Silva
- Joao Santos
- Pedro Lima
- Joao Pedro
- Lucas Almeida
- Rafael Santos
- Pedro Costa
- Joao da Silva

### 6.2 Nivelacao da equipe

Fonte: `src/lib/supabase/migrations/001_initial_schema.sql`

Niveis disponiveis:

- Junior - multiplicador `0.8`
- Profissional - multiplicador `1.0`
- Senior - multiplicador `1.2`
- Master - multiplicador `1.5`

### 6.3 Profissionais por unidade

Para o piloto, a referencia visual deve separar a equipe por unidade:

- Unidade Itoupava Seca
- Unidade Escola Agricola

O print que voce comentou entra aqui como referencia de profissionais da `Unidade Escola Agricola`.

## 7. Estrutura do piloto em Flutter

Ordem recomendada para copiar para o mock:

1. Lojas
2. Planos
3. Servicos
4. Produtos
5. Profissionais
6. Agendamentos e assinatura

## 8. Observacoes importantes

- O projeto ja tem o branding da Alces pronto, com logo e cor base dourada.
- Os servicos e planos estao bem definidos no codigo.
- Produtos existem como mock visual nas telas, mas nao achei seed real de produto no schema atual.
- O mesmo vale para barbeiros: ha estrutura e nomes de mock, mas ainda vale validar a base real antes do import final.

## 9. Proximo passo

Transformar este inventario em um arquivo de dados unico para o Flutter, para o piloto ja nascer com:

- home do cliente
- agenda
- servicos
- loja
- assinatura
- equipe
