import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/supplier_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/purchase_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/supplier.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';

class SupplierAnalyticsTab extends ConsumerStatefulWidget {
  const SupplierAnalyticsTab({super.key});

  @override
  ConsumerState<SupplierAnalyticsTab> createState() => _SupplierAnalyticsTabState();
}

class _SupplierAnalyticsTabState extends ConsumerState<SupplierAnalyticsTab> {
  int? _selectedSupplierId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suppliersAsync = ref.watch(suppliersProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCard(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecionar Fornecedor',
                        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      suppliersAsync.when(
                        data: (suppliers) => SearchAnchor(
                          builder: (context, controller) {
                            final selectedSupplier = suppliers.any((s) => s.idFornecedor == _selectedSupplierId)
                                ? suppliers.firstWhere((s) => s.idFornecedor == _selectedSupplierId)
                                : null;

                            return SearchBar(
                              controller: controller,
                              hintText: selectedSupplier?.razaoSocial ?? 'Pesquisar fornecedor...',
                              padding: const WidgetStatePropertyAll<EdgeInsets>(
                                EdgeInsets.symmetric(horizontal: 16.0),
                              ),
                              onTap: () => controller.openView(),
                              onChanged: (_) => controller.openView(),
                              leading: const Icon(Icons.search),
                              trailing: selectedSupplier != null ? [
                                IconButton(
                                  onPressed: () => setState(() => _selectedSupplierId = null),
                                  icon: const Icon(Icons.clear),
                                ),
                              ] : null,
                            );
                          },
                          suggestionsBuilder: (context, controller) {
                            final query = controller.text.toLowerCase();
                            final filtered = suppliers.where((s) =>
                                s.razaoSocial.toLowerCase().contains(query) ||
                                (s.cnpj?.contains(query) ?? false)).toList();

                            return filtered.map((s) => ListTile(
                                  title: Text(s.razaoSocial),
                                  subtitle: Text(s.cnpj ?? 'Sem CNPJ'),
                                  onTap: () {
                                    setState(() {
                                      _selectedSupplierId = s.idFornecedor;
                                      controller.closeView(s.razaoSocial);
                                    });
                                  },
                                ));
                          },
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Erro ao carregar fornecedores: $e'),
                      ),
                    ],
                  ),
                ),
                // REMOVED: redundant close button since search bar has it
              ],
            ),
          ),
        ),

        // Results
        if (_selectedSupplierId == null)
          const Expanded(
            child: EmptyState(
              icon: Icons.analytics_outlined,
              title: 'Análise de Fornecedor',
              subtitle: 'Selecione um fornecedor acima para visualizar o histórico de compras e indicadores.',
            ),
          )
        else
          Expanded(
            child: _buildSupplierData(context, ref, _selectedSupplierId!),
          ),
      ],
    );
  }

  Widget _buildSupplierData(BuildContext context, WidgetRef ref, int supplierId) {
    final historyAsync = ref.watch(supplierHistoryProvider(supplierId));

    return historyAsync.when(
      loading: () => const LoadingOverlay(message: 'Carregando histórico...'),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Erro ao carregar dados',
        subtitle: e.toString(),
        action: ElevatedButton(
          onPressed: () => ref.invalidate(supplierHistoryProvider(supplierId)),
          child: const Text('Tentar novamente'),
        ),
      ),
      data: (purchases) {
        if (purchases.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'Nenhuma compra encontrada',
            subtitle: 'Este fornecedor ainda não possui registros de compras no sistema.',
          );
        }

        // Calculate stats
        final totalValue = purchases.fold(0.0, (sum, c) => sum + c.valorTotal);
        final lastPurchase = purchases.first; // Already sorted by date DESC in backend

        return Column(
          children: [
            // KPI Bar
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total em Compras',
                    value: Formatters.currency(totalValue),
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiCard(
                    title: 'Qtd. de Compras',
                    value: purchases.length.toString(),
                    icon: Icons.shopping_bag_outlined,
                    color: AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiCard(
                    title: 'Última Compra',
                    value: Formatters.date(lastPurchase.dataEntrada),
                    subtitle: 'NF: ${lastPurchase.numeroNotaFiscal ?? '-'}',
                    icon: Icons.event_note_outlined,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // History Table
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: AppTheme.glassCard(),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: DataTable(
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text('DATA')),
                      DataColumn(label: Text('NF')),
                      DataColumn(label: Text('PRODUTOS'), numeric: true),
                      DataColumn(label: Text('VALOR TOTAL'), numeric: true),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows: purchases.map((c) => DataRow(
                      cells: [
                        DataCell(Text(Formatters.date(c.dataEntrada))),
                        DataCell(Text(c.numeroNotaFiscal ?? '-')),
                        DataCell(Text(Formatters.currency(c.valorProdutos))),
                        DataCell(Text(
                          Formatters.currency(c.valorTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(StatusChip.fromStatus(c.status)),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
