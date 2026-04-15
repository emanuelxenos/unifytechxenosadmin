# Refatoração e Melhorias: Tela de Vendas (SalesScreen)

Este documento descreve o plano de implementação para otimizar e melhorar a manutenibilidade da tela de Vendas (`sales_screen.dart`). 

## 1. Separação de Arquivos e Componentes

Para reduzir o tamanho da classe principal `SalesScreen` (atualmente com quase 300 linhas) e melhorar a organização, propomos a extração dos modais em arquivos independentes dentro de uma nova pasta `widgets` na mesma raiz do módulo de vendas.

**Estrutura de pastas proposta:**
```text
lib/
└── presentation/
    └── views/
        └── sales/
            ├── sales_screen.dart (arquivo limpo, foco no layout da tabela)
            └── widgets/
                ├── sale_detail_dialog.dart (Modal de detalhes da venda)
                └── cancel_sale_dialog.dart (Modal com validação e loading)
```

---

## 2. Implementação do `cancel_sale_dialog.dart` com UX aprimorada

A versão atual permite cliques sem validação e não mostra status de "Carregando" na chamada de rede.

**Código proposto:**

```dart
// lib/presentation/views/sales/widgets/cancel_sale_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/presentation/providers/sale_provider.dart';

class CancelSaleDialog extends ConsumerStatefulWidget {
  final Venda venda;

  const CancelSaleDialog({super.key, required this.venda});

  @override
  ConsumerState<CancelSaleDialog> createState() => _CancelSaleDialogState();
}

class _CancelSaleDialogState extends ConsumerState<CancelSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCancel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final (success, msg) = await ref.read(saleActionsProvider.notifier).cancelar(
      widget.venda.idVenda,
      CancelarVendaRequest(
        motivo: _motivoCtrl.text.trim(),
        senhaSupervisor: _senhaCtrl.text.trim(),
      ),
    );

    if (mounted) {
      Navigator.pop(context); // Fecha o dialog de cancelamento
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar Venda'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _motivoCtrl,
                decoration: const InputDecoration(labelText: 'Motivo *'),
                enabled: !_isLoading,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'O motivo é obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha Supervisor *'),
                obscureText: true,
                enabled: !_isLoading,
                validator: (value) =>
                    value == null || value.isEmpty ? 'A senha é obrigatória' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentRed,
            disabledBackgroundColor: AppTheme.accentRed.withOpacity(0.5),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text('Confirmar Cancelamento'),
        ),
      ],
    );
  }
}
```

---

## 3. Implementação do `sale_detail_dialog.dart`

Para limpar ainda mais nossa tela principal, esse widget fica inteiramente responsável por sua exibição e chama o `CancelSaleDialog` de forma encapsulada.

```dart
// lib/presentation/views/sales/widgets/sale_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'cancel_sale_dialog.dart';

class SaleDetailDialog extends StatelessWidget {
  final Venda venda;

  const SaleDetailDialog({super.key, required this.venda});

  void _showCancelarDialog(BuildContext context) {
    Navigator.pop(context); // Fecha dialog atual antes de abrir o novo
    showDialog(
      context: context,
      barrierDismissible: false, // Previne clique fora no loading
      builder: (_) => CancelSaleDialog(venda: venda),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Venda ${venda.numeroVenda}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Data', Formatters.dateTime(venda.dataVenda)),
              _infoRow('Operador', venda.operadorNome ?? '-'),
              _infoRow('Status', venda.status),
              _infoRow('Total Produtos', Formatters.currency(venda.valorTotalProdutos)),
              _infoRow('Descontos', Formatters.currency(venda.valorTotalDescontos)),
              _infoRow('Total', Formatters.currency(venda.valorTotal)),
              _infoRow('Pago', Formatters.currency(venda.valorPago)),
              _infoRow('Troco', Formatters.currency(venda.valorTroco)),
              if (venda.itens.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                Text('Itens', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...venda.itens.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.produtoNome ?? 'Produto #${item.produtoId}')),
                      Text('${Formatters.quantity(item.quantidade)} x ${Formatters.currency(item.precoUnitario)}'),
                      const SizedBox(width: 16),
                      Text(Formatters.currency(item.valorLiquido),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
        if (!venda.isCancelada)
          ElevatedButton.icon(
            onPressed: () => _showCancelarDialog(context),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancelar Venda'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8E92BC))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
```

---

## 4. Refatoração Final de `sales_screen.dart`

Agora sua tela final apenas importará o detalhe e ficará exuta e fácil de dar rotina visual:

```dart
// Após refatoração, apenas as importações necessárias
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/sale_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'widgets/sale_detail_dialog.dart'; // <--- Nova Importação

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});
  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  // O METÓDO DE DIALOG SERÁ REDUZIDO A ISSO:
  void _openSaleDetailDialog(Venda v) {
     showDialog(
      context: context,
      builder: (context) => SaleDetailDialog(venda: v),
    );
  }

  @override
  Widget build(BuildContext context) {
      // ... Seu Layout exato atual, contudo na linha de IconButton você fará:
      //
      // IconButton(
      //    icon: const Icon(Icons.visibility_outlined, size: 18),
      //    onPressed: () => _openSaleDetailDialog(v), // Usa nova função!
      //    tooltip: 'Detalhes',
      //  ),
      //
      // IMPORTANTE:
      // Pode deletar as antigas funções completas '_showDetail', '_infoRow' e '_showCancelarDialog'
      // nativamente presentes no fim de sua tela `sales_screen.dart`.
  }
}
```

## Próximos Passos (Evolução Futura)
- Na tabela (`DataTable`), converter para utilizar plugins como `data_table_2` caso seja detectado mais de 1.000 listagens de vendas simultâneas retornando pela API para evitar congelamento de UI em máquinas fracas.
- Inserir campo de [Selecionar Data Inicial e Final] logo ao lado de Atualizar para repassar para a API.
