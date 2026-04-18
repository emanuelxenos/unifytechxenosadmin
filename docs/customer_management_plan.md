# Plano de Implementação: Gestão de Clientes

Este documento detalha o passo a passo para implementar o módulo de Cadastro e Gestão de Clientes no frontend Flutter da UnifyTech Xenos Admin.

## Contexto
O sistema já possui infraestrutura de backend (Handlers, Services, Tabelas SQL e Rotas) para clientes, mas o frontend carece das telas e da lógica de integração. Este módulo é essencial para o funcionamento correto do relatório de **Inadimplência** e para o fluxo de **Contas a Receber (Crediário)**.

---

## 1. Passo: Criação do Modelo de Dados
Criar o arquivo `app-admin\lib\domain\models\customer.dart` baseado no modelo existente no backend.

```dart
class Cliente {
  final int idCliente;
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final double limiteCredito;
  final double saldoDevedor;
  final bool ativo;

  Cliente({
    required this.idCliente,
    required this.nome,
    required this.tipoPessoa,
    this.cpfCnpj,
    this.telefone,
    this.email,
    required this.limiteCredito,
    required this.saldoDevedor,
    this.ativo = true,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    idCliente: json['id_cliente'],
    nome: json['nome'],
    tipoPessoa: json['tipo_pessoa'],
    cpfCnpj: json['cpf_cnpj'],
    telefone: json['telefone'],
    email: json['email'],
    limiteCredito: (json['limite_credito'] as num).toDouble(),
    saldoDevedor: (json['saldo_devedor'] as num).toDouble(),
    ativo: json['ativo'] ?? true,
  );
}

class CriarClienteRequest {
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final double limiteCredito;

  CriarClienteRequest({
    required this.nome,
    required this.tipoPessoa,
    this.cpfCnpj,
    this.telefone,
    this.email,
    required this.limiteCredito,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'tipo_pessoa': tipoPessoa,
    'cpf_cnpj': cpfCnpj,
    'telefone': telefone,
    'email': email,
    'limite_credito': limiteCredito,
  };
}
```

## 2. Passo: Implementação do Repositório
Utilizar o `SupplierRepository` como template para criar `app-admin\lib\data\repositories\customer_repository.dart`.

*   **Endpoints:** `ApiEndpoints.clientes` (adicionar no arquivo de constantes se faltar).
*   **Métodos:** `listar`, `criar`, `atualizar`.

## 3. Passo: Lógica de Estado (Provider)
Criar `app-admin\lib\presentation\providers\customer_provider.dart` usando `riverpod_generator`.

*   Implementar um `AsyncNotifier` para a lista de clientes.
*   Suportar filtragem local ou remota por nome/documento.

## 4. Passo: Interface (Visão)
Criar uma nova tela `app-admin\lib\presentation\views\customers\customers_screen.dart`.

*   **Layout:** Seguir o padrão de `ProductsScreen` (tabela de dados + busca no topo).
*   **Botão Novo:** Abrir dialog `CustomerFormDialog`.
*   **Ações:** Editar cliente e ver resumo financeiro (Saldo Devedor).

## 5. Passo: Integração e Navegação
Integrar a nova tela no sistema de navegação central.

### A. Rotas (GoRouter)
No arquivo `app-admin\lib\main.dart`, adicionar a nova rota:
```dart
GoRoute(
  path: '/clientes',
  builder: (context, state) => const CustomersScreen(),
),
```

### B. Menu Lateral (Sidebar)
No arquivo `app-admin\lib\presentation\views\shell\app_shell.dart`, adicionar o item no método do menu:
```dart
_NavItem(
  icon: Icons.people_alt_rounded,
  label: 'Clientes',
  isActive: currentPath.startsWith('/clientes'),
  isExpanded: _isExpanded,
  onTap: () => context.go('/clientes'),
),
```

---

## Observações de Segurança e UX
*   **Controle de Acesso:** Clientes devem estar visíveis para perfis `caixa`, `gerente` e `admin`, mas o ajuste de `limite_credito` deve ser restrito a `gerente` e `admin`.
*   **Inadimplência:** Na ficha do cliente, seria ideal um atalho para ver as "Contas a Receber" pendentes filtradas por aquele ID.

---
> [!IMPORTANT]
> Lembre-se de rodar `dart run build_runner build -d` após criar os arquivos de repositório e provider para gerar o código boilerplate.
