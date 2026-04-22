# Roadmap Técnico: Melhorias Avançadas do Estoque

Este guia descreve o passo a passo para a implementação de 5 novas funcionalidades no módulo de estoque do UniTech Xenos ERP. O objetivo é manter a modularidade e garantir que cada funcionalidade seja independente e testável.

---

## 🛠️ Pré-requisitos e Dependências

### Backend (Go)
- **gofpdf**: Para geração de PDF (já instalado).
- **excelize/v2**: Para exportação Excel (já instalado).

### Frontend (Flutter)
- **url_launcher**: Para abrir os links de download de relatórios.
- **printing / pdf**: (Opcional) Se desejar visualização prévia de etiquetas no app.

---

## 📈 Fase 1: Filtro por Categorias (UI & Provider)

### Passo 1: Atualização do Provider
No arquivo `lib/presentation/providers/product_provider.dart`, os métodos `setCategoria` e a lógica de busca já suportam o parâmetro `categoriaId`. 
**Ação**: Apenas garantir que o estado `ProductState` seja resetado para a página 1 ao mudar a categoria.

### Passo 2: Componente Dropdown na UI
No arquivo `lib/presentation/views/stock/stock_screen.dart`, aba "Posição Atual":
- Implementar um `_buildCategoryFilter()` que utiliza o `categoryProvider`.
- Posicionar ao lado dos filtros de Chips.

---

## 📑 Fase 2: Filtros de Histórico (Backend & UI)

### Passo 1: Backend (Go)
No arquivo `internal/service/estoque_service.go`, o método `ListarMovimentacoes` deve ser alterado:
```go
func (s *EstoqueService) ListarMovimentacoes(ctx context.Context, empresaID int, produtoID int, dataInicio, dataFim, tipo string)
```
- Adicionar a condição `AND tipo_movimentacao = $4` na query SQL se o `tipo` não for vazio.

### Passo 2: UI (Flutter)
Na aba "Histórico", adicionar um seletor (Chips ou Dropdown) para filtrar por: `Entrada`, `Saída`, `Ajuste`, `Inventário`.

---

## 📄 Fase 3: Exportação de Relatórios Detalhados

### Passo 1: Backend (Go)
No arquivo `internal/api/handlers/relatorio_handler.go`:
- Criar o endpoint `ExportarEstoqueDetalhado`.
- Ele deve receber os filtros (search, categoria, status) e gerar um PDF contendo a listagem atual (não apenas o resumo).

### Passo 2: UI (Flutter)
Adicionar botões de "Exportar PDF" e "Exportar Excel" no topo da listagem de estoque.

---

## 🏷️ Fase 4: Impressão de Etiquetas

### Passo 1: Backend (Go)
Criar um serviço `EtiquetaService` que gera um PDF de tamanho customizado (ex: 40x25mm) para gôndolas.
- Conteúdo: Nome do produto, Preço (formatado), Código de Barras (opcional usando biblioteca de fonte ou imagem).

### Passo 2: UI (Flutter)
Nos botões de "Ações" de cada produto na tabela, adicionar um ícone de etiqueta `Icons.label_outline`.

---

## 🛒 Fase 5: Integração com Compras

### Passo 1: Frontend
Identificar quando o filtro de "Reposição" está ativo.
Apresentar um botão flutuante ou no topo "Gerar Pedido de Compra".
- **Lógica**: Agrupar todos os produtos filtrados e enviar para a tela de `PurchaseScreen` via `extra` do `GoRouter`.

---

## 🛡️ Protocolo de Segurança (Não Quebrar o Sistema)

1. **Testes de Regressão**: Após cada fase, validar o `flutter run` para garantir que o `stock_screen.dart` carrega os dados básicos.
2. **Logs**: Manter os logs de erro do Go ativos (`log.Printf`) para rastrear falhas nas novas queries de histórico.
3. **Mocks**: Se o backend demorar para subir, usar dados estáticos no Provider para validar a UI primeiro.
