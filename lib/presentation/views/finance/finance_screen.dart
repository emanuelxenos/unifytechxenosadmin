import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/finance_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (keep existing Text widgets)
            Text('Financeiro', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Contas a pagar, receber e fluxo de caixa', style: theme.textTheme.bodyMedium),
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
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Contas a Pagar'),
                  Tab(text: 'Contas a Receber'),
                  Tab(text: 'Fluxo de Caixa'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ContasPagarTab(controller: _pagarController),
                  _ContasReceberTab(controller: _receberController),
                  _FluxoCaixaTab(controller: _fluxoController),
                ],
              ),
            ),
          ],
        ),
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
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas a pagar');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('FORNECEDOR')),
                      DataColumn(label: Text('VENCIMENTO')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows: contas.map((c) => DataRow(cells: [
                      DataCell(Text(c.descricao)),
                      DataCell(Text(c.fornecedorNome ?? '-')),
                      DataCell(Text(
                        Formatters.date(c.dataVencimento),
                        style: TextStyle(color: c.isVencida ? AppTheme.accentRed : null),
                      )),
                      DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(StatusChip.fromStatus(c.status)),
                    ])).toList(),
                  ),
                ),
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
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas a receber');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('CLIENTE')),
                      DataColumn(label: Text('VENCIMENTO')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows: contas.map((c) => DataRow(cells: [
                      DataCell(Text(c.descricao)),
                      DataCell(Text(c.clienteNome ?? '-')),
                      DataCell(Text(
                        Formatters.date(c.dataVencimento),
                        style: TextStyle(color: c.isVencida ? AppTheme.accentRed : null),
                      )),
                      DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(StatusChip.fromStatus(c.status)),
                    ])).toList(),
                  ),
                ),
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
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'Sem movimentações');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
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
                        label: item.tipo,
                        color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                      )),
                      DataCell(Text(
                        Formatters.currency(item.valor),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                        ),
                      )),
                    ])).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
