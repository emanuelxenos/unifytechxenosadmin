# Plano de Implementação: Relatórios Avançados e Gerenciais

Este documento serve como um guia estruturado para que uma Inteligência Artificial ou Desenvolvedor consiga implementar, de forma modular e segura, a segunda fase do módulo de relatórios do **UnifyTech Xenos ERP**.

## 🎯 Objetivo
Expandir o módulo de relatórios analíticos (`reports_screen.dart`) e as APIs em Go para fornecer Business Intelligence aos gestores. Serão 4 novos pilares implementados: DRE Gerencial, Inadimplência, Curva ABC e Comissões por Operador.

---

## 🛠 Fase 1: Arquitetura de Dados (Backend Go)

A primeira etapa consiste em consultar e somarizadores de dados diretamente no banco de dados PostgreSQL, através de queries SQL dentro do arquivo `app-backend/internal/service/relatorio_service.go`, e em seguida expor essas rotas.

### 1.1 Modificações em `relatorio_service.go`
- **DRE Gerencial (`DREResumo`)**:
  - `Receitas Brutas`: `SUM(valor_total)` das Vendas com status 'concluida' num período (mês).
  - `Deduções/Descontos`: `SUM(valor_total_descontos)`.
  - `Custo da Mercadoria Vendida (CMV)`: Calculado através dos `item_venda` vinculados às vendas somando `quantidade * preco_custo`.
  - `Despesas Operacionais`: Somatório de `conta_pagar` liquidadas do período vigente.
  - `Lucro Líquido`: `Receita Líquida - CMV - Despesas`.
- **Inadimplência (`ContasVencidasResumo`)**:
  - Query: Selecionar dados na tabela `conta_receber` onde `status = 'aberta'` E `data_vencimento < CURRENT_DATE`.
  - Retornar Total de Títulos Vencidos e o Valor Financeiro em Atraso.
- **Curva ABC de Estoque (`CurvaABC`)**:
  - Classificação A (Representa ~80% do faturamento), B (~15%) e C (~5%).
  - Query: Calcular o faturamento gerado por cada `id_produto` historicamente, ordenar de forma decrescente pelo total acumulado e classificar com base na proporção geral.
- **Vendas por Operador (`ComissoesOperador`)**:
  - Agrupar as tabelas `venda` por `usuario_id` (Operador).
  - Somar total de vendas, ticket médio e comissão presumida (usando um percentual pré-estabelecido fixo inicial, ex: 1%).

### 1.2 Mapeando Handlers e Rotas (`relatorio_handler.go` e `router.go`)
- Criar os novos Handlers: `RelatorioDRE`, `RelatorioInadimplencia`, `RelatorioCurvaABC` e `RelatorioComissoes`.
- Configurar os encodadores e conversores JSON com o padrão `utils.JSON(w, http.StatusOK, data)`.
- Amarrar os endpoints no arquivo de rotas (ex: `/api/relatorios/dre`, `/api/relatorios/inadimplencia`).

---

## 💻 Fase 2: Integração e Interface (Frontend Flutter)

Com a fundação do servidor criada, o projeto em Flutter (`app-admin`) precisará abraçar essas rotas e exibir a informação formatada de forma luxuosa e compreensível.

### 2.1 Repositório e Conexões
- No arquivo `lib/core/constants/api_endpoints.dart`, adicionar constante para os novos endpoints REST.
- Em `report_repository.dart`, instanciar novas sub-chamadas assíncronas utilizando a função `_extractMapData` padronizada na fase 1.
- No Provider (`report_provider.dart`), mapear o estado com `FutureProvider` e as flags de carregamento autogeradas.

### 2.2 Ampliando o Frontend (`reports_screen.dart`)
- **Tabela DRE**: Desenvolver um componente elegante no estilo Extrato Bancário. Utilizar espaçamentos estritos (`Row` com `Expanded`) indicando receitas (Verde), despesas (Vermelho) e a Margem final (Ouro/Verde).
- **Lista de Inadimplência**: Incorporar um painel expansível ou `DataTable` para enumerar as faturas vencidas em cor bordô e as respectivas tags com atraso em dias.
- **Gráfico Curva ABC**: Ao invés de usar tabelas, construir um Gráfico de Pizza ou de Barras Sobrepostas coloridas com a proporção de Produtos (Usar biblioteca existente `fl_chart`).
- **Cards de Fechamento por Profissional**: Usar Avatares/`ListTile` descrevendo o ranking de vendedores top daquele mês com o indicativo de comissões.

---

## 🖨️ Fase 3: Exportação Otimizada de Documentos (PDF/Excel)
- Incrementar a lógica nos Handlers Go de `ExportarPDF` e `ExportarExcel`.
- Interceptar os novos valores da flag `tipo` do request HTTP (ex: `&tipo=dre`, `&tipo=abc`, `&tipo=comissoes`).
- Aplicar o layout das tabelas para o PDF utilizando a mesma estratégia gráfica (cores customizadas, título inteligente, rodapé automático) recentemente aprovada.

## 🤖 Como rodar este plano com IA Activa:
1. Comece solicitando à IA para focar APENAS no Item 1.1 (Querys do `relatorio_service.go`). Teste a sintaxe SQL com a arquitetura `Postgres`.
2. Após compilar sem erros, instrua a seguir o Item 1.2 e certifique que o painel rotas e o servidor inicializa vazio.
3. Finalmente, entre no passo de Frontend pedindo a interface unificada dos blocos novos aproveitando componentes da UI local. 
4. Revise os testes de exportação se as funções no Backend respeitam as variáveis da UI.
