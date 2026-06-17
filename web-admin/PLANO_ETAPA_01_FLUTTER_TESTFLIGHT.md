# Plano - Etapa 01 Flutter / TestFlight

Baseado no `barberhub360` atual e nos prints de referencia em `prints app - referencia`.

## Objetivo

Criar um mock navegavel em Flutter para o app do cliente, pronto para validacao em TestFlight, com foco em:

- entender o fluxo principal do usuario
- validar a linguagem visual
- revisar navegacao, estados e hierarquia de telas
- manter fidelidade ao que o `barberhub360` ja comunica hoje

Nesta etapa nao entra backend real. Tudo deve funcionar com dados mockados e transicoes consistentes.

## Direcao Visual

Vamos reaproveitar a identidade ja existente no `barberhub360`:

- base escura com acentos dourados
- contraste forte para leitura em mobile
- tipografia mais editorial para titulos
- cards limpos e densos
- foco em mobile first

O design system nao deve parecer genérico nem distante do produto atual. A ideia e que o cliente reconheca o mesmo servico, so que reorganizado para Flutter.

## Design System Inicial

### Tokens

- `color.primary`: dourado do produto
- `color.background`: preto/grafite
- `color.surface`: cinza muito escuro
- `color.textPrimary`: branco/quase branco
- `color.textSecondary`: cinza medio
- `color.success`: verde
- `color.warning`: amarelo/laranja
- `color.danger`: vermelho

### Tipografia

- titulo principal com presenca forte
- subtitulos curtos e funcionais
- texto de apoio pequeno e legivel
- sem excesso de pesos ou variações decorativas

### Componentes Base

- botao primario
- botao secundario
- card de servico
- card de barbeiro
- card de plano
- card de pacote
- badge de status
- input
- select
- stepper de fluxo
- bottom navigation
- header com identidade
- modal / sheet
- toast
- estado vazio
- estado de loading
- estado de erro

## Escopo Da Etapa 01

### Telas Do Cliente

1. `Home`
2. `Agendar`
3. `Servicos`
4. `Assinatura`
5. `Pacotes`
6. `Unidades / Endereco`
7. `Login`
8. `Cadastro`
9. `Menu / Produtos`
10. `Checkout`
11. `Perfil`
12. `Sucesso / Erro`

### Fluxos Prioritarios

1. Entrar na home
2. Escolher unidade
3. Ver servicos
4. Agendar horario
5. Ver assinatura / clube
6. Selecionar plano
7. Simular pagamento
8. Ver confirmacao
9. Navegar pelo menu e produtos

## O Que Vamos Mockar

- unidades
- barbeiros
- servicos
- pacotes
- planos de assinatura
- checkout
- estados de validação
- mensagens de erro e sucesso
- loading e empty states

## O Que Nao Entra Ainda

- integracao real com Supabase
- pagamentos reais
- push notifications
- login persistente real
- admin completo
- multi-tenant real

## Ordem Recomendada De Implementacao

1. Fechar design system
2. Criar navegação base no Flutter
3. Montar home
4. Montar fluxo de agendamento
5. Montar assinatura e pacotes
6. Montar menu / produtos
7. Montar login e cadastro mockados
8. Aplicar estados visuais finais
9. Revisar em tamanhos de iPhone
10. Gerar build para TestFlight

## Critérios De Pronto

A etapa 01 so pode ser considerada pronta quando:

- o fluxo principal estiver navegavel ponta a ponta
- as telas estiverem consistentes entre si
- o design system estiver aplicado em todas as rotas principais
- o app estiver apresentavel em iPhone
- os estados de erro, loading e sucesso estiverem cobertos
- o cliente conseguir entender o produto sem explicacao extra

## Referencias

- [prints app - referencia](./prints%20app%20-%20referencia)
- [README.md](./README.md)
- [src/App.tsx](./src/App.tsx)
- [src/pages/client/ClientHome.tsx](./src/pages/client/ClientHome.tsx)
- [src/pages/client/ClientBooking.tsx](./src/pages/client/ClientBooking.tsx)
- [src/pages/client/ClientServices.tsx](./src/pages/client/ClientServices.tsx)

## Observacao

A linha correta aqui e usar o `barberhub360` como base de linguagem visual e comportamento, nao como copia literal de tecnologia. O Flutter vai servir para prototipar uma experiencia mais controlada, pronta para validacao no TestFlight.
