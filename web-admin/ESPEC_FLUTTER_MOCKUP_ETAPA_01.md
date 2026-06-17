# Especificacao Flutter - Mockup Etapa 01

Documento operacional para o mock navegavel do app cliente em Flutter, usando o `barberhub360` como referencia visual e funcional.

## 1. Base Do App

### Pilares

- mobile first
- navegacao simples
- visual premium escuro com acento dourado
- dados mockados, sem backend real
- foco no fluxo de cliente

### Regra De Ouro

Tudo que o usuario precisa entender sobre o produto deve caber neste mock:

- escolher unidade
- ver servicos
- agendar
- assinar
- comprar pacote
- navegar no menu

## 2. Design System Mínimo

### Cores

- `primary`: dourado
- `background`: preto profundo
- `surface`: grafite
- `surfaceSoft`: cinza escuro
- `textPrimary`: branco suave
- `textSecondary`: cinza medio
- `success`: verde
- `warning`: amarelo
- `danger`: vermelho

### Tipografia

- titulo: serifado forte, usado com moderação
- corpo: sem serifa limpa
- labels: caixa alta pequena

### Componentes

- `PrimaryButton`
- `SecondaryButton`
- `GhostButton`
- `AppHeader`
- `BottomNav`
- `SectionTitle`
- `StatCard`
- `ServiceCard`
- `BarberCard`
- `PlanCard`
- `PackageCard`
- `UnitCard`
- `ProductCard`
- `InputField`
- `SelectField`
- `StatusBadge`
- `EmptyState`
- `LoadingState`
- `ErrorState`
- `ConfirmationSheet`
- `Toast`

## 3. Telas

### Home

Objetivo: ser a porta de entrada e mostrar a marca.

Elementos:

- header com logo/nome
- destaque principal
- atalhos `Agendar` e `Servicos`
- resumo rapido de horario, endereco e contato
- bloco de clube/assinatura
- promocoes
- barbeiros em carrossel
- bottom nav

### Agendar

Objetivo: fluxo em passos, com selecao de cliente, servico, barbeiro, data e horario.

Passos:

1. cliente
2. servico
3. barbeiro
4. data
5. horario
6. resumo

Elementos:

- progresso do passo
- lista de opcoes em cards
- selecao visual de estado
- resumo final
- botao fixo de continuar/confirmar

Estados obrigatorios:

- sem unidade selecionada
- loading
- erro ao carregar
- horario indisponivel
- barbeiro em folga

### Servicos

Objetivo: listar o catalogo principal.

Elementos:

- header
- lista de cards de servico
- preco
- duracao
- descricao curta
- botao `Agendar`

### Assinatura

Objetivo: mostrar planos do clube.

Elementos:

- destaque do clube
- lista de planos
- diferencas entre planos
- CTA para escolher plano
- area de confirmacao

### Pacotes

Objetivo: mostrar compra avulsa / combos.

Elementos:

- cards de pacote
- preco
- beneficio
- CTA `Comprar`
- aviso de pagamento

### Unidades / Endereco

Objetivo: permitir troca de unidade e leitura da loja.

Elementos:

- lista de unidades
- card com endereco
- status da unidade
- barbeiros da unidade
- CTA de selecionar unidade

### Login

Objetivo: acesso rapido ao fluxo principal.

Elementos:

- email
- senha
- botao entrar
- links para cadastro e recuperar senha

### Cadastro

Objetivo: criar conta mockada.

Elementos:

- nome
- email
- senha
- confirmacao
- validacoes

### Menu / Produtos

Objetivo: catalogo e navegacao complementar.

Elementos:

- lista de produtos
- categorias
- cards
- CTA para carrinho ou detalhes

### Checkout

Objetivo: simular confirmacao de pagamento.

Elementos:

- resumo do pedido
- forma de pagamento
- total
- botao confirmar
- mensagem de sucesso / erro

### Perfil

Objetivo: dados do usuario e acessos secundarios.

Elementos:

- dados do cliente
- historico
- opcoes rapidas

## 4. Fluxos Prioritarios

### Fluxo A

Home -> Servicos -> Agendar -> Resumo -> Sucesso

### Fluxo B

Home -> Assinatura -> Plano -> Pagamento -> Sucesso

### Fluxo C

Home -> Menu -> Produtos -> Checkout -> Sucesso

### Fluxo D

Home -> Unidades -> Trocar unidade -> Home atualizada

## 5. Dados Mockados Necessarios

- unidades: Itoupava Seca, Escola Agricola
- barbeiros: nomes, especialidade, nota, status
- servicos: nome, duracao, preco
- planos: mensal, pix, cartao
- pacotes: combos e avulsos
- produtos: itens do menu
- promocoes: cards da home

## 6. Estados De UI

### Loading

- skeleton em cards
- spinner em areas criticas

### Empty

- sem servicos
- sem barbeiros
- sem agenda
- sem resultados

### Success

- agendamento confirmado
- assinatura confirmada
- pagamento concluido

### Error

- senha fraca
- hora indisponivel
- folga do profissional
- falha de pagamento

## 7. Prioridade De Implementacao

1. design system
2. navegacao base
3. home
4. agendamento
5. assinatura
6. checkout
7. menu / produtos
8. login / cadastro
9. estados finais
10. pacote para TestFlight

## 8. Referencias Diretas

- [PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md](./PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md)
- [prints-app-referencia-contact-sheet.png](./prints-app-referencia-contact-sheet.png)
- [src/pages/client/ClientHome.tsx](./src/pages/client/ClientHome.tsx)
- [src/pages/client/ClientBooking.tsx](./src/pages/client/ClientBooking.tsx)
- [src/pages/client/ClientServices.tsx](./src/pages/client/ClientServices.tsx)

## 9. Definicao De Pronto

O mock da etapa 01 esta pronto quando:

- navega sem depender de backend
- parece o produto real do cliente
- cabe bem em iPhone
- tem fluxo de agendamento e assinatura entendivel
- pode ser mostrado no TestFlight para validacao de negocio
