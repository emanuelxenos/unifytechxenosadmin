import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/presentation/providers/report_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';
import 'package:unifytechxenosadmin/core/utils/debouncer.dart';
import 'package:unifytechxenosadmin/presentation/views/stock/inventory_counting_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:unifytechxenosadmin/data/repositories/report_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});
  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);
  bool _showStats = true; // Toggle for KPI cards
  bool _isExporting = false;
  final _searchFocus = FocusNode();
  final Set<int> _selectedIds = {};
  
  // Filtros de Inventário
  DateTime? _invInicio;
  DateTime? _invFim;
  bool _filterToday = false;

  // Filtros de Histórico
  DateTime? _histInicio;
  DateTime? _histFim;
  bool _filterHistToday = false;
  String? _histTipo;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final isControl = HardwareKeyboard.instance.isControlPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    if (isControl && event.logicalKey == LogicalKeyboardKey.keyF) {
      _searchFocus.requestFocus();
      return true;
    }
    if (isAlt && event.logicalKey == LogicalKeyboardKey.keyS) {
      _showSugestaoCompraDialog(context, ref);
      return true;
    }
    if (isAlt && event.logicalKey == LogicalKeyboardKey.keyP) {
      _imprimirEtiquetasLote();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_searchFocus.hasFocus) {
        _searchController.clear();
        ref.read(productsProvider.notifier).setSearch('');
        _searchFocus.unfocus();
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    _searchController.dispose();
    _horizontalController.dispose();
    _debouncer.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _exportar(String formato) async {
    setState(() => _isExporting = true);
    final productsState = ref.read(productsProvider);
    
    try {
      String fileName = 'estoque_${DateTime.now().millisecondsSinceEpoch}.$formato';
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Exportar Estoque',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [formato],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.$formato')) outputFile += '.$formato';
        
        final params = {
          'search': productsState.search,
          'categoria_id': productsState.categoriaId,
          'baixo_estoque': productsState.onlyLowStock,
          'vencendo': productsState.onlyExpiring,
        };

        await ref.read(reportRepositoryProvider).exportarRelatorio(
          formato, 
          outputFile, 
          'estoque_lista',
          params: params,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estoque exportado: $outputFile'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _imprimirEtiqueta(int produtoId) async {
    try {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salvar Etiqueta',
        fileName: 'etiqueta_$produtoId.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.pdf')) outputFile += '.pdf';
        await ref.read(reportRepositoryProvider).imprimirEtiqueta(produtoId, outputFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Etiqueta gerada com sucesso!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao imprimir etiqueta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSugestaoCompraDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shopping_cart_checkout_rounded, color: Colors.blueAccent),
            SizedBox(width: 12),
            Text('Sugestão de Compra'),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: ref.read(reportRepositoryProvider).sugestaoCompra(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhuma sugestão no momento.'));
              }

              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return ListTile(
                    title: Text(item['nome'] ?? ''),
                    subtitle: Text('Estoque Atual: ${item['estoque_atual']} | Mín: ${item['estoque_minimo']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Sugerido', style: TextStyle(fontSize: 11, color: Colors.blueAccent)),
                        Text(
                          '${item['sugestao_quantidade']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/compras');
            },
            child: const Text('Ir para Compras'),
          ),
        ],
      ),
    );
  }

  Future<void> _imprimirEtiquetasLote() async {
    if (_selectedIds.isEmpty) return;
    
    try {
      String fileName = 'etiquetas_lote_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salvar Etiquetas em Lote',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.pdf')) outputFile += '.pdf';
        await ref.read(reportRepositoryProvider).imprimirEtiquetasLote(_selectedIds.toList(), outputFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lote de etiquetas gerado com sucesso!'), backgroundColor: Colors.green),
          );
          setState(() => _selectedIds.clear());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao imprimir lote: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showProductPerformanceDialog(dynamic product) async {
    final theme = Theme.of(context);
    final reportRepo = ref.read(reportRepositoryProvider);

    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glassCard(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informações Detalhadas', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70)),
                          Text(product.nome, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: 'Performance (6m)'),
                    Tab(text: 'Histórico de Auditoria'),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Performance Chart
                      _buildPerformanceTab(reportRepo, product.idProduto),
                      
                      // Tab 2: Auditoria Log
                      _buildAuditoriaTab(reportRepo, product.idProduto),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceTab(ReportRepository repo, int id) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.getPerformanceProduto(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Sem dados de movimentação nos últimos 6 meses.', style: TextStyle(color: Colors.white54)),
          );
        }

        final data = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(data),
                    barGroups: _buildBarGroups(data),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            if (val.toInt() >= data.length) return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                data[val.toInt()]['mes'],
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Entradas', Colors.blueAccent),
                const SizedBox(width: 24),
                _buildLegend('Saídas', Colors.redAccent),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuditoriaTab(ReportRepository repo, int id) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.getAuditoriaEstoque(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhuma movimentação registrada.',
                style: TextStyle(color: Colors.white54)),
          );
        }

        final data = snapshot.data!;
        final scrollController = ScrollController();
        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white10))),
                  children: [
                    _headerCell('Data'),
                    _headerCell('Usuário'),
                    _headerCell('Operação'),
                    _headerCell('Qtd'),
                    _headerCell('Observação'),
                  ],
                ),
                ...data.map((m) {
                  final date = DateTime.parse(m['data']);
                  return TableRow(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.05)))),
                    children: [
                      _dataCell(Formatters.dateTime(date)),
                      _dataCell(m['usuario']),
                      _dataCell(m['tipo'].toString().toUpperCase(),
                          color: _getTipoColor(m['tipo'])),
                      _dataCell(Formatters.quantity(m['quantidade']),
                          bold: true),
                      _dataCell(m['observacao'] ?? '-', size: 11),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerCell(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12)),
  );

  Widget _dataCell(String text, {Color? color, bool bold = false, double size = 12}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: TextStyle(
        color: color ?? Colors.white54,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: size,
      ),
    ),
  );

  Color _getTipoColor(String tipo) {
    if (tipo.contains('entrada') || tipo.contains('compra')) return Colors.greenAccent;
    if (tipo.contains('saida') || tipo.contains('venda') || tipo.contains('perda')) return Colors.redAccent;
    return Colors.blueAccent;
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 0;
    for (var d in data) {
      if (d['entrada'] > max) max = (d['entrada'] as num).toDouble();
      if (d['saida'] > max) max = (d['saida'] as num).toDouble();
    }
    return max == 0 ? 10 : max * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: (data[i]['entrada'] as num).toDouble(),
            color: Colors.blueAccent,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: (data[i]['saida'] as num).toDouble(),
            color: Colors.redAccent,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
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
                if (_selectedIds.isNotEmpty) _buildBulkActionsBar(theme),
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
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        IconButton(
          tooltip: 'Exportar PDF',
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
          onPressed: _isExporting ? null : () => _exportar('pdf'),
        ),
        IconButton(
          tooltip: 'Exportar Excel',
          icon: const Icon(Icons.table_chart_rounded, color: Colors.green),
          onPressed: _isExporting ? null : () => _exportar('xlsx'),
        ),
        IconButton(
          tooltip: 'Sugestão de Compra (Alt+S)',
          icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.blueAccent),
          onPressed: () => _showSugestaoCompraDialog(context, ref),
        ),
        Tooltip(
          message: 'Atalhos do Teclado:\n• Ctrl + F: Buscar Produto\n• Alt + S: Sugestão de Compra\n• Alt + P: Imprimir Etiquetas (Lote)\n• Esc: Limpar busca/filtros',
          child: IconButton(
            icon: const Icon(Icons.keyboard_command_key_rounded, color: Colors.white70),
            onPressed: () {},
          ),
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

  Widget _buildBulkActionsBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.glassBoxShadow,
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} itens selecionados',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _imprimirEtiquetasLote,
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Imprimir Etiquetas (Lote)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => setState(() => _selectedIds.clear()),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildVencimentoCell(DateTime? data) {
    if (data == null) return const Text('N/A', style: TextStyle(color: Colors.white54));
    
    final now = DateTime.now();
    final difference = data.difference(now).inDays;
    
    Color color = Colors.white;
    if (data.isBefore(now)) {
      color = AppTheme.accentRed;
    } else if (difference <= 15) {
      color = AppTheme.accentOrange;
    } else if (difference <= 30) {
      color = Colors.yellow;
    }

    return Text(
      Formatters.date(data),
      style: TextStyle(color: color, fontWeight: color != Colors.white ? FontWeight.bold : null),
    );
  }

  Widget _buildPosicaoTab(ThemeData theme) {
    final productsState = ref.watch(productsProvider);
    final reportAsync = ref.watch(stockReportProvider);
    final productsNotifier = ref.read(productsProvider.notifier);

    return Column(
      children: [
        // KPI Cards
        // KPI Cards with Animation
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: (!_showStats || productsState.onlyLowStock || productsState.onlyExpiring || productsState.onlyReposition)
              ? const SizedBox.shrink() // Hide stats manually or when filtering
              : reportAsync.when(
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
                _StockKpiCard(
                  title: 'Reposição Necessária',
                  value: Formatters.currency(data['sugestao_compra_total']?.toDouble() ?? 0),
                  icon: Icons.shopping_cart_checkout_rounded,
                  color: Colors.purple,
                ),
                _StockKpiCard(
                  title: 'Vencendo (15 dias)',
                  value: data['produtos_vencendo']?.toString() ?? '0',
                  icon: Icons.event_busy_rounded,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
                  loading: () => const SizedBox(height: 100, child: LoadingOverlay()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
        ),

        // Search & Filters
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: AppTheme.glassCard(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (v) {
                        _debouncer.run(() => productsNotifier.setSearch(v));
                      },
                      decoration: const InputDecoration(
                        hintText: 'Buscar produto...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _showStats ? 'Esconder Estatísticas' : 'Mostrar Estatísticas',
                  icon: Icon(
                    _showStats ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => setState(() => _showStats = !_showStats),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Filtro de Categoria
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: ref.watch(categoriesProvider).response.when(
                    data: (paginated) => DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: productsState.categoriaId,
                        hint: const Text('Categoria', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.primaryColor),
                        dropdownColor: const Color(0xFF1C2039),
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        onChanged: (id) => productsNotifier.setCategoria(id),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas Categorias'),
                          ),
                          ...paginated.data.map((cat) => DropdownMenuItem(
                            value: cat.idCategoria,
                            child: Text(cat.nome),
                          )),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const Icon(Icons.error_outline, size: 18, color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Estoque Baixo'),
                  selected: productsState.onlyLowStock,
                  onSelected: (v) => productsNotifier.setFilterLowStock(v),
                  selectedColor: AppTheme.accentOrange.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.accentOrange,
                ),
                FilterChip(
                  label: const Text('Vencendo (15d)'),
                  selected: productsState.onlyExpiring,
                  onSelected: (v) => productsNotifier.setFilterExpiring(v),
                  selectedColor: AppTheme.accentRed.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.accentRed,
                ),
                FilterChip(
                  label: const Text('Reposição'),
                  selected: productsState.onlyReposition,
                  onSelected: (v) => productsNotifier.setFilterReposition(v),
                  selectedColor: Colors.purple.withValues(alpha: 0.2),
                  checkmarkColor: Colors.purple,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        // Table with Pagination
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: productsState.response.when(
              loading: () => const LoadingOverlay(message: 'Carregando estoque...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (paginated) {
                final products = paginated.data;

                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.warehouse_outlined,
                    title: 'Nenhum item encontrado',
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: _verticalController,
                        child: SingleChildScrollView(
                          controller: _verticalController,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            controller: _horizontalController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                    label: Checkbox(
                                      value: products.isNotEmpty && _selectedIds.length == products.length,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedIds.addAll(products.map((p) => p.idProduto));
                                          } else {
                                            _selectedIds.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const DataColumn(label: Text('PRODUTO')),
                                  const DataColumn(label: Text('UNIDADE')),
                                  const DataColumn(label: Text('ESTOQUE ATUAL'), numeric: true),
                                  const DataColumn(label: Text('ESTOQUE MÍN'), numeric: true),
                                  const DataColumn(label: Text('LOCALIZAÇÃO')),
                                  const DataColumn(label: Text('VENCIMENTO')),
                                  const DataColumn(label: Text('STATUS')),
                                  const DataColumn(label: Text('AÇÕES')),
                                ],
                                rows: products.map((p) {
                                  final baixo = p.estoqueBaixo;
                                  final isSelected = _selectedIds.contains(p.idProduto);
                                  return DataRow(
                                    selected: isSelected,
                                    cells: [
                                      DataCell(
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedIds.add(p.idProduto);
                                              } else {
                                                _selectedIds.remove(p.idProduto);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () => _showProductPerformanceDialog(p),
                                          borderRadius: BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                            child: Text(
                                              p.nome,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    DataCell(Text(p.unidadeVenda)),
                                    DataCell(Text(
                                      Formatters.quantity(p.estoqueAtual),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: baixo ? AppTheme.accentRed : null,
                                      ),
                                    )),
                                    DataCell(Text(Formatters.quantity(p.estoqueMinimo))),
                                    DataCell(Text(p.localizacao ?? 'N/A')),
                                    DataCell(_buildVencimentoCell(p.dataVencimento)),
                                    DataCell(StatusChip.fromStatus(baixo ? 'pendente' : 'ativo')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.label_outline_rounded, color: Colors.orangeAccent),
                                            onPressed: () => _imprimirEtiqueta(p.idProduto),
                                            tooltip: 'Imprimir Etiqueta',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                                            onPressed: () => _showAjusteDialog(context, ref, p),
                                            tooltip: 'Ajustar',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ${paginated.total} produtos',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          Row(
                            children: [
                              Text(
                                'Página ${paginated.page} de ${(paginated.total / paginated.limit).ceil() == 0 ? 1 : (paginated.total / paginated.limit).ceil()}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: paginated.hasPreviousPage
                                    ? () => productsNotifier.setPage(paginated.page - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                color: Colors.white,
                              ),
                              IconButton(
                                onPressed: paginated.hasNextPage
                                    ? () => productsNotifier.setPage(paginated.page + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricoTab(ThemeData theme) {
    // Normalizar data para evitar loops
    final today = DateUtils.dateOnly(DateTime.now());
    
    final movementsAsync = ref.watch(stockMovementsProvider(
      produtoId: null, 
      inicio: _filterHistToday ? today : _histInicio, 
      fim: _histFim,
      tipo: _histTipo,
    ));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Hoje'),
                selected: _filterHistToday,
                onSelected: (val) {
                  setState(() {
                    _filterHistToday = val;
                    if (val) {
                      _histInicio = null;
                      _histFim = null;
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              // Filtro de Tipo de Movimentação
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _histTipo,
                    hint: const Text('Tipo', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.primaryColor),
                    dropdownColor: const Color(0xFF1C2039),
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    onChanged: (val) => setState(() => _histTipo = val),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos Tipos')),
                      DropdownMenuItem(value: 'entrada', child: Text('Entradas')),
                      DropdownMenuItem(value: 'saida', child: Text('Saídas')),
                      DropdownMenuItem(value: 'ajuste', child: Text('Ajustes')),
                      DropdownMenuItem(value: 'inventario', child: Text('Inventário')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _selectHistDateRange,
                icon: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(_histInicio != null ? 'Período Selecionado' : 'Selecionar Período'),
              ),
              const SizedBox(width: 8),
              if (_histInicio != null || _histFim != null || _filterHistToday)
                IconButton(
                  tooltip: 'Limpar Filtros',
                  onPressed: () {
                    setState(() {
                      _histInicio = null;
                      _histFim = null;
                      _filterHistToday = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
            ],
          ),
        ),
        if (_histInicio != null && _histFim != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Período: ${Formatters.date(_histInicio!)} até ${Formatters.date(_histFim!)}',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: movementsAsync.when(
              loading: () => const LoadingOverlay(message: 'Carregando histórico...'),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
              data: (movs) {
                if (movs.isEmpty) {
                  return EmptyState(
                    icon: Icons.history_rounded,
                    title: _filterHistToday || _histInicio != null 
                        ? 'Nenhuma movimentação no período' 
                        : 'Nenhuma movimentação registrada',
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
    ),
  ),
],
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

  Future<void> _selectHistDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _histInicio != null && _histFim != null
          ? DateTimeRange(start: _histInicio!, end: _histFim!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      helpText: 'Selecione o período do histórico',
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
        _histInicio = picked.start;
        _histFim = picked.end;
        _filterHistToday = false;
      });
    }
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
