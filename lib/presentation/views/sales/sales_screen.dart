import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/sale_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/caixa_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});
  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  int _selectedTabIndex = 0;

  final List<_TabItem> _tabs = [
    _TabItem(
      title: 'Histórico de Vendas',
      subtitle: 'Log completo de transações',
      icon: Icons.receipt_long_rounded,
    ),
    _TabItem(
      title: 'Sessões de Caixa',
      subtitle: 'Aberturas e fechamentos',
      icon: Icons.point_of_sale_rounded,
    ),
    _TabItem(
      title: 'Sangrias & Suprimentos',
      subtitle: 'Movimentações de gaveta',
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar de Navegação
          _TabSidebar(
            tabs: _tabs,
            selectedIndex: _selectedTabIndex,
            onSelected: (index) => setState(() => _selectedTabIndex = index),
          ),
          const SizedBox(width: 24),
          // Conteúdo Ativo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_selectedTabIndex),
                  child: _buildActiveTab(theme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(ThemeData theme) {
    switch (_selectedTabIndex) {
      case 0:
        return const _VendasHistoryView();
      case 1:
        return const _CaixaSessionsView();
      case 2:
        return const _CaixaMovementsView();
      default:
        return const Center(child: Text('Em desenvolvimento'));
    }
  }
}

class _TabItem {
  final String title;
  final String subtitle;
  final IconData icon;
  _TabItem({required this.title, required this.subtitle, required this.icon});
}

class _TabSidebar extends StatelessWidget {
  final List<_TabItem> tabs;
  final int selectedIndex;
  final Function(int) onSelected;

  const _TabSidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendas & Caixa',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Gestão Operacional',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final item = tabs[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppTheme.primaryColor : null,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- VIEWS ---

class _VendasHistoryView extends ConsumerStatefulWidget {
  const _VendasHistoryView();
  @override
  ConsumerState<_VendasHistoryView> createState() => _VendasHistoryViewState();
}

class _VendasHistoryViewState extends ConsumerState<_VendasHistoryView> {
  DateTime _inicio = DateTime.now();
  DateTime _fim = DateTime.now();
  final _scrollCtrl = ScrollController();

  String get _inicioStr => _inicio.toString().split(' ')[0];
  String get _fimStr => _fim.toString().split(' ')[0];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final salesAsync = ref.watch(salesHistoryProvider(inicio: _inicioStr, fim: _fimStr));

    return Column(
      children: [
        _buildViewHeader(
          title: 'Histórico de Vendas',
          icon: Icons.receipt_long_rounded,
          actions: [
            _DateRangeButton(
              inicio: _inicio,
              fim: _fim,
              onChanged: (start, end) => setState(() {
                _inicio = start;
                _fim = end;
              }),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: () => ref.read(salesHistoryProvider(inicio: _inicioStr, fim: _fimStr).notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // KPIs locais
        salesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (vendas) {
            final concluidas = vendas.where((v) => v.status != 'cancelada').toList();
            final total = concluidas.fold(0.0, (s, v) => s + v.valorTotal);
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MiniKpi(title: 'Total Pago', value: Formatters.currency(total), color: AppTheme.accentGreen),
                _MiniKpi(title: 'Qtd Vendas', value: '${concluidas.length}', color: AppTheme.primaryColor),
                _MiniKpi(title: 'Canceladas', value: '${vendas.length - concluidas.length}', color: AppTheme.accentRed),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: salesAsync.when(
              loading: () => const LoadingOverlay(message: 'Buscando vendas...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (vendas) {
                if (vendas.isEmpty) {
                  return const EmptyState(icon: Icons.receipt_long_outlined, title: 'Nenhuma venda neste período');
                }
                return _buildSalesTable(vendas, theme);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTable(List<Venda> vendas, ThemeData theme) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollCtrl,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Nº VENDA')),
              DataColumn(label: Text('DATA/HORA')),
              DataColumn(label: Text('OPERADOR')),
              DataColumn(label: Text('CAIXA')),
              DataColumn(label: Text('VALOR'), numeric: true),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('DETALHES')),
            ],
            rows: vendas.map((v) => DataRow(
              cells: [
                DataCell(Text(v.numeroVenda, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(Formatters.dateTime(v.dataVenda))),
                DataCell(Text(v.operadorNome ?? '-')),
                DataCell(Text(v.caixaNome ?? '-')),
                DataCell(Text(Formatters.currency(v.valorTotal), style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(StatusChip.fromStatus(v.status)),
                DataCell(IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () => _showVendaDetail(context, v),
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showVendaDetail(BuildContext context, Venda venda) {
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
                _infoRow('Total', Formatters.currency(venda.valorTotal)),
                const Divider(),
                const Text('Itens', style: TextStyle(fontWeight: FontWeight.bold)),
                ...venda.itens.map((item) => ListTile(
                  title: Text(item.produtoNome ?? 'Produto'),
                  subtitle: Text('${Formatters.quantity(item.quantidade)} x ${Formatters.currency(item.precoUnitario)}'),
                  trailing: Text(Formatters.currency(item.valorLiquido)),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

class _CaixaSessionsView extends ConsumerStatefulWidget {
  const _CaixaSessionsView();
  @override
  ConsumerState<_CaixaSessionsView> createState() => _CaixaSessionsViewState();
}

class _CaixaSessionsViewState extends ConsumerState<_CaixaSessionsView> {
  DateTime _inicio = DateTime.now().subtract(const Duration(days: 7));
  DateTime _fim = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(caixaSessionsProvider(
      inicio: _inicio.toString().split(' ')[0],
      fim: _fim.toString().split(' ')[0],
    ));

    return Column(
      children: [
        _buildViewHeader(
          title: 'Histórico de Sessões',
          icon: Icons.point_of_sale_rounded,
          actions: [
            _DateRangeButton(
              inicio: _inicio,
              fim: _fim,
              onChanged: (start, end) => setState(() {
                _inicio = start;
                _fim = end;
              }),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: () => ref.read(caixaSessionsProvider(
                inicio: _inicio.toString().split(' ')[0],
                fim: _fim.toString().split(' ')[0],
              ).notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: sessionsAsync.when(
              loading: () => const LoadingOverlay(message: 'Buscando sessões...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (sessoes) {
                if (sessoes.isEmpty) {
                  return const EmptyState(icon: Icons.history_rounded, title: 'Nenhuma sessão aberta/fechada no período');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessoes.length,
                  separatorBuilder: (_, __) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final s = sessoes[index];
                    return InkWell(
                      onTap: () => _showSessionInfo(context, s),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (s.status == 'fechado' ? Colors.blueGrey : Colors.green).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                s.status == 'fechado' ? Icons.lock_outline : Icons.lock_open_rounded,
                                color: s.status == 'fechado' ? Colors.blueGrey : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sessão #${s.codigoSessao}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Abertura: ${Formatters.dateTime(s.dataAbertura)}',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.currency(s.totalVendas),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (s.status == 'fechado') ...[
                                  const StatusChip(label: 'FECHADO', color: Colors.blueGrey),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Final: ${Formatters.currency(s.saldoFinal)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                ] else
                                  const StatusChip(label: 'ABERTO', color: AppTheme.accentGreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSessionInfo(BuildContext context, SessaoCaixa s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sessão ${s.codigoSessao}'),
            StatusChip.fromStatus(s.status),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow('Saldo Inicial', Formatters.currency(s.saldoInicial)),
            _infoRow('Total Vendas', Formatters.currency(s.totalVendas)),
            _infoRow('Total Sangrias', Formatters.currency(s.totalSangrias)),
            _infoRow('Total Suprimentos', Formatters.currency(s.totalSuprimentos)),
            const Divider(),
            _infoRow('Saldo Esperado', Formatters.currency(s.saldoFinalEsperado)),
            _infoRow('Saldo Informado', Formatters.currency(s.saldoFinal)),
            _infoRow('Diferença', Formatters.currency(s.diferenca)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

class _CaixaMovementsView extends ConsumerStatefulWidget {
  const _CaixaMovementsView();
  @override
  ConsumerState<_CaixaMovementsView> createState() => _CaixaMovementsViewState();
}

class _CaixaMovementsViewState extends ConsumerState<_CaixaMovementsView> {
  DateTime _inicio = DateTime.now();
  DateTime _fim = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final movsAsync = ref.watch(caixaMovementsProvider(
      inicio: _inicio.toString().split(' ')[0],
      fim: _fim.toString().split(' ')[0],
    ));

    return Column(
      children: [
        _buildViewHeader(
          title: 'Sangrias & Suprimentos',
          icon: Icons.account_balance_wallet_rounded,
          actions: [
            _DateRangeButton(
              inicio: _inicio,
              fim: _fim,
              onChanged: (start, end) => setState(() {
                _inicio = start;
                _fim = end;
              }),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              onPressed: () => ref.read(caixaMovementsProvider(
                inicio: _inicio.toString().split(' ')[0],
                fim: _fim.toString().split(' ')[0],
              ).notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: movsAsync.when(
              loading: () => const LoadingOverlay(message: 'Buscando movimentações...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (movs) {
                if (movs.isEmpty) {
                  return const EmptyState(icon: Icons.swap_vert_rounded, title: 'Nenhuma sangria ou suprimento');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movs.length,
                  itemBuilder: (context, index) {
                    final m = movs[index];
                    final isSangria = m.tipo == 'sangria';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isSangria ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          color: isSangria ? Colors.red : Colors.green,
                        ),
                        title: Text(Formatters.currency(m.valor), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${m.tipo.toUpperCase()} - ${m.motivo ?? "Sem motivo"}'),
                        trailing: Text(Formatters.dateTime(m.dataMovimentacao), style: const TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// --- SHARED COMPONENTS ---

Widget _buildViewHeader({required String title, required IconData icon, List<Widget>? actions}) {
  return Row(
    children: [
      Icon(icon, size: 28, color: AppTheme.primaryColor),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const Spacer(),
      if (actions != null) ...actions,
    ],
  );
}

class _DateRangeButton extends StatelessWidget {
  final DateTime inicio;
  final DateTime fim;
  final Function(DateTime, DateTime) onChanged;

  const _DateRangeButton({required this.inicio, required this.fim, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final currentRange = DateTimeRange(start: inicio, end: fim);
        final dateRange = await showDateRangePicker(
          context: context,
          initialDateRange: currentRange,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppTheme.primaryColor,
                onPrimary: Colors.white,
                surface: const Color(0xFF1E2145),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (dateRange != null) {
          onChanged(dateRange.start, dateRange.end);
        }
      },
      icon: const Icon(Icons.calendar_month, size: 18),
      label: Text(
        '${Formatters.date(inicio)} - ${Formatters.date(fim)}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniKpi({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
