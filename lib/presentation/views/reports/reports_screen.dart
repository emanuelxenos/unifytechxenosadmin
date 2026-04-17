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
    _tabController = TabController(length: 9, vsync: this);
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
      case 5: return 'dre';
      case 6: return 'inadimplencia';
      case 7: return 'abc';
      case 8: return 'comissoes';
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
                  Tab(text: 'DRE'),
                  Tab(text: 'Inadimplência'),
                  Tab(text: 'Curva ABC'),
                  Tab(text: 'Comissões'),
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
                  _ReportDREView(),
                  _ReportInadimplenciaView(),
                  _ReportCurvaABCView(),
                  _ReportComissoesView(),
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

class _ReportDREView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(dreReportProvider());

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Calculando DRE...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          final double bruto = (data['receita_bruta'] ?? 0).toDouble();
          final double descontos = (data['descontos'] ?? 0).toDouble();
          final double liquida = (data['receita_liquida'] ?? 0).toDouble();
          final double cmv = (data['cmv'] ?? 0).toDouble();
          final double lucroBruto = (data['lucro_bruto'] ?? 0).toDouble();
          final double despesas = (data['despesas'] ?? 0).toDouble();
          final double lucroLiquido = (data['lucro_liquido'] ?? 0).toDouble();
          final double margem = (data['margem_percentual'] ?? 0).toDouble();

          return SingleChildScrollView(
            child: Column(
              children: [
                Text('DRE Gerencial do Mês', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _DRELing(label: '(+) RECEITA BRUTA', value: bruto, color: Colors.green),
                _DRELing(label: '(-) Devoluções/Descontos', value: descontos, color: Colors.redAccent),
                _DRELing(label: '(=) RECEITA LÍQUIDA', value: liquida, isBold: true),
                const Divider(height: 32),
                _DRELing(label: '(-) CMV (Custo de Venda)', value: cmv, color: Colors.orange),
                _DRELing(label: '(=) LUCRO BRUTO', value: lucroBruto, isBold: true, color: Colors.green),
                const Divider(height: 32),
                _DRELing(label: '(-) Despesas Operacionais', value: despesas, color: Colors.red),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: (lucroLiquido >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (lucroLiquido >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      _DRELing(label: '(=) LUCRO LÍQUIDO FINAL', value: lucroLiquido, isBold: true, color: lucroLiquido >= 0 ? Colors.green : Colors.red),
                      const SizedBox(height: 8),
                      Text('Margem Líquida: ${margem.toStringAsFixed(2)}%', style: TextStyle(fontWeight: FontWeight.bold, color: lucroLiquido >= 0 ? Colors.green : Colors.red)),
                    ],
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

class _DRELing extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  const _DRELing({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(Formatters.currency(value), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _ReportInadimplenciaView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(inadimplenciaReportProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Listando Inadimplência...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          final List itens = data['itens'] ?? [];
          final double total = (data['total_vencido'] ?? 0).toDouble();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Títulos em Atraso', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total em Aberto', style: TextStyle(fontSize: 12)),
                        Text(Formatters.currency(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: itens.isEmpty 
                  ? const EmptyState(icon: Icons.check_circle_outline, title: 'Nenhum título vencido!')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: itens.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = itens[i];
                        final int dias = item['dias_atraso'] ?? 0;
                        Color statusColor = Colors.orange;
                        if (dias > 30) statusColor = Colors.red;
                        if (dias > 60) statusColor = const Color(0xff800000); // Bordô

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha: 0.2))),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: statusColor.withValues(alpha: 0.1), child: Icon(Icons.person, color: statusColor)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['cliente'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Vencido em: ${Formatters.date(item['data_vencimento'])}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Formatters.currency((item['valor'] ?? 0).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                                    child: Text('$dias dias em atraso', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCurvaABCView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(curvaABCReportProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Gerando Curva ABC...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          final List itens = data['itens'] ?? [];
          final double total = (data['total_faturamento'] ?? 0).toDouble();

          // Agrupar por classificação para o gráfico
          double faturamentoA = 0;
          double faturamentoB = 0;
          double faturamentoC = 0;

          for (var item in itens) {
            final f = (item['faturamento'] ?? 0).toDouble();
            if (item['classificacao'] == 'A') faturamentoA += f;
            else if (item['classificacao'] == 'B') faturamentoB += f;
            else faturamentoC += f;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                   children: [
                      const Icon(Icons.auto_graph, color: AppTheme.primaryColor, size: 30),
                      const SizedBox(width: 12),
                      Text('Análise Curva ABC (90 dias)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                   ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: [
                             PieChartSectionData(value: faturamentoA, title: 'A (${((faturamentoA/total)*100).toStringAsFixed(1)}%)', color: Colors.green, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                             PieChartSectionData(value: faturamentoB, title: 'B (${((faturamentoB/total)*100).toStringAsFixed(1)}%)', color: Colors.blue, radius: 45, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                             PieChartSectionData(value: faturamentoC, title: 'C (${((faturamentoC/total)*100).toStringAsFixed(1)}%)', color: Colors.orange, radius: 40, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        children: [
                           _ABCLegend(color: Colors.green, title: 'Classe A (Essenciais)', description: 'Representam ~80% do faturamento.'),
                           const SizedBox(height: 12),
                           _ABCLegend(color: Colors.blue, title: 'Classe B (Intermediários)', description: 'Representam ~15% do faturamento.'),
                           const SizedBox(height: 12),
                           _ABCLegend(color: Colors.orange, title: 'Classe C (Baixo Giro)', description: 'Representam os últimos ~5%.'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text('Top Itens por Classificação', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('PRODUTO')),
                      DataColumn(label: Text('CLASSE')),
                      DataColumn(label: Text('FATURAMENTO')),
                      DataColumn(label: Text('ACUMULADO')),
                    ],
                    rows: itens.take(20).map((item) {
                       final String classe = item['classificacao'] ?? '-';
                       Color c = Colors.grey;
                       if (classe == 'A') c = Colors.green;
                       else if (classe == 'B') c = Colors.blue;
                       else if (classe == 'C') c = Colors.orange;

                       return DataRow(cells: [
                         DataCell(Text(item['nome'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                         DataCell(Chip(label: Text(classe, style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: c, padding: EdgeInsets.zero)),
                         DataCell(Text(Formatters.currency((item['faturamento'] ?? 0).toDouble()))),
                         DataCell(Text('${(item['percentual_acumulado'] as num?)?.toStringAsFixed(1)}%')),
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

class _ABCLegend extends StatelessWidget {
  final Color color;
  final String title;
  final String description;

  const _ABCLegend({required this.color, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportComissoesView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(comissoesReportProvider());

    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(24),
      child: dataAsync.when(
        loading: () => const LoadingOverlay(message: 'Calculando Comissões...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (data) {
          final List operadores = data['operadores'] ?? [];
          final double totalGeral = (data['total_geral'] ?? 0).toDouble();
          final double totalComissao = (data['total_comissao'] ?? 0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _KPICard(title: 'Faturamento Total', value: Formatters.currency(totalGeral), icon: Icons.payments, color: AppTheme.primaryColor),
                  _KPICard(title: 'Comissões Presumidas (1%)', value: Formatters.currency(totalComissao), icon: Icons.card_giftcard, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 48),
              Text('Performance por Operador', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: operadores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final op = operadores[i];
                    return ListTile(
                      leading: CircleAvatar(
                         backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                         child: Text(op['nome']?[0] ?? '?', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      ),
                      title: Text(op['nome'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${op['total_vendas']} vendas | Ticket Médio: ${Formatters.currency((op['ticket_medio'] ?? 0).toDouble())}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Formatters.currency((op['comissao'] ?? 0).toDouble()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                          const Text('Comissão', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
