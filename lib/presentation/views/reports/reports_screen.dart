import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/report_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relatórios', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Análises e indicadores do negócio', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Vendas do Dia'),
                  Tab(text: 'Vendas do Mês'),
                  Tab(text: 'Mais Vendidos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ReportDataView(provider: salesReportDayProvider, title: 'Vendas do Dia'),
                  _ReportDataView(provider: salesReportMonthProvider, title: 'Vendas do Mês'),
                  _BestSellersView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportDataView extends ConsumerWidget {
  final ProviderListenable<AsyncValue<Map<String, dynamic>>> provider;
  final String title;

  const _ReportDataView({required this.provider, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(provider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando relatório...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                ...data.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: theme.textTheme.bodyMedium),
                      Text(
                        e.value is num ? Formatters.currency((e.value as num).toDouble()) : '${e.value}',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BestSellersView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(bestSellersProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(icon: Icons.bar_chart_rounded, title: 'Sem dados');
          }
          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('PRODUTO')),
                  DataColumn(label: Text('QTD VENDIDA'), numeric: true),
                  DataColumn(label: Text('TOTAL'), numeric: true),
                ],
                rows: products.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return DataRow(cells: [
                    DataCell(Container(
                      width: 28, height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < 3 ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${i + 1}', style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: i < 3 ? AppTheme.primaryColor : theme.colorScheme.onSurfaceVariant,
                      )),
                    )),
                    DataCell(Text(p['nome']?.toString() ?? '-')),
                    DataCell(Text(Formatters.quantity((p['quantidade_vendida'] as num?)?.toDouble() ?? 0))),
                    DataCell(Text(
                      Formatters.currency((p['total_vendido'] as num?)?.toDouble() ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
