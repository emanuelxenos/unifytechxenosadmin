import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/purchase_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/suppliers_tab.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/widgets/purchase_form_dialog.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final purchasesAsync = ref.watch(purchasesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compras', style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text('Gestão de suprimentos e fornecedores', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewPurchaseForm(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nova Compra'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tabs
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.primaryColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'HISTÓRICO DE COMPRAS'),
                  Tab(text: 'FORNECEDORES'),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: TabBarView(
                  children: [
                    // Purchases List Tab
                    _buildPurchasesList(context, ref, purchasesAsync),
                    // Suppliers Tab
                    const SuppliersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasesList(BuildContext context, WidgetRef ref, AsyncValue<List<Compra>> purchasesAsync) {
    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: purchasesAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando compras...'),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Erro ao carregar compras',
          subtitle: e.toString(),
          action: ElevatedButton(
            onPressed: () => ref.read(purchasesProvider.notifier).refresh(),
            child: const Text('Tentar novamente'),
          ),
        ),
        data: (purchases) {
          if (purchases.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nenhuma compra registrada',
              subtitle: 'As compras registradas aparecerão aqui.',
              action: ElevatedButton.icon(
                onPressed: () => _showNewPurchaseForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Registrar Primeira Compra'),
              ),
            );
          }
          return SingleChildScrollView(
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('DATA')),
                DataColumn(label: Text('NF')),
                DataColumn(label: Text('FORNECEDOR')),
                DataColumn(label: Text('VALOR TOTAL'), numeric: true),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('AÇÕES')),
              ],
              rows: purchases.map((c) => DataRow(
                cells: [
                  DataCell(Text(Formatters.date(c.dataEntrada))),
                  DataCell(Text(c.numeroNotaFiscal ?? '-')),
                  DataCell(Text(c.fornecedorNome ?? 'Não informado')),
                  DataCell(Text(Formatters.currency(c.valorTotal), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(StatusChip.fromStatus(c.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.status == 'pendente')
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: AppTheme.accentGreen),
                            tooltip: 'Marcar como Recebida',
                            onPressed: () => _confirmReceive(context, ref, c),
                          ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          onPressed: () {}, // Detalhes da compra
                        ),
                      ],
                    ),
                  ),
                ],
              )).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showNewPurchaseForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PurchaseFormDialog(),
    );
  }

  Future<void> _confirmReceive(BuildContext context, WidgetRef ref, Compra compra) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receber Mercadoria'),
        content: Text('Deseja marcar a compra NF ${compra.numeroNotaFiscal} como recebida?\nIsso atualizará o estoque dos produtos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar Recebimento')),
        ],
      ),
    );

    if (confirmed == true) {
      // Para simplificar, estamos recebendo a quantidade total comprada
      final request = ReceberCompraRequest(
        itensRecebidos: compra.itens.map((i) => ItemRecebidoRequest(
          produtoId: i.produtoId,
          quantidadeRecebida: i.quantidade,
        )).toList(),
      );
      
      final (success, message) = await ref.read(purchaseActionsProvider.notifier).receber(compra.idCompra, request);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed),
        );
      }
    }
  }
}
