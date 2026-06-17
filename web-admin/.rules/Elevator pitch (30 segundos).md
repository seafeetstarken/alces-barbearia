## **Elevator pitch (30 segundos)**  
Uma plataforma **White Label** de gestão completa para barbearias e redes.Centraliza **financeiro, comissões, equipe, estoque e clientes** em um único sistema simples, justo e escalável — sem planilhas, sem confusão.  
  
## **Problema & missão**  
**Problema**  
* Barbearias operam com controles manuais.  
* Comissão de barbeiros gera conflitos e erros.  
* Donos não têm visão clara de lucro por loja.  
* Redes não escalam processos.  
**Missão**  
* Tornar a gestão de barbearias **clara, automática e justa**.  
* Eliminar atrito entre dono e barbeiro.  
* Escalar de uma loja para redes, sem retrabalho.  
  
## **Público-alvo**  
* Donos de barbearia (1 unidade).  
* Donos de redes de barbearia.  
* Gestores operacionais.  
* Barbeiros (incluindo líderes).  
  
## **Proposta de valor**  
* Comissão automática por pontos.  
* Financeiro em tempo real.  
* White Label pronto para venda.  
* Escala nativa para multi-loja.  
* Transparência para barbeiros.  
  
## **Core features (escaneável)**  
## **Gestão financeira**  
* Faturamento por loja.  
* Separação:  
    * Serviços  
    * Vendas de produtos  
* Abertura e fechamento de caixa.  
* Dashboard:  
    * Receita  
    * Despesas  
    * Comissões pagas  
* Controle de despesas por natureza.  
* Integração com gateway de pagamento (~4%).  
## **Comissão & Splitshare**  
* Pontuação por serviço:  
    * Corte → 1 ponto  
    * Corte + barba → 2 pontos  
* 43% da receita distribuída entre barbeiros.  
* Distribuição proporcional aos pontos.  
* Multiplicador de comissão.  
* Vale dos profissionais (adiantamento).  
## **Barbeiros & carreira**  
* Cadastro e gerenciamento de barbeiros.  
* Serviços vinculados por profissional.  
* Escala de trabalho.  
* Metas de venda.  
* Bônus de liderança.  
* Plano de carreira.  
* Líder com visualização diferenciada no app.  
## **Clientes**  
* Lista de clientes ativos.  
* Clientes inadimplentes.  
* Blacklist de clientes.  
## **Produtos & estoque**  
* Cadastro de produtos.  
* Preços tabelados.  
* Inventário.  
* Controle de estoque.  
## **Comercial & planos**  
* Cadastro de planos.  
* Área comercial.  
* Dashboard executivo.  
* Módulo de marketing (ex.: Starken).  
  
## **Modelo White Label**  
* Marca, cores e nome por cliente.  
* Estrutura multi-tenant.  
* Cada cliente pode ter:  
    * Uma ou várias lojas  
    * Usuários com permissões distintas  
  
## **High-level tech stack (conceitual)**  
* **Frontend**: Web + Mobile (experiência consistente).  
* **Backend**: API central multi-tenant.  
* **Banco de dados**: Estrutura por organização → lojas → usuários.  
* **Pagamentos**: Gateway com split e taxas configuráveis.  
* **Analytics**: Dashboards em tempo real.  
*(Sem amarrar tecnologia — foco no produto, não na stack.)*  
  
## **Modelo de dados (ERD em palavras)**  
* Organização (cliente White Label)  
    * → Lojas  
        * → Caixa  
        * → Estoque  
        * → Metas  
    * → Usuários  
        * Dono  
        * Gestor  
        * Barbeiro  
        * Líder  
* Serviços  
* Produtos  
* Vendas  
* Pontos  
* Comissões  
* Despesas  
* Clientes  
  
## **Princípios de UI (Krug)**  
* Não fazer o usuário pensar.  
* Dashboards visuais, não relatórios longos.  
* Ações claras:  
    * Abrir caixa  
    * Fechar caixa  
    * Registrar serviço  
* Números sempre explicáveis.  
    * Ex.: “43% distribuído por pontos”.  
  
## **Segurança & compliance**  
* Isolamento total entre clientes White Label.  
* Permissões por papel.  
* Histórico de ações (auditoria).  
* Backup automático.  
* LGPD:  
    * Dados mínimos  
    * Controle de acesso  
  
## **Roadmap**  
## **MVP**  
* Cadastro de lojas, barbeiros e serviços.  
* Registro de vendas.  
* Pontuação e comissão automática.  
* Caixa básico.  
* Dashboard financeiro.  
## **V1**  
* Estoque.  
* Metas e bônus.  
* Vale de barbeiro.  
* Multi-loja completo.  
* White Label configurável.  
## **V2**  
* Plano de carreira avançado.  
* Marketing integrado.  
* Relatórios comparativos entre lojas.  
* Expansão comercial.  
  
## **Riscos & mitigação**  
* **Complexidade de comissão**  
    * → Regras visuais e exemplos claros no app.  
* **Adoção por barbeiros**  
    * → Transparência total dos cálculos.  
* **Escala multi-loja**  
    * → Separação rígida por organização.  
  
## **Expansões futuras**  
* App para clientes finais.  
* Agendamento online.  
* Programa de fidelidade.  
* Integração contábil.  
* IA para metas e performance.  
