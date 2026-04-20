import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class InventoryCountingScreen extends ConsumerStatefulWidget {
  final int inventoryId;

  const InventoryCountingScreen({super.key, required this.inventoryId});

  @override
  ConsumerState<InventoryCountingScreen> createState() => _InventoryCountingScreenState();
}

class _InventoryCountingScreenState extends ConsumerState<InventoryCountingScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryDetailsProvider(widget.inventoryId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contagem de Inventário'),
        actions: [
          inventoryAsync.when(
            data: (inv) => inv.status == 'aberto'
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => _showFinalizarDialog(context, inv),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Finalizar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: inventoryAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando itens...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (inv) {
          final filteredItems = inv.itens.where((it) {
            final query = _searchQuery.toLowerCase();
            return it.produtoNome?.toLowerCase().contains(query) ?? false;
          }).toList();

          final totalCounted = inv.itens.where((it) => it.contado).length;

          return Column(
            children: [
              // Header Info
              _buildHeader(inv, totalCounted, theme),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar produto no inventário...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Items List
              Expanded(
                child: filteredItems.isEmpty
                    ? const EmptyState(icon: Icons.inventory_2_outlined, title: 'Nenhum produto encontrado')
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = filteredItems[i];
                          return _buildItemCard(item, inv.status == 'aberto', theme);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Inventario inv, int totalCounted, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.codigo, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(inv.descricao ?? 'Sem descrição', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(inv.status == 'aberto' ? Icons.lock_open : Icons.lock, size: 16, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(inv.status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          _buildProgressCircle(totalCounted, inv.itens.length, theme),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(int current, int total, ThemeData theme) {
    final percent = total > 0 ? (current / total) : 0.0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percent,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(percent == 1.0 ? AppTheme.accentGreen : theme.primaryColor),
              ),
            ),
            Text('${(percent * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$current / $total', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildItemCard(InventarioItem item, bool isAberto, ThemeData theme) {
    return Container(
      decoration: AppTheme.glassCard(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(item.produtoNome ?? 'Produto [${item.produtoId}]', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Contagem Cega - Insira a quantidade física'),
        trailing: Container(
          width: 140,
          child: isAberto
              ? _buildCountAction(item, theme)
              : Text(
                  Formatters.quantity(item.quantidadeFisica ?? 0),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildCountAction(InventarioItem item, ThemeData theme) {
    return ElevatedButton(
      onPressed: () => _showContagemDialog(context, item),
      style: ElevatedButton.styleFrom(
        backgroundColor: item.contado ? AppTheme.accentGreen.withValues(alpha: 0.1) : theme.primaryColor,
        foregroundColor: item.contado ? AppTheme.accentGreen : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(item.contado ? Formatters.quantity(item.quantidadeFisica ?? 0) : 'CONTAR'),
    );
  }

  Future<void> _showContagemDialog(BuildContext context, InventarioItem item) async {
    final controller = TextEditingController(text: item.quantidadeFisica?.toString() ?? '');
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contagem: ${item.produtoNome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Insira a quantidade exata encontrada fisicamente:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Quantidade Física',
                suffixText: 'itens',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null) {
                final (success, msg) = await ref.read(stockActionsProvider.notifier).atualizarItemInventario(
                  widget.inventoryId,
                  item.produtoId,
                  val,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    // Refresh current view if needed - though when() handles it via invalidate
                  } else {
                    AppNotifications.showError(context, msg);
                  }
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFinalizarDialog(BuildContext context, Inventario inv) async {
    final pending = inv.itens.where((it) => !it.contado).length;
    final obsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Inventário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Existem $pending itens não contados. O sistema irá considerar apenas as quantidades inseridas.',
                        style: const TextStyle(color: AppTheme.accentOrange, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Ao finalizar, o estoque dos produtos será atualizado com os valores contados. Esta ação não pode ser desfeita.'),
            const SizedBox(height: 16),
            TextField(
              controller: obsController,
              decoration: const InputDecoration(
                labelText: 'Observações de Fechamento',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final (success, msg) = await ref.read(stockActionsProvider.notifier).finalizarInventario(
                inv.idInventario,
                obsController.text,
              );
              if (context.mounted) {
                Navigator.pop(context); // Fecha o diálogo
                if (success) {
                  AppNotifications.showSuccess(context, msg);
                  context.pop(); // Volta para a tela de estoque via GoRouter
                } else {
                  AppNotifications.showError(context, msg);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen, foregroundColor: Colors.white),
            child: const Text('CONFIRMAR FECHAMENTO'),
          ),
        ],
      ),
    );
  }
}
