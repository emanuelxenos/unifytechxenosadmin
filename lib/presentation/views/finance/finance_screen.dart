import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/finance_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/domain/models/account_payable.dart';
import 'package:unifytechxenosadmin/domain/models/account_receivable.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});
  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pagarController = ScrollController();
  final _receberController = ScrollController();
  final _fluxoController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pagarController.dispose();
    _receberController.dispose();
    _fluxoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fluxoAsync = ref.watch(cashFlowProvider);
    final filters = ref.watch(financialFiltersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, theme, filters),
                  const SizedBox(height: 24),
                  fluxoAsync.when(
                    loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (resp) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _KpiCard(
                              title: 'Entradas Totais',
                              value: resp.totalEntrada,
                              icon: Icons.trending_up,
                              color: AppTheme.accentGreen,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _KpiCard(
                              title: 'Saídas Totais',
                              value: resp.totalSaida,
                              icon: Icons.trending_down,
                              color: AppTheme.accentRed,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _KpiCard(
                              title: 'Saldo no Período',
                              value: resp.saldo,
                              icon: Icons.account_balance_wallet,
                              color: AppTheme.primaryColor,
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildChartCard(resp),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF0D1117).withOpacity(0.8), // Fundo para a aba fixada
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Contas a Pagar'),
                        Tab(text: 'Contas a Receber'),
                        Tab(text: 'Extrato de Fluxo'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TabBarView(
              controller: _tabController,
              children: [
                _ContasPagarTab(controller: _pagarController),
                _ContasReceberTab(controller: _receberController),
                _FluxoCaixaTab(controller: _fluxoController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ThemeData theme, ({DateTime? start, DateTime? end}) filters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestão Financeira 360º', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Gestão administrativa completa: automático + manual', style: theme.textTheme.bodyMedium),
          ],
        ),
        Row(
          children: [
            _DateFilterButton(filters: filters),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showManualEntryDialog(context, isPagar: true),
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Nova Despesa'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showManualEntryDialog(context, isPagar: false),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nova Entrada'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () {
                ref.read(cashFlowProvider.notifier).refresh();
                ref.read(accountsPayableProvider.notifier).refresh();
                ref.read(accountsReceivableProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar Dados',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(FluxoCaixaResponse resp) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tendência de Caixa', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: resp.items.isEmpty 
              ? const Center(child: Text('Sem dados suficientes para o gráfico', style: TextStyle(color: Colors.white54)))
              : _FinanceLineChart(items: resp.items),
          ),
        ],
      ),
    );
  }


  void _showManualEntryDialog(BuildContext context, {required bool isPagar}) {
    showDialog(
      context: context,
      builder: (_) => _ManualEntryDialog(isPagar: isPagar),
    );
  }
}

class _FinanceLineChart extends StatelessWidget {
  final List<FluxoCaixaItem> items;
  const _FinanceLineChart({required this.items});

  @override
  Widget build(BuildContext context) {
    // Agrupar por data para o gráfico
    final Map<String, double> dataPoints = {};
    for (var item in items) {
      final key = item.data.toString().split(' ')[0];
      dataPoints[key] = (dataPoints[key] ?? 0) + item.valor;
    }

    final sortedKeys = dataPoints.keys.toList()..sort();
    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPoints[sortedKeys[i]]!));
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xFF1C2039),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  Formatters.currency(barSpot.y),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= 0 && val.toInt() < sortedKeys.length) {
                  final date = DateTime.parse(sortedKeys[val.toInt()]);
                  return Text('${date.day}/${date.month}', style: const TextStyle(color: Colors.white54, fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends ConsumerWidget {
  final ({DateTime? start, DateTime? end}) filters;
  const _DateFilterButton({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = filters.start == null 
      ? 'Filtrar por Período' 
      : '${Formatters.date(filters.start!)} - ${Formatters.date(filters.end!)}';

    return OutlinedButton.icon(
      onPressed: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: filters.start != null 
            ? DateTimeRange(start: filters.start!, end: filters.end!)
            : null,
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppTheme.primaryColor,
                surface: const Color(0xFF1C2039),
              ),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          ref.read(financialFiltersProvider.notifier).setRange(range.start, range.end);
        }
      },
      icon: const Icon(Icons.date_range_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.currency(value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContasPagarTab extends ConsumerWidget {
  final ScrollController controller;
  const _ContasPagarTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contasAsync = ref.watch(accountsPayableProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: contasAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (contas) {
          if (contas.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas no período');
          }
          return Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('DESCRIÇÃO')),
                  DataColumn(label: Text('CATEGORIA')),
                  DataColumn(label: Text('VENCIMENTO')),
                  DataColumn(label: Text('VALOR'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('AÇÕES')),
                ],
                rows: contas.map((c) {
                  final user = ref.watch(authProvider).user;
                  final bool canManage = user?.perfil == 'admin' || user?.perfil == 'gerente';
                  
                  return DataRow(cells: [
                    DataCell(Text(c.descricao)),
                    DataCell(StatusChip(
                      label: c.categoria.toUpperCase(),
                      color: c.categoria == 'fornecedor' ? Colors.blue : Colors.purple,
                    )),
                    DataCell(Text(
                      Formatters.date(c.dataVencimento),
                      style: TextStyle(color: c.isVencida ? AppTheme.accentRed : null),
                    )),
                    DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(StatusChip.fromStatus(c.status)),
                    DataCell(
                      IconButton(
                        icon: Icon(
                          Icons.payments_outlined, 
                          color: (c.status == 'aberta' && canManage) ? AppTheme.primaryColor : Colors.grey.withOpacity(0.5)
                        ),
                        onPressed: (c.status == 'aberta' && canManage)
                            ? () => showDialog(context: context, builder: (_) => _PaymentDialog(conta: c))
                            : null,
                      ),
                    ),
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

class _ContasReceberTab extends ConsumerWidget {
  final ScrollController controller;
  const _ContasReceberTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contasAsync = ref.watch(accountsReceivableProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: contasAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (contas) {
          if (contas.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas no período');
          }
          return Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('DESCRIÇÃO')),
                  DataColumn(label: Text('CATEGORIA')),
                  DataColumn(label: Text('VENCIMENTO')),
                  DataColumn(label: Text('VALOR'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('AÇÕES')),
                ],
                rows: contas.map((c) {
                  final user = ref.watch(authProvider).user;
                  final bool canManage = user?.perfil == 'admin' || user?.perfil == 'gerente';

                  return DataRow(cells: [
                    DataCell(Text(c.descricao)),
                    DataCell(StatusChip(
                      label: c.categoria.toUpperCase(),
                      color: c.categoria == 'venda' ? Colors.green : Colors.amber,
                    )),
                    DataCell(Text(
                      Formatters.date(c.dataVencimento),
                      style: TextStyle(color: c.isVencida ? AppTheme.accentRed : null),
                    )),
                    DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(StatusChip.fromStatus(c.status)),
                    DataCell(
                      IconButton(
                        icon: Icon(
                          Icons.price_check, 
                          color: (c.status == 'aberta' && canManage) ? AppTheme.accentGreen : Colors.grey.withOpacity(0.5)
                        ),
                        onPressed: (c.status == 'aberta' && canManage)
                            ? () => showDialog(context: context, builder: (_) => _ReceiptDialog(conta: c))
                            : null,
                      ),
                    ),
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

class _FluxoCaixaTab extends ConsumerWidget {
  final ScrollController controller;
  const _FluxoCaixaTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fluxoAsync = ref.watch(cashFlowProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: fluxoAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (resp) {
          final items = resp.items;
          if (items.isEmpty) {
            return const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'Sem movimentações no período');
          }
          return Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('DATA')),
                  DataColumn(label: Text('TIPO')),
                  DataColumn(label: Text('VALOR'), numeric: true),
                ],
                rows: items.map((item) => DataRow(cells: [
                  DataCell(Text(Formatters.date(item.data))),
                  DataCell(StatusChip(
                    label: item.tipo.toUpperCase(),
                    color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                  )),
                  DataCell(Text(
                    Formatters.currency(item.valor),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                    ),
                  )),
                ])).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ManualEntryDialog extends ConsumerStatefulWidget {
  final bool isPagar;
  const _ManualEntryDialog({required this.isPagar});

  @override
  ConsumerState<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends ConsumerState<_ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  String _categoria = 'Administrativo';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dataCtrl.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: Text(widget.isPagar ? 'Nova Despesa Manual' : 'Nova Entrada Manual', style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição (Ex: Aluguel, Luz, etc)'),
                style: const TextStyle(color: Colors.white),
                validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorCtrl,
                      decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: r'R$ '),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      dropdownColor: const Color(0xFF1C2039),
                      items: ['Administrativo', 'Infraestrutura', 'Pessoal', 'Marketing', 'Outros']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (v) => setState(() => _categoria = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataCtrl,
                decoration: const InputDecoration(labelText: 'Data de Vencimento', suffixIcon: Icon(Icons.calendar_today, size: 18)),
                style: const TextStyle(color: Colors.white),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) _dataCtrl.text = date.toString().split(' ')[0];
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: widget.isPagar ? AppTheme.accentRed : AppTheme.accentGreen),
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final valor = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0;
    bool ok;

    if (widget.isPagar) {
      ok = await ref.read(accountsPayableProvider.notifier).criar(CriarContaPagarRequest(
        descricao: _descricaoCtrl.text,
        valorOriginal: valor,
        dataVencimento: _dataCtrl.text,
        categoria: _categoria,
      ));
    } else {
      ok = await ref.read(accountsReceivableProvider.notifier).criar(CriarContaReceberRequest(
        descricao: _descricaoCtrl.text,
        valorOriginal: valor,
        dataVencimento: _dataCtrl.text,
        categoria: _categoria,
      ));
    }

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.pop(context);
        AppNotifications.showSuccess(context, 'Lançamento registrado com sucesso');
      } else {
        AppNotifications.showError(context, 'Erro ao salvar lançamento');
      }
    }
  }
}

class _PaymentDialog extends StatefulWidget {
  final ContaPagar conta;
  const _PaymentDialog({required this.conta});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valorController.text = widget.conta.valorOriginal.toStringAsFixed(2);
    _dataController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: const Text('Confirmar Pagamento', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deseja registrar o pagamento de: ${widget.conta.descricao}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: r'Valor Pago (R$)', prefixText: r'R$ '),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data do Pagamento', suffixIcon: Icon(Icons.calendar_today)),
            style: const TextStyle(color: Colors.white),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) _dataController.text = date.toString().split(' ')[0];
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
        Consumer(builder: (context, ref, _) {
          return ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
              final ok = await ref.read(accountsPayableProvider.notifier).pagar(widget.conta.idContaPagar, PagarContaRequest(valorPago: valor, dataPagamento: _dataController.text));
              if (mounted && ok) {
                ref.read(cashFlowProvider.notifier).refresh();
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmar'),
          );
        }),
      ],
    );
  }
}

class _ReceiptDialog extends StatefulWidget {
  final ContaReceber conta;
  const _ReceiptDialog({required this.conta});

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valorController.text = widget.conta.valorOriginal.toStringAsFixed(2);
    _dataController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: const Text('Confirmar Recebimento', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Deseja registrar o recebimento de: ${widget.conta.descricao}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: r'Valor Recebido (R$)', prefixText: r'R$ '),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data do Recebimento', suffixIcon: Icon(Icons.calendar_today)),
            style: const TextStyle(color: Colors.white),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) _dataController.text = date.toString().split(' ')[0];
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
        Consumer(builder: (context, ref, _) {
          return ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
              final ok = await ref.read(accountsReceivableProvider.notifier).receber(widget.conta.idContaReceber, ReceberContaRequest(valorRecebido: valor, dataRecebimento: _dataController.text));
              if (mounted && ok) {
                ref.read(cashFlowProvider.notifier).refresh();
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmar'),
          );
        }),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final Widget _tabBar;

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => _tabBar;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
