import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/presentation/providers/report_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';
import 'package:unifytechxenosadmin/presentation/views/stock/inventory_counting_screen.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});
  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();
  final _horizontalController = ScrollController();
  String _searchQuery = '';
  bool _onlyLowStock = false;
  
  // Filtros de Inventário
  DateTime? _invInicio;
  DateTime? _invFim;
  bool _filterToday = false;

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildTabBar(),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPosicaoTab(theme),
                    _buildHistoricoTab(theme),
                    _buildInventariosTab(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estoque', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('Controle de estoque e inventário', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAjusteDialog(context, ref),
          icon: const Icon(Icons.swap_vert_rounded, size: 18),
          label: const Text('Ajustar Estoque'),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppTheme.primaryColor,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppTheme.primaryColor,
      tabs: const [
        Tab(text: 'POSIÇÃO ATUAL'),
        Tab(text: 'HISTÓRICO'),
        Tab(text: 'INVENTÁRIOS'),
      ],
    );
  }

  Widget _buildPosicaoTab(ThemeData theme) {
    final productsAsync = ref.watch(productsProvider);
    final reportAsync = ref.watch(stockReportProvider);

    return Column(
      children: [
        // KPI Cards
        reportAsync.when(
          data: (data) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StockKpiCard(
                  title: 'Total de Itens',
                  value: data['total_produtos']?.toString() ?? '0',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                _StockKpiCard(
                  title: 'Estoque Baixo',
                  value: data['produtos_baixo_estoque']?.toString() ?? '0',
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.accentOrange,
                ),
                _StockKpiCard(
                  title: 'Valor (Custo)',
                  value: Formatters.currency(data['valor_total_custo']?.toDouble() ?? 0),
                  icon: Icons.attach_money_rounded,
                  color: AppTheme.accentGreen,
                ),
              ],
            ),
          ),
          loading: () => const SizedBox(height: 100, child: LoadingOverlay()),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Search & Filters
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: AppTheme.glassCard(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Buscar produto...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilterChip(
              label: const Text('Apenas estoque baixo'),
              selected: _onlyLowStock,
              onSelected: (v) => setState(() => _onlyLowStock = v),
              selectedColor: AppTheme.accentOrange.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentOrange,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: productsAsync.response.when(
              loading: () => const LoadingOverlay(message: 'Carregando estoque...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (paginated) {
                final products = paginated.data;
                final filtered = products.where((p) {
                  if (!p.controlarEstoque) return false;
                  if (_onlyLowStock && !p.estoqueBaixo) return false;
                  
                  if (_searchQuery.isEmpty) return true;
                  return p.nome.toLowerCase().contains(_searchQuery) ||
                         (p.codigoBarras ?? '').toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.warehouse_outlined,
                    title: 'Nenhum item encontrado',
                  );
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
                          columns: const [
                            DataColumn(label: Text('PRODUTO')),
                            DataColumn(label: Text('UNIDADE')),
                            DataColumn(label: Text('ESTOQUE ATUAL'), numeric: true),
                            DataColumn(label: Text('ESTOQUE MÍN'), numeric: true),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('AÇÕES')),
                          ],
                          rows: filtered.map((p) {
                            final baixo = p.estoqueBaixo;
                            return DataRow(cells: [
                              DataCell(Text(p.nome, style: const TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(p.unidadeVenda)),
                              DataCell(Text(
                                Formatters.quantity(p.estoqueAtual),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: baixo ? AppTheme.accentRed : null,
                                ),
                              )),
                              DataCell(Text(Formatters.quantity(p.estoqueMinimo))),
                              DataCell(StatusChip.fromStatus(baixo ? 'pendente' : 'ativo')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                                  onPressed: () => _showAjusteDialog(context, ref, p),
                                  tooltip: 'Ajustar',
                                ),
                              ),
                            ]);
                          }).toList(),
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
    );
  }

  Widget _buildHistoricoTab(ThemeData theme) {
    final movementsAsync = ref.watch(stockMovementsProvider(produtoId: null, inicio: null, fim: null));

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: movementsAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando histórico...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (movs) {
          if (movs.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'Nenhuma movimentação registrada',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = movs[i];
              final isPositive = m.tipoMovimentacao == 'entrada' || 
                                 m.tipoMovimentacao == 'compra' || 
                                 ((m.tipoMovimentacao == 'ajuste' || m.tipoMovimentacao == 'inventario') && m.quantidade > 0);
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppTheme.accentGreen : AppTheme.accentRed).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                    size: 20,
                  ),
                ),
                title: Text(m.produtoNome ?? 'Produto [${m.produtoId}]', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${m.tipoMovimentacao.toUpperCase()} - ${m.observacao ?? 'Sem observação'}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? '+' : ''}${Formatters.quantity(m.quantidade)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                      ),
                    ),
                    Text(Formatters.dateTime(m.dataMovimentacao), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInventariosTab(ThemeData theme) {
    // Normalizar data para evitar loops (key estável para o provider)
    final today = DateUtils.dateOnly(DateTime.now());
    
    final inventoriesAsync = ref.watch(inventoriesProvider(
      inicio: _filterToday ? today : _invInicio,
      fim: _invFim,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showNovoInventarioDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo Inventário'),
            ),
            const SizedBox(width: 16),
            FilterChip(
              label: const Text('Hoje'),
              selected: _filterToday,
              onSelected: (val) {
                setState(() {
                  _filterToday = val;
                  if (val) {
                    _invInicio = null;
                    _invFim = null;
                  }
                });
              },
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _selectInvDateRange,
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(_invInicio != null ? 'Período Selecionado' : 'Selecionar Período'),
            ),
            const SizedBox(width: 8),
            if (_invInicio != null || _invFim != null || _filterToday)
              IconButton(
                tooltip: 'Limpar Filtros',
                onPressed: () {
                  setState(() {
                    _invInicio = null;
                    _invFim = null;
                    _filterToday = false;
                  });
                },
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
              ),
          ],
        ),
        if (_invInicio != null && _invFim != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Período: ${Formatters.date(_invInicio!)} até ${Formatters.date(_invFim!)}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: inventoriesAsync.when(
              loading: () => const LoadingOverlay(message: 'Carregando inventários...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (invs) {
                if (invs.isEmpty) {
                  return EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: _filterToday || _invInicio != null 
                        ? 'Nenhum inventário no período' 
                        : 'Nenhum inventário planejado',
                    subtitle: 'Crie um novo inventário para iniciar a contagem física.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: invs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final inv = invs[i];
                    return ListTile(
                      onTap: () => context.push('/estoque/contagem/${inv.idInventario}'),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: Text(inv.status[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor)),
                      ),
                      title: Text('Inventário: ${inv.codigo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(inv.descricao ?? 'Sem descrição'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip.fromStatus(inv.status),
                          const SizedBox(height: 4),
                          Text(Formatters.date(inv.dataInicio), style: const TextStyle(fontSize: 12)),
                        ],
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

  void _showAjusteDialog(BuildContext context, WidgetRef ref, [dynamic initialProduct]) {
    final produtoIdCtrl = TextEditingController(text: initialProduct?.idProduto.toString() ?? '');
    final quantidadeCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();
    String tipo = 'entrada';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(initialProduct != null ? 'Ajustar: ${initialProduct.nome}' : 'Ajustar Estoque'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (initialProduct != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Código: ${initialProduct.codigoBarras ?? initialProduct.idProduto}',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  TextFormField(
                    controller: produtoIdCtrl,
                    decoration: const InputDecoration(labelText: 'ID do Produto *'),
                    keyboardType: TextInputType.number,
                    enabled: initialProduct == null,
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tipo,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                      DropdownMenuItem(value: 'saida', child: Text('Saída')),
                      DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
                      DropdownMenuItem(value: 'perda', child: Text('Perda')),
                    ],
                    onChanged: (v) => setDialogState(() => tipo = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantidadeCtrl,
                    decoration: const InputDecoration(labelText: 'Quantidade *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: motivoCtrl,
                    decoration: const InputDecoration(labelText: 'Motivo *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final (success, msg) = await ref.read(stockActionsProvider.notifier).ajustar(
                  AjusteEstoqueRequest(
                    produtoId: int.parse(produtoIdCtrl.text),
                    quantidade: double.parse(quantidadeCtrl.text),
                    tipo: tipo,
                    motivo: motivoCtrl.text,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(productsProvider);
                  ref.invalidate(stockReportProvider);
                  ref.invalidate(stockMovementsProvider(produtoId: null, inicio: null, fim: null));
                  
                  if (success) {
                    AppNotifications.showSuccess(context, msg);
                  } else {
                    AppNotifications.showError(context, msg);
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectInvDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _invInicio != null && _invFim != null
          ? DateTimeRange(start: _invInicio!, end: _invFim!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      helpText: 'Selecione o período do inventário',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppTheme.primaryColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _invInicio = picked.start;
        _invFim = picked.end;
        _filterToday = false;
      });
    }
  }

  void _showNovoInventarioDialog(BuildContext context) {
    final codigoCtrl = TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch ~/ 10000}');
    final descCtrl = TextEditingController();
    int? selectedCategoria;
    final categoriesAsync = ref.watch(categoriesProvider);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Inventário'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codigoCtrl,
                    decoration: const InputDecoration(labelText: 'Código / Identificação *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.response.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Erro ao carregar categorias'),
                    data: (paginated) {
                      final cats = paginated.data;
                      return DropdownButtonFormField<int?>(
                        value: selectedCategoria,
                        decoration: const InputDecoration(labelText: 'Filtrar por Categoria (Opcional)'),
                        hint: const Text('Todas as Categorias'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todas as Categorias')),
                          ...cats.map((c) => DropdownMenuItem(value: c.idCategoria, child: Text(c.nome))),
                        ],
                        onChanged: (v) => setDialogState(() => selectedCategoria = v),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final (success, msg) = await ref.read(stockActionsProvider.notifier).criarInventario(
                  CriarInventarioRequest(
                    codigo: codigoCtrl.text,
                    descricao: descCtrl.text,
                    dataInicio: DateTime.now().toIso8601String(),
                    categoriaId: selectedCategoria,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    AppNotifications.showSuccess(context, msg);
                  } else {
                    AppNotifications.showError(context, msg);
                  }
                }
              },
              child: const Text('Iniciar Contagem'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StockKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
