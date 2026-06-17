# Browser Audit - 2026-06-16

Relatorio da validacao visual/funcional feita com o Browser embutido do Codex no projeto `Barber Hub`.

## Contexto

- Projeto: `C:\Users\Juan\Documents\Projetos Starken\Barber Hub`
- App validado em:
  - `http://127.0.0.1:8080`
  - `http://localhost:8080`
- Objetivo: abrir o app local, navegar pelas telas principais, inspecionar DOM, capturar estado visual e registrar problemas encontrados.

## O Que Foi Testado

1. Conexao do Browser embutido.
2. Abertura da pagina inicial.
3. Login com credenciais demo.
4. Selecao de loja.
5. Dashboard principal.
6. Modulos administrativos:
   - Caixa
   - Comissoes
   - Barbeiros
   - Escala
   - Clientes
   - Servicos
   - Produtos
   - Estoque
   - Despesas
   - Metas e Bonus
   - Relatorios
   - Configuracoes
7. Menu lateral em desktop e mobile.
8. Toggle de tema.
9. Rotas publicas de cliente.

## Fluxo Executado

- A pagina inicial carregou em `/`.
- O login com `admin@alces.com` / `Alces@2026` funcionou.
- O fluxo levou para `/stores`.
- A selecao da loja abriu `/dashboard/<storeId>`.
- A navegaacao pelo sidebar funcionou nos modulos internos.
- O menu mobile tambem abriu e permitiu navegar para `Clientes`.

## Achados

### 1. Rotas profundas sem fallback no servidor local

- `http://127.0.0.1:8080/` responde `200`.
- `http://127.0.0.1:8080/client` responde `404`.
- `http://127.0.0.1:8080/clients` responde `404`.
- O header do servidor local mostrou `SimpleHTTP/0.6 Python/3.12.13`.
- Em contraste, o app usa `BrowserRouter` e o `vercel.json` tem rewrite para `index.html`, entao o problema parece ser do servidor local atual, nao do app em si.

### 2. Duplicacao visual de dados

- Em `stores`, o mesmo card de loja apareceu repetido varias vezes.
- Em `barbers`, cada profissional apareceu em dobro.
- Em `clients`, varios clientes tambem apareceram repetidos.
- Isso sugere duplicacao nos dados vindos do backend ou na forma como as listas estao sendo renderizadas.

### 3. Tema com estado inconsistente

- O menu de tema abre corretamente e a opcao `Claro` muda `document.documentElement.className` para `light`.
- Mesmo assim, a interface permaneceu visualmente escura.
- Ou seja, o estado do tema muda, mas o estilo computado nao acompanha a troca como esperado.

### 4. Layout mobile apertado em alguns pontos

- A selecao de loja no mobile fica muito comprimida e o texto do card quebra bastante.
- O menu lateral mobile funciona, mas ocupa bastante espaco visual e deixa a navegaacao densa na parte inferior.

## Comportamento Que Funcionou Bem

- Login via formulario.
- Redirecionamento para selecao de loja.
- Abertura do dashboard.
- Navegacao entre modulos do sidebar.
- Abertura de `Configuracoes` com tabs e campos editaveis.
- Abertura de `Relatorios` com cards, graficos e seletor de periodo.
- Acoes simples de UI como abrir/fechar menu lateral e alternar tema.

## Referencias Utilizadas

- `src/App.tsx`
- `src/contexts/AuthContext.tsx`
- `src/components/layout/DashboardLayout.tsx`
- `src/components/layout/AppSidebar.tsx`
- `src/hooks/useStore.ts`
- `src/hooks/useBarbers.ts`
- `src/hooks/useClients.ts`
- `src/pages/StoreSelection.tsx`
- `vite.config.js`
- `vercel.json`

## Observacao Sobre Capturas

Durante a auditoria, eu tentei gerar capturas automatizadas fora do browser embutido. Essas tentativas acabaram criando arquivos temporarios de perfil do Chrome dentro de `browser-audit-screenshots/`, mas o teste principal foi feito e verificado no Browser do Codex.

## Resumo Final

- O app principal esta navegando.
- O login demo funciona.
- Os modulos internos abrem.
- Existem tres pontos que merecem correcao prioritaria:
  - fallback de rotas local
  - duplicacao de registros em listas
  - tema com mudanca de estado sem reflexo visual completo
