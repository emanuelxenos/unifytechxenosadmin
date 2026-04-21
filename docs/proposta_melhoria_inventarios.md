# Proposta de Melhoria: Organização e Filtros de Inventários

O objetivo é aprimorar a gestão de inventários permitindo a ordenação decrescente (mais recentes primeiro) e filtros por período (ex: Hoje, Última Semana) na listagem.

## Mudanças Propostas

### Backend (Go)

- **Service (`estoque_service.go`)**: 
  - Alterar assinatura de `ListarInventarios` para aceitar `dataInicio` e `dataFim`.
  - Implementar SQL dinâmico para aplicar os filtros de data na tabela `inventario`.
  - Atualizar a ordenação para `ORDER BY data_inicio DESC, id_inventario DESC`.
- **Handler (`estoque_handler.go`)**:
  - Capturar parâmetros `inicio` e `fim` da URL e passá-los para o serviço.

### Frontend (Flutter)

- **Repository (`stock_repository.dart`)**:
  - Atualizar `listarInventarios` para aceitar `DateTime? inicio` e `DateTime? fim`.
- **Provider (`stock_provider.dart`)**:
  - Transformar `Inventories` em um `Family` ou atualizar para aceitar parâmetros de filtro.
- **UI (`stock_screen.dart`)**:
  - Adicionar uma barra de filtros na aba de inventários com botão "Hoje" e seletor de calendário.

## Plano de Verificação
1. Criar inventários em datas diferentes e validar a ordenação.
2. Aplicar o filtro "Hoje" e validar os resultados.
3. Filtrar por um intervalo customizado.
