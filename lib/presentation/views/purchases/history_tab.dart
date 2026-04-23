import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/purchase_provider.dart';
import 'package:unifytechxenosadmin/data/repositories/purchase_repository.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/widgets/purchase_detail_dialog.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/widgets/receive_purchase_dialog.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final purchasesAsync = ref.watch(purchasesProvider);
    final filters = ref.watch(purchaseFilterStateProvider);

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Search NF
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (v) => ref.read(purchaseFilterStateProvider.notifier).setNotaFiscal(v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nota fiscal...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Status Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String?>(
                  value: filters.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos os Status')),
                    ...['pendente', 'recebida', 'cancelada'].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(Formatters.statusCompra(s)),
                    )),
                  ],
                  onChanged: (v) => ref.read(purchaseFilterStateProvider.notifier).setStatus(v),
                ),
              ),
              const SizedBox(width: 12),
              // Date Range
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: filters.dataInicio != null && filters.dataFim != null
                      ? DateTimeRange(start: filters.dataInicio!, end: filters.dataFim!)
                      : null,
                    builder: (context, child) => Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  ref.read(purchaseFilterStateProvider.notifier).setRange(range);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(
                  filters.dataInicio == null 
                    ? 'Período' 
                    : '${Formatters.date(filters.dataInicio)} - ${Formatters.date(filters.dataFim)}'
                ),
              ),
              const SizedBox(width: 8),
              if (filters.status != null || filters.notaFiscal != null || filters.dataInicio != null)
                IconButton(
                  onPressed: () => ref.read(purchaseFilterStateProvider.notifier).clear(),
                  icon: const Icon(Icons.filter_list_off_rounded, color: AppTheme.accentRed),
                  tooltip: 'Limpar filtros',
                ),
            ],
          ),
        ),
        // List
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: purchasesAsync.when(
              loading: () => const LoadingOverlay(message: 'Carregando compras...'),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Erro ao carregar compras',
                subtitle: e.toString(),
                action: ElevatedButton(
                  onPressed: () => ref.refresh(purchasesProvider),
                  child: const Text('Tentar novamente'),
                ),
              ),
              data: (purchases) {
                if (purchases.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Nenhuma compra encontrada',
                    subtitle: 'Ajuste os filtros ou registre novas compras.',
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
                                tooltip: 'Ver Detalhes',
                                onPressed: () => _showDetails(context, c),
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
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, Compra compra) {
    showDialog(
      context: context,
      builder: (context) => PurchaseDetailDialog(compraId: compra.idCompra),
    );
  }

  Future<void> _confirmReceive(BuildContext context, WidgetRef ref, Compra compra) async {
    try {
      // 1. Carregar detalhes completos da compra (garantir que itens existam)
      final fullCompra = await ref.read(purchaseRepositoryProvider).buscarPorID(compra.idCompra);
      
      if (!context.mounted) return;

      // 2. Abrir diálogo com a compra completa
      final request = await showDialog<ReceberCompraRequest>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ReceivePurchaseDialog(compra: fullCompra),
      );

      if (request != null) {
        final (success, message) = await ref.read(purchaseActionsProvider.notifier).receber(compra.idCompra, request);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens da compra: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }
}
