# Plano de Implementação: Gerenciamento de Categorias de Produtos (Tela Dedicada)

Este documento detalha as etapas necessárias para implementar a gestão completa de categorias (CRUD) no sistema UnifyTech Xenos como uma tela independente acessível pela sidebar.

## 1. Backend (Go)

### 1.1. Novos Endpoints no Router (`app-backend/internal/api/router.go`)
Registrar as rotas sob o grupo autenticado (Gerente+):
- `GET /api/categorias`: Listar todas as categorias da empresa.
- `POST /api/categorias`: Criar nova categoria.
- `PUT /api/categorias/{id}`: Atualizar categoria.
- `DELETE /api/categorias/{id}`: Inativar categoria.

### 1.2. Handler e Service
- Criar `internal/api/handlers/categoria_handler.go`.
- Criar `internal/service/categoria_service.go` (ou adicionar ao `produto_service.go`, mas o ideal é separar para escalabilidade).

## 2. Frontend (Flutter)

### 2.1. Modelos e Repository
- Definir `CriarCategoriaRequest` em `lib/domain/models/product.dart`.
- Atualizar `ProductRepository` em `lib/data/repositories/product_repository.dart` para usar os novos endpoints REST reais.

### 2.2. Provider
- Atualizar `Categories` em `lib/presentation/providers/product_provider.dart` adicionando métodos `criar`, `atualizar` e `inativar`.

### 2.3. Roteamento (`lib/main.dart`)
Adicionar a nova rota no `GoRouter`:
```dart
GoRoute(
  path: '/categorias',
  builder: (context, state) => const CategoriesScreen(),
),
```

### 2.4. Sidebar (`lib/presentation/views/shell/app_shell.dart`)
Adicionar o item de navegação no `AppShell`:
```dart
_NavItem(
  icon: Icons.category_rounded,
  label: 'Categorias',
  isActive: currentPath.startsWith('/categorias'),
  isExpanded: _isExpanded,
  onTap: () => context.go('/categorias'),
),
```
*Sugestão:* Posicionar logo abaixo de "Produtos".

### 2.5. UI - Tela de Categorias (`lib/presentation/views/products/categories_screen.dart`)
- Implementar uma tela baseada no padrão do sistema (Glass Card, DataTable).
- Diálogo de formulário para Nome e Descrição.
- Ações de Editar e Inativar.

## 3. Fluxo de Trabalho sugerido para IA
1. Implementar o serviço e handler no Go e registrar as rotas.
2. Atualizar o Repository e Provider no Flutter.
3. Criar a tela `CategoriesScreen`.
4. Registrar o rota no `main.dart` e o item no `app_shell.dart`.
5. Validar a integração (garantir que categorias criadas apareçam no dropdown de cadastro de produtos).
