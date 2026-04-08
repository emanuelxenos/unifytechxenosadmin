import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/sale_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final salesAsync = ref.watch(salesTodayProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vendas', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text('Vendas do dia', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => ref.read(salesTodayProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Summary cards
            salesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (vendas) {
                final concluidas = vendas.where((v) => v.status != 'cancelada').toList();
                final total = concluidas.fold(0.0, (s, v) => s + v.valorTotal);
                return Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total do Dia',
                        value: Formatters.currency(total),
                        icon: Icons.payments_rounded,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: 'Vendas Realizadas',
                        value: '${concluidas.length}',
                        icon: Icons.shopping_cart_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiCard(
                        title: 'Canceladas',
                        value: '${vendas.length - concluidas.length}',
                        icon: Icons.cancel_outlined,
                        color: AppTheme.accentRed,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: AppTheme.glassCard(),
                clipBehavior: Clip.antiAlias,
                child: salesAsync.when(
                  loading: () => const LoadingOverlay(message: 'Carregando vendas...'),
                  error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
                  data: (vendas) {
                    if (vendas.isEmpty) {
                      return const EmptyState(icon: Icons.receipt_long_outlined, title: 'Nenhuma venda hoje');
                    }
                    return Scrollbar(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              columns: const [
                                DataColumn(label: Text('Nº VENDA')),
                                DataColumn(label: Text('HORA')),
                                DataColumn(label: Text('OPERADOR')),
                                DataColumn(label: Text('CAIXA')),
                                DataColumn(label: Text('ITENS'), numeric: true),
                                DataColumn(label: Text('VALOR'), numeric: true),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('AÇÕES')),
                              ],
                              rows: vendas.map((v) => DataRow(
                                cells: [
                                  DataCell(Text(v.numeroVenda, style: theme.textTheme.bodyLarge)),
                                  DataCell(Text(Formatters.time(v.dataVenda))),
                                  DataCell(Text(v.operadorNome ?? '-')),
                                  DataCell(Text(v.caixaNome ?? '-')),
                                  DataCell(Text('${v.itens.length}')),
                                  DataCell(Text(
                                    Formatters.currency(v.valorTotal),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: v.isCancelada ? AppTheme.accentRed : null,
                                    ),
                                  )),
                                  DataCell(StatusChip.fromStatus(v.status)),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18),
                                      onPressed: () => _showDetail(context, ref, v),
                                      tooltip: 'Detalhes',
                                    ),
                                  ),
                                ],
                              )).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref, Venda venda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                        Text(Formatters.currency(item.valorLiquido), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          if (!venda.isCancelada)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showCancelarDialog(context, ref, venda);
              },
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancelar Venda'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            ),
        ],
      ),
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

  void _showCancelarDialog(BuildContext context, WidgetRef ref, Venda venda) {
    final motivoCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Venda'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: motivoCtrl, decoration: const InputDecoration(labelText: 'Motivo *')),
              const SizedBox(height: 12),
              TextFormField(controller: senhaCtrl, decoration: const InputDecoration(labelText: 'Senha Supervisor *'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final (success, msg) = await ref.read(saleActionsProvider.notifier).cancelar(
                venda.idVenda,
                CancelarVendaRequest(motivo: motivoCtrl.text, senhaSupervisor: senhaCtrl.text),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Confirmar Cancelamento'),
          ),
        ],
      ),
    );
  }
}
