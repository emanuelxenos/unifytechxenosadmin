import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/data/repositories/report_repository.dart';
import 'package:unifytechxenosadmin/presentation/providers/report_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTipoRelatorioAtivo() {
    switch (_tabController.index) {
      case 0: return 'vendas_dia';
      case 1: return 'vendas_mes';
      case 2: return 'mais_vendidos';
      case 3: return 'estoque';
      case 4: return 'financeiro';
      default: return 'vendas_mes';
    }
  }

  Future<void> _exportar(String formato) async {
    setState(() => _isExporting = true);
    try {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salvar Relatório',
        fileName: 'relatorio_${_getTipoRelatorioAtivo()}.$formato',
        type: FileType.custom,
        allowedExtensions: [formato],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.$formato')) outputFile += '.$formato';
        await ref.read(reportRepositoryProvider).exportarRelatorio(formato, outputFile, _getTipoRelatorioAtivo());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Relatório exportado em $outputFile', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Relatórios & Análises', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Visão completa do negócio e indicadores chave', style: theme.textTheme.bodyMedium),
                  ],
                ),
                Row(
                  children: [
                    if (_isExporting) const CircularProgressIndicator() else ...[
                      ElevatedButton.icon(
                        onPressed: () => _exportar('pdf'),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _exportar('xlsx'),
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Excel'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ]
                  ],
                ),
              ],
            ),
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
                  Tab(text: 'Visão de Estoque'),
                  Tab(text: 'Resumo Financeiro'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ReportSalesView(provider: salesReportDayProvider, title: 'Vendas Hoje'),
                  _ReportSalesView(provider: salesReportMonthProvider, title: 'Análise do Mês'),
                  _BestSellersView(),
                  _ReportStockView(),
                  _ReportFinanceView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSalesView extends ConsumerWidget {
  final ProviderListenable<AsyncValue<Map<String, dynamic>>> provider;
  final String title;

  const _ReportSalesView({required this.provider, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(provider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando indicadores...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro de Relatório', subtitle: '$e'),
        data: (data) {
          final double totalVendas = (data['total_vendas'] ?? 0).toDouble();
          final double valorTotal = (data['valor_total'] ?? 0).toDouble();
          final double ticketMedio = (data['ticket_medio'] ?? 0).toDouble();
          
          final List porCaixa = data['por_caixa'] ?? [];
          final List porFormaPag = data['por_forma_pagamento'] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _KPICard(title: 'Transações', value: totalVendas.toInt().toString(), icon: Icons.receipt),
                    _KPICard(title: 'Faturamento', value: Formatters.currency(valorTotal), icon: Icons.monetization_on, color: Colors.green),
                    _KPICard(title: 'Ticket Médio', value: Formatters.currency(ticketMedio), icon: Icons.analytics, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Faturamento por Caixa', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (porCaixa.isEmpty) const Text('Nenhum dado registrado.') else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: porCaixa.length,
                            itemBuilder: (context, i) {
                              final item = porCaixa[i];
                              return ListTile(
                                leading: const Icon(Icons.point_of_sale, color: AppTheme.primaryColor),
                                title: Text(item['caixa'] ?? 'Caixa'),
                                subtitle: Text('${item['total']} transações'),
                                trailing: Text(Formatters.currency((item['valor_total'] ?? 0).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Métodos de Pagamento', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (porFormaPag.isEmpty) const Text('Nenhum dado registrado.') else
                          ...porFormaPag.map((item) {
                             return ListTile(
                                leading: const Icon(Icons.payment, color: Colors.green),
                                title: Text(item['forma_pagamento'] ?? 'PAGAMENTO'),
                                subtitle: Text('${item['total']} transações'),
                                trailing: Text(Formatters.currency((item['valor_total'] ?? 0).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({required this.title, required this.value, required this.icon, this.color = AppTheme.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
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
        loading: () => const LoadingOverlay(message: 'Carregando Produtos...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(icon: Icons.bar_chart_rounded, title: 'Poucos dados na última semana');
          }

          // Gráfico de Barras para os top 5
          final topProducts = products.take(5).toList();
          List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < topProducts.length; i++) {
            barGroups.add(BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (topProducts[i]['quantidade_vendida'] as num?)?.toDouble() ?? 0,
                  color: AppTheme.primaryColor,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            ));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Produtos (Volume)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: barGroups,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              if (val.toInt() < topProducts.length) {
                                String name = topProducts[val.toInt()]['nome'] ?? '';
                                if (name.length > 10) name = '${name.substring(0, 10)}...';
                                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(name, style: const TextStyle(fontSize: 10)));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text('Detalhes do Relatório', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('PRODUTO')),
                      DataColumn(label: Text('QTD VENDIDA'), numeric: true),
                      DataColumn(label: Text('TOTAL (\$)'), numeric: true),
                    ],
                    rows: products.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(p['nome']?.toString() ?? '-')),
                        DataCell(Text(Formatters.quantity((p['quantidade_vendida'] as num?)?.toDouble() ?? 0))),
                        DataCell(Text(Formatters.currency((p['valor_total'] as num?)?.toDouble() ?? 0))),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportStockView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(stockReportProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando Estoque...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro de Relatório', subtitle: '$e'),
        data: (data) {
          final int total = data['total_produtos'] as int? ?? 0;
          final double custo = (data['valor_total_custo'] as num?)?.toDouble() ?? 0;
          final double venda = (data['valor_total_venda'] as num?)?.toDouble() ?? 0;
          final int baixos = data['produtos_baixo_estoque'] as int? ?? 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avaliação de Patrimônio', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _KPICard(title: 'Total de Itens Cadastrados', value: '$total', icon: Icons.inventory_2, color: Colors.blueGrey),
                    _KPICard(title: 'Alerta Estoque Baixo', value: '$baixos produtos', icon: Icons.warning_amber_rounded, color: Colors.orange),
                    _KPICard(title: 'Valor Estoque (Custo)', value: Formatters.currency(custo), icon: Icons.price_change, color: Colors.red),
                    _KPICard(title: 'Valor Estoque (Venda)', value: Formatters.currency(venda), icon: Icons.monetization_on, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 48),
                if (venda > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.insights, color: Colors.green),
                      const SizedBox(width: 16),
                      Expanded(child: Text('A margem de lucro bruta (estimada global) baseada no estoque atual é de aproximadamente ${(((venda - custo) / custo) * 100).toStringAsFixed(1)}%.')),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportFinanceView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(financeReportProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando Finanças...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          final double pagar = (data['valor_pagar_aberto'] as num?)?.toDouble() ?? 0;
          final double receber = (data['valor_receber_aberto'] as num?)?.toDouble() ?? 0;
          final double caixa = (data['saldo_caixa_dia'] as num?)?.toDouble() ?? 0;

          return SingleChildScrollView(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('Instantâneo Financeiro', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _KPICard(title: 'A Receber (Aberto)', value: Formatters.currency(receber), icon: Icons.arrow_circle_down, color: Colors.green),
                      _KPICard(title: 'A Pagar (Aberto)', value: Formatters.currency(pagar), icon: Icons.arrow_circle_up, color: Colors.red),
                      _KPICard(title: 'Evolução Caixa Hoje', value: Formatters.currency(caixa), icon: Icons.account_balance, color: Colors.blue),
                    ],
                  ),
               ],
            ),
          );
        },
      ),
    );
  }
}
