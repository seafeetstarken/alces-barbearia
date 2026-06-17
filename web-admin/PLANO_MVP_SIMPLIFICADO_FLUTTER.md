# Plano MVP Simplificado - Flutter / TestFlight

Este e o caminho enxuto para a primeira entrega do app cliente em Flutter.

## Intencao

Subir uma versao simples no TestFlight para o cliente entender o fluxo, a cara do produto e os pontos principais de interacao.

## Regra Principal

Menos telas, menos passos, menos ruido.

Se algo nao ajuda o cliente a entender o fluxo principal, entra depois.

## O Que Entra Nesta Fase

1. `Home`
2. `Unidades`
3. `Servicos`
4. `Agendamento`
5. `Assinatura`
6. `Login`
7. `Cadastro`
8. `Perfil`
9. `Sucesso` e `Erro`

## O Que Fica Para Depois

- pacotes
- loja completa
- checkout detalhado
- catalogo de produtos
- funcionalidades administrativas
- pagamentos reais
- integrações reais

## Fluxo Simples

1. O usuario entra na `Home`
2. Vê a unidade ativa
3. Abre `Servicos`
4. Faz `Agendamento`
5. Vê `Resumo`
6. Recebe `Sucesso`
7. Se quiser, acessa `Assinatura`

## Design System

### Visual

- fundo escuro
- dourado como acento principal
- cards simples
- tipografia forte nos titulos
- poucos elementos por tela

### Componentes

- botao primario
- botao secundario
- card simples
- badge
- header
- bottom nav
- loading
- empty state
- erro

## Direcao De Conteudo

O app deve parecer uma versao clara e premium do que ja existe no `barberhub360`, sem adicionar complexidade agora.

## Ordem De Execucao

1. fechar tema
2. montar shell do app
3. montar `Home`
4. montar `Servicos`
5. montar `Agendamento`
6. montar `Assinatura`
7. montar `Login` e `Cadastro`
8. montar `Perfil`
9. revisar telas em iPhone
10. gerar build para TestFlight

## Definicao De Pronto

A etapa 01 esta pronta quando:

- o cliente entende a jornada sem explicacao extra
- o app esta elegante, mas simples
- o fluxo principal funciona de ponta a ponta
- a base visual fica pronta para evoluir depois

## Referencias

- [PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md](./PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md)
- [ESPEC_FLUTTER_MOCKUP_ETAPA_01.md](./ESPEC_FLUTTER_MOCKUP_ETAPA_01.md)
- [FLUTTER_APP_STRUCTURE.md](./FLUTTER_APP_STRUCTURE.md)
- [prints-app-referencia-contact-sheet.png](./prints-app-referencia-contact-sheet.png)
