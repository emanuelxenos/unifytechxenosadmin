import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});
  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = TextEditingController();
  final _horizontalController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final lowStockAsync = ref.watch(lowStockProvider);

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
            ),
            const SizedBox(height: 20),
            // Low stock summary
            lowStockAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) => items.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: AppTheme.accentOrange, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${items.length} produto(s) abaixo do estoque mínimo',
                            style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Container(
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nome, código de barras ou categoria...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: AppTheme.glassCard(),
                clipBehavior: Clip.antiAlias,
                child: productsAsync.response.when(
                  loading: () => const LoadingOverlay(message: 'Carregando estoque...'),
                  error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
                  data: (paginated) {
                    final products = paginated.data;
                    final stockProducts = products.where((p) {
                      final matchesControlled = p.controlarEstoque;
                      if (!matchesControlled) return false;
                      
                      if (_searchQuery.isEmpty) return true;
                      
                      final matchesName = p.nome.toLowerCase().contains(_searchQuery);
                      final matchesBarcode = (p.codigoBarras ?? '').toLowerCase().contains(_searchQuery);
                      final matchesCategory = (p.categoriaNome ?? '').toLowerCase().contains(_searchQuery);
                      
                      return matchesName || matchesBarcode || matchesCategory;
                    }).toList();

                    if (stockProducts.isEmpty) {
                      return EmptyState(
                        icon: Icons.warehouse_outlined,
                        title: _searchQuery.isEmpty ? 'Nenhum produto com controle de estoque' : 'Nenhum resultado encontrado',
                        subtitle: _searchQuery.isEmpty ? null : 'Tente buscar com termos diferentes',
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
                              rows: stockProducts.map((p) {
                                final baixo = p.estoqueBaixo;
                                return DataRow(cells: [
                                  DataCell(Text(p.nome)),
                                  DataCell(Text(p.unidadeVenda)),
                                  DataCell(Text(
                                    Formatters.quantity(p.estoqueAtual),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: baixo ? AppTheme.accentRed : null,
                                    ),
                                  )),
                                  DataCell(Text(Formatters.quantity(p.estoqueMinimo))),
                                  DataCell(StatusChip.fromStatus(baixo ? 'pendente' : 'ativo')),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.edit_note_rounded, size: 20, color: AppTheme.primaryColor),
                                      onPressed: () => _showAjusteDialog(context, ref, p),
                                      tooltip: 'Ajustar Estoque',
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
        ),
      ),
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
                    initialValue: tipo,
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
                    keyboardType: TextInputType.number,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
