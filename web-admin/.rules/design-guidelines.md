## **design-guidelines.md**  
## **Tese emocional do produto**  
**“Gestão que transmite justiça, controle e tranquilidade — como uma barbearia premium bem organizada no início do dia.”**  
Inspirado em *Kindness in Design*: o sistema deve **acalmar**, não pressionar.  
Inspirado em *Kindness in Design*: o sistema deve **acalmar**, não pressionar.  
  
## **Princípios-mãe de design**  
* Clareza > densidade.  
* Transparência > surpresa.  
* Confiança > ostentação.  
* O sistema **explica**, nunca acusa.  
* Todo número deve “fazer sentido à primeira vista”.  
  
## **Sistema visual**  
## **Tipografia**  
Objetivo: **confiança, leitura rápida e neutralidade elegante**.  
* **H1**: 28–32px · Semibold  
* **H2**: 22–24px · Semibold  
* **H3**: 18–20px · Medium  
* **Body**: 15–16px · Regular  
* **Caption**: 13px · Regular  
Regras:  
* Line-height ≥ 1.5×.  
* Nunca usar mais de 2 famílias tipográficas.  
* Números financeiros sempre bem espaçados e legíveis.  
  
## **Sistema de cores**  
Objetivo: **calma operacional + autoridade**.  
**Cores principais**  
* **Primária**: Grafite profundo (confiança).  
* **Secundária**: Cinza claro neutro (base).  
* **Acento**: Verde suave (positivo / lucro).  
* **Alerta**: Âmbar (atenção, não erro).  
* **Erro**: Vermelho controlado (raramente).  
Regras:  
* Nada de vermelho agressivo para finanças.  
* Verde nunca deve “gritar”.  
* Contraste mínimo WCAG AA (≥ 4.5:1).  
  
## **Light & Dark mode**  
* Light = padrão operacional.  
* Dark = leitura prolongada / líderes / dashboards.  
* Mesma hierarquia em ambos.  
* Nunca inverter significados de cores.  
  
## **Espaçamento & layout**  
Objetivo: **respiração visual**.  
* Grid base: **8pt**.  
* Cards com padding generoso.  
* Dashboards em blocos claros.  
* Evitar telas “cheias demais”.  
Regra simples:  
Se precisar explicar onde clicar, o layout falhou.  
Se precisar explicar onde clicar, o layout falhou.  
  
## **Motion & interações**  
Inspirado em *Kindness in Design*.  
* Duração padrão: **150–250ms**.  
* Easing suave.  
* Nada “saltando”.  
* Feedback imediato, discreto.  
Exemplos:  
* Comissão calculada → fade-in calmo.  
* Fechamento de caixa → confirmação sólida, sem fogos.  
* Erro → mensagem clara + ação sugerida.  
  
## **Voice & tone (microcopy)**  
## **Personalidade**  
* Profissional.  
* Calmo.  
* Justo.  
* Nunca irônico.  
## **Exemplos**  
**Onboarding**  
“Vamos configurar sua barbearia. Leva poucos minutos.”  
“Vamos configurar sua barbearia. Leva poucos minutos.”  
**Sucesso**  
**Sucesso**  
“Caixa fechado com sucesso.”  
“Caixa fechado com sucesso.”  
**Erro**  
**Erro**  
“Algo não fechou aqui. Verifique os valores antes de continuar.”  
“Algo não fechou aqui. Verifique os valores antes de continuar.”  
Nunca:  
* “Você errou”.  
* “Dados inválidos”.  
* “Falha crítica”.  
  
## **Padrões recorrentes**  
* Cards como unidade principal.  
* Dashboards sempre no topo.  
* Filtros simples.  
* Explicações inline (ex.: comissão).  
Referências:  
* Linear (clareza).  
* Apple Human Interface (calma).  
* shadcn/ui (consistência).  
  
## **Hierarquia de usuários (visual)**  
* **Dono**: visão total, dashboards completos.  
* **Gestor**: operação + metas.  
* **Líder**: visão ampliada da equipe.  
* **Barbeiro**: foco em agenda, pontos e ganhos.  
A UI deve **mostrar poder sem parecer hierárquica**.  
  
## **Acessibilidade**  
* Navegação por teclado.  
* Estados de foco visíveis.  
* Sem dependência exclusiva de cor.  
* Texto sempre selecionável.  
* Ícones sempre com rótulo.  
  
## **Checklist emocional (auditoria)**  
Antes de aprovar qualquer tela:  
* Isso transmite controle ou ansiedade?  
* O usuário entende o número sem ajuda?  
* Um barbeiro confiaria nesse cálculo?  
* O erro ensina ou pune?  
* Dá para usar cansado?  
Se alguma resposta for “não”, revisar.  
  
## **Checklist técnico de QA**  
* Contraste AA+.  
* Hierarquia tipográfica consistente.  
* Motion dentro do padrão.  
* Estados de hover / foco visíveis.  
* Nenhum elemento “decorativo demais”.  
  
## **Design Snapshot**  
## **Paleta (exemplo)**  
```

Primária: #1F1F1F
Secundária: #F2F2F2
Acento: #4CAF50
Alerta: #FFC107
Erro: #E53935

```
## **Escala tipográfica**  
* H1: 32px  
* H2: 24px  
* H3: 20px  
* Body: 16px  
* Caption: 13px  
## **Sistema de layout**  
* Grid 8pt  
* Cards como base  
* Dashboards modulares  
## **Tese emocional**  
Gestão justa, silenciosa e confiável.  
  
## **Design Integrity Review**  
O design proposto equilibra **autoridade e empatia**.Sugestão de melhoria futura: criar **visualizações animadas simples** para explicar comissão por pontos — educa sem texto longo.  
