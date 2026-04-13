# Especificação Técnica: Módulo de Fornecedores Avançado (3ª Aba)

Esta especificação detalha as alterações para implementar o **Filtro de Inativos** e a nova aba de **Consultas por Fornecedor**.

---

## 1. Arquitetura de Interface (3 Abas)

**Arquivo**: `lib/presentation/views/purchases/purchases_screen.dart`
- **Ação**: Alterar o `DefaultTabController(length: 3, ...)` (Linha 19).
- **Ação**: Adicionar o título `Tab(text: 'CONSULTAS POR FORNECEDOR')` (Linha 58).
- **Ação**: No `TabBarView` (Linha 63), inserir o novo widget `SupplierAnalyticsTab()`.

---

## 2. Filtro de Fornecedores Inativos

### Backend (Go)
**Arquivo**: `internal/service/fornecedor_service.go`
- **SQL (Linha 23)**: `WHERE empresa_id = $1 AND (ativo = true OR $2 = true)`
- **Handler (`fornecedor_handler.go`)**: Ler `r.URL.Query().Get("incluir_inativos")`.

### Frontend (Flutter)
**Arquivo**: `lib/presentation/providers/supplier_provider.dart`
- **Ação**: Criar `supplierInactivesProvider` (Notifer booleano).
- **Ação**: Atualizar `Suppliers.build` para usar `ref.watch(supplierInactivesProvider)`.
- **UI (`suppliers_tab.dart`)**: Adicionar um `Switch` ou `FilterChip` na toolbar (Linha 32) para alternar o status do provider.

---

## 3. Aba de Consultas (Histórico e Dashboard)

### Novo Widget: `SupplierAnalyticsTab`
**Arquivo**: `lib/presentation/views/purchases/supplier_analytics_tab.dart` (Criar este arquivo).
- **Componentes**:
  1. **Seletor**: Um `Dropdown` ou `Autocomplete` para escolher um fornecedor (Carregar a lista do `suppliersProvider`).
  2. **Loader**: Ao selecionar, disparar o fetch das compras.
  3. **Tabela de Histórico**: Exibir os resultados filtrados.

### Backend - Filtro de Compra
**Arquivo**: `internal/service/compra_service.go`
- **Lógica SQL (Linha 118)**: Adicionar `AND (c.fornecedor_id = $2 OR $2 = 0)`.
- **Handler (`compra_handler.go`)**: Capturar o query param `fornecedor_id`.

---

## 4. Passo a Passo para o Desenvolvedor

1.  **Backend Primeiro**: Ajustar as signatures das funções `Listar` nos serviços Go e os SQLs.
2.  **API Frontend**: Atualizar `supplier_repository.dart` e `purchase_repository.dart` para suportar os novos parâmetros opcionais.
3.  **Estado**: Criar o provider de histórico filtrado:
    ```dart
    @riverpod
    Future<List<Compra>> supplierHistory(SupplierHistoryRef ref, int supplierId) {
      return ref.read(purchaseRepositoryProvider).listar(fornecedorId: supplierId);
    }
    ```
4.  **UI**: Implementar a lógica de troca de abas e o widget de análise.

---

## 5. Por que esta é a melhor abordagem?
- **Escalabilidade**: Carregar dados por fornecedor evita sobrecarga de memória inicial.
- **Produtividade**: O gerente tem uma tela dedicada para analisar um fornecedor específico sem perder o contexto das compras gerais.
- **Generic**: Funciona para mercados, farmácias ou qualquer comércio com fluxo constante de entrada.
