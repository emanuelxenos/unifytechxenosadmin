# Plano de Implementação: Finalização do ERP UnifyTech Xenos

Este documento detalha o roteiro para completar as funcionalidades do sistema e alinhar a arquitetura com os padrões corporativos desejados.

---

## 📅 Fase 1: Módulo de Compras (Gestão de Suprimentos)
Este é o núcleo funcional que falta para fechar o ciclo de vida do produto no ERP.

### 1.1 Gestão de Fornecedores
- **View**: Criar `lib/presentation/views/purchases/suppliers_tab.dart`.
- **Funcionalidade**: Listagem (DataTable) e Formulário de cadastro de fornecedores.
- **Integração**: Conectar com `supplierRepository`.

### 1.2 Registro de Compras (Carrinho de Compra)
- **Componente**: Criar `lib/presentation/views/purchases/widgets/purchase_form_dialog.dart`.
- **Lógica**: Permitir selecionar um fornecedor e adicionar múltiplos produtos com quantidade e preço de custo atualizado.
- **Ação**: Ao finalizar, chamar `purchaseRepository.criar` e disparar atualização de estoque.

### 1.3 Recebimento e Histórico
- **View**: Atualizar `PurchasesScreen` para exibir a lista de compras realizadas.
- **Status**: Controle de status (Pendente -> Recebido).

---

## 📊 Fase 2: Relatórios e Exportação (PDF/Excel)
Dar utilidade aos dados permitindo que o gestor extraia informações do sistema.

### 2.1 Infraestrutura de Exportação
- **Lib**: Adicionar `pdf` e `excel` ao `pubspec.yaml`.
- **Serviço**: Criar `lib/services/export_service.dart`.
- **Métodos**: `generateSalesPdf()`, `exportStockToExcel()`.

### 2.2 Relatórios de Lucratividade
- **Lógica**: Criar provider que calcula Lucro = Preço Venda - Preço Custo.
- **Visual**: Adicionar gráficos de margem na aba de Relatórios.

---

## 🔐 Fase 3: Segurança e Configurações (RBAC)
Transformar a aplicação em um sistema multi-usuário seguro.

### 3.1 Gestão de Usuários
- **View**: Finalizar a aba de "Usuários" em `SettingsScreen`.
- **Permissões**: Implementar o mapeamento do `core/constants/permissions.dart` na UI (Esconder botões se o usuário não tiver permissão).

### 3.2 Backup do Sistema
- **Serviço**: Criar `lib/services/backup_service.dart`.
- **Funcionalidade**: Botão para exportar o dump do banco de dados (via API) ou localmente.

---

## 🛠️ Checklist de Dependências para IA Futura
- [ ] Rodar `dart run build_runner build` após qualquer mudança em repositórios/providers.
- [ ] Verificar se o backend (Go) tem os endpoints `/api/compras` e `/api/fornecedores` ativos.
- [ ] Usar `AppTheme.glassCard()` para manter a estética visual.

> [!TIP]
> **Prioridade Recomendada:** Começar pela **Fase 1 (Compras)**, pois ela gera o maior valor imediato para o usuário final, permitindo o controle real do estoque.
