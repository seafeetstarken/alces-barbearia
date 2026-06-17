# Estrutura Inicial Flutter

Base para iniciar o mock do app cliente em Flutter usando o `barberhub360` como referencia visual e funcional.

## 1. Objetivo Da Estrutura

Organizar o app de forma simples o suficiente para:

- mostrar o fluxo no TestFlight
- facilitar mock de dados
- permitir evolucao para backend depois
- reaproveitar o que ja existe como linguagem visual

## 2. Decisao De Arquitetura

### Camadas

- `presentation`: telas, widgets e navegacao
- `domain`: modelos e contratos
- `data`: mocks locais e futuros repositories
- `shared`: tema, constantes, helpers e componentes reutilizaveis

### Estado

Para a etapa 01, o estado pode ser leve e previsivel:

- `StatefulWidget` para fluxos de passo a passo
- `ValueNotifier` ou `ChangeNotifier` para estado simples
- `Provider` ou `Riverpod` apenas se a necessidade crescer

O foco aqui e reduzir complexidade, nao criar uma arquitetura pesada antes da hora.

## 3. Estrutura De Pastas Sugerida

```text
lib/
  main.dart
  app/
    barberhub_app.dart
    router.dart
    theme.dart
  core/
    constants/
      app_colors.dart
      app_spacing.dart
      app_text_styles.dart
    data/
      mock_units.dart
      mock_barbers.dart
      mock_services.dart
      mock_plans.dart
      mock_products.dart
    models/
      unit.dart
      barber.dart
      service_item.dart
      plan.dart
      package_item.dart
      product_item.dart
      appointment.dart
    widgets/
      app_header.dart
      bottom_nav.dart
      primary_button.dart
      secondary_button.dart
      ghost_button.dart
      section_title.dart
      stat_card.dart
      card_shell.dart
      status_badge.dart
      empty_state.dart
      loading_state.dart
      error_state.dart
      confirmation_sheet.dart
      field_input.dart
      field_select.dart
  features/
    splash/
      splash_page.dart
    auth/
      login_page.dart
      register_page.dart
      forgot_password_page.dart
    home/
      home_page.dart
      widgets/
    booking/
      booking_page.dart
      booking_summary_sheet.dart
      widgets/
    services/
      services_page.dart
      widgets/
    subscription/
      subscription_page.dart
      widgets/
    packages/
      packages_page.dart
      widgets/
    units/
      units_page.dart
      widgets/
    catalog/
      catalog_page.dart
      widgets/
    checkout/
      checkout_page.dart
      success_page.dart
      error_page.dart
    profile/
      profile_page.dart
```

## 4. Navegacao Principal

### Rotas Base

- `/splash`
- `/login`
- `/register`
- `/forgot-password`
- `/home`
- `/booking`
- `/services`
- `/subscription`
- `/packages`
- `/units`
- `/catalog`
- `/checkout`
- `/checkout/success`
- `/checkout/error`
- `/profile`

### Navegacao Global

O app deve ter:

- header superior
- bottom navigation fixa
- rotas secundarias em tela cheia
- modais ou sheets para passos curtos

## 5. Modelos De Dominio

### `Unit`

- `id`
- `name`
- `address`
- `phone`
- `status`
- `openingHours`
- `coverImage`

### `Barber`

- `id`
- `name`
- `specialty`
- `rating`
- `status`
- `avatar`
- `unitId`

### `ServiceItem`

- `id`
- `name`
- `price`
- `durationMinutes`
- `description`
- `unitId`

### `Plan`

- `id`
- `name`
- `price`
- `billingCycle`
- `features`
- `paymentMethods`

### `PackageItem`

- `id`
- `name`
- `price`
- `benefits`
- `highlight`

### `ProductItem`

- `id`
- `name`
- `price`
- `image`
- `category`
- `description`

### `Appointment`

- `id`
- `unitId`
- `clientName`
- `barberId`
- `serviceId`
- `date`
- `time`
- `status`

## 6. Dados Mockados

Os mocks devem bater com a linguagem dos prints:

- unidades: Itoupava Seca e Escola Agricola
- barbeiros: equipe com status, rating e especialidade
- servicos: corte, barba, combo, pigmentacao
- planos: pix, cartao e mensal
- pacotes: combos e ofertas
- produtos: itens de loja

Os dados precisam ser consistentes entre telas. Se um barbeiro aparece na home, ele tem que existir no booking e nos cards de unidade.

## 7. Componentes Reutilizaveis

### Base Visual

- `CardShell`
- `SectionTitle`
- `StatusBadge`
- `PrimaryButton`
- `SecondaryButton`
- `GhostButton`

### Fluxo

- `StepperHeader`
- `StepPill`
- `SelectionCard`
- `SummaryBlock`
- `StickyActionBar`

### Feedback

- `LoadingState`
- `EmptyState`
- `ErrorState`
- `Toast`
- `SuccessScreen`

## 8. Telas Por Prioridade

### Prioridade 1

- `Home`
- `Booking`
- `Services`
- `Units`

### Prioridade 2

- `Subscription`
- `Packages`
- `Catalog`
- `Checkout`

### Prioridade 3

- `Login`
- `Register`
- `Forgot Password`
- `Profile`

## 9. Fluxo De Implementacao

1. criar tema e tokens
2. criar rotas e shell do app
3. criar modelos e mocks
4. criar componentes base
5. montar `Home`
6. montar `Units`
7. montar `Services`
8. montar `Booking`
9. montar `Subscription` e `Packages`
10. montar `Catalog` e `Checkout`
11. montar `Login` e `Profile`
12. revisar estados finais

## 10. Critérios De Qualidade

- texto cabe sem quebrar layout
- bottom navigation nao sobrepoe conteudo
- cards se alinham bem em iPhone
- fluxo booking funciona sem backend
- fluxo assinatura funciona sem backend
- tema escuro reproduz a assinatura visual do produto
- estados de erro e sucesso sao claros

## 11. Saida Esperada Da Etapa 01

Ao final, teremos:

- estrutura pronta em Flutter
- mock navegavel para TestFlight
- base visual consistente com o `barberhub360`
- fluxo que o cliente entende de primeira

## 12. Referencias

- [PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md](./PLANO_ETAPA_01_FLUTTER_TESTFLIGHT.md)
- [ESPEC_FLUTTER_MOCKUP_ETAPA_01.md](./ESPEC_FLUTTER_MOCKUP_ETAPA_01.md)
- [prints-app-referencia-contact-sheet.png](./prints-app-referencia-contact-sheet.png)
