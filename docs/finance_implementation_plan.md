# Plano de Implementação: Módulo Financeiro (Gestão de Resultados)

Este plano detalha a implementação do módulo financeiro no **App Admin**, focado em acompanhamento, supervisão e gestão de lucratividade (entradas vs. saídas).

## 1. Visão Geral
Transformar o módulo financeiro em um painel de controle para o gestor, integrando os dados operacionais do Caixa (Vendas) com os dados administrativos (Compras e Despesas).

---

## 2. Backend (Servidor Go)

### A. Banco de Dados (SQL)
#### [MODIFY] [init_db.sql](file:///c:/Users/Emanuel/Desktop/ERP%20UnifyTechXenos/app-backend/init_db.sql)
- **Criação da View `vw_fluxo_caixa`**: Uma visão consolidada que une:
    - Vendas à vista (`venda_pagamento`).
    - Contas pagas (`conta_pagar` com status 'paga').
    - Movimentações de caixa (Sangrias/Suprimentos).

### B. Automação de Processos
#### [MODIFY] [compra_service.go](file:///c:/Users/Emanuel/Desktop/ERP%20UnifyTechXenos/app-backend/internal/service/compra_service.go)
- **Geração Automática**: Ao criar uma compra, o sistema deve inserir automaticamente um registro na tabela `conta_pagar` vinculando o fornecedor e o valor total.

### C. Agregação de Dados
#### [MODIFY] [financeiro_service.go](file:///c:/Users/Emanuel/Desktop/ERP%20UnifyTechXenos/app-backend/internal/service/financeiro_service.go)
- Refatorar o método `FluxoCaixa` para consumir a nova View e retornar totais de Entrada, Saída e Saldo Acumulado.

---

## 3. Frontend (App Admin - Flutter)

### A. Repositório e Provedores
#### [MODIFY] [finance_provider.dart](file:///c:/Users/Emanuel/Desktop/ERP%20UnifyTechXenos/app-admin/lib/presentation/providers/finance_provider.dart)
- Adicionar um novo provedor `financialSummaryProvider` que traz os KPIs consolidados (Faturamento Bruto, Despesas de Compras, Lucro Projetado).

### B. Interface (UI)
#### [MODIFY] [finance_screen.dart](file:///c:/Users/Emanuel/Desktop/ERP%20UnifyTechXenos/app-admin/lib/presentation/views/finance/finance_screen.dart)
- **Dashboard de Topo**: Implementar Cards com os indicadores financeiros principais.
- **Acompanhamento de Contas**:
    - Abas para `Contas a Pagar` (Fornecedores) e `Movimentação de Caixa` (Operacional).
    - As tabelas serão estritamente de **leitura (ReadOnly)** para acompanhamento do gerente.
- **Gráficos**: Adicionar um gráfico simples de barras mostrando a relação Entrada vs. Saída dos últimos 7 dias.

---

## 4. Ordem de Execução
1.  **SQL**: Criar a View no PostgreSQL.
2.  **Backend Logic**: Implementar a criação automática de Contas a Pagar nas Compras.
3.  **Backend API**: Ajustar endpoints do Financeiro.
4.  **Frontend**: Atualizar a `FinanceScreen` com os novos Dashboards e tabelas de acompanhamento.

---

## 5. Verificação de Segurança
- [ ] Validar que o Admin **não permite** alterar saldos de vendas (apenas visualiza).
- [ ] Testar se ao deletar uma compra (admin), a conta a pagar vinculada é tratada corretamente.
- [ ] Verificar integridade dos dados na View de Fluxo de Caixa.
