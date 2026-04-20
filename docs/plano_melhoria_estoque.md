# Plano de Implementação: Melhorias no Módulo de Estoque

Este documento detalha o passo a passo para evoluir a tela de estoque atual para um módulo profissional de gestão de inventário.

## 1. Atualização do Repositório (Data Layer)
O primeiro passo é garantir que o app consiga buscar os dados históricos e de inventário.
- **Arquivo**: `lib/data/repositories/stock_repository.dart`
- **Ações**:
    - Implementar `Future<List<EstoqueMovimentacao>> listarMovimentacoes()`.
    - Implementar `Future<List<Inventario>> listarInventarios()`.
    - Endpoint sugerido no backend: `GET /api/estoque/movimentacoes`.

## 2. Implementação dos Providers (State Management)
Criar os provedores que alimentarão as novas abas.
- **Arquivo**: `lib/presentation/providers/stock_provider.dart`
- **Ações**:
    - Criar `stockMovementsProvider` (AsyncNotifier) para gerenciar o histórico.
    - Criar `inventoriesProvider` para gerenciar as contagens de estoque.

## 3. Reformulação da Interface (UI Layer)
Transformar a tela única em uma interface com abas.
- **Arquivo**: `lib/presentation/views/stock/stock_screen.dart`
- **Passos**:
    - Envolver o `Scaffold` em um `DefaultTabController` com 3 abas.
    - **Aba 1: Posição Atual**
        - Adicionar 3 cards de KPI no topo (usando o estilo do `KpiCard` mas implementado localmente para evitar conflitos).
        - Indicadores: Total de Itens, Valor Total (Custo), Alerta de Baixo Estoque.
    - **Aba 2: Histórico (Movimentações)**
        - Implementar uma `DataTable` ou `ListView` que liste as entradas e saídas.
        - Mostrar: Produto, Tipo (Entrada/Saída), Quantidade, Data e Motivo.
    - **Aba 3: Inventários/Contagens**
        - Listar inventários pendentes e realizados.
        - Adicionar botão para "Iniciar Nova Contagem".

## 4. Polimento e UX
- Adicionar filtros de data no histórico.
- Adicionar um toggle "Apenas Estoque Baixo" na aba de posição atual.
- Melhorar as cores dos status (Verde para OK, Vermelho para estoque baixo).

---
*Documento gerado por Antigravity para referência futura.*
