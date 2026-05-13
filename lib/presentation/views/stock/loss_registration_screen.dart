import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';

class LossRegistrationScreen extends ConsumerStatefulWidget {
  const LossRegistrationScreen({super.key});

  @override
  ConsumerState<LossRegistrationScreen> createState() => _LossRegistrationScreenState();
}

class _LossRegistrationScreenState extends ConsumerState<LossRegistrationScreen> {
  final _searchController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _motivoController = TextEditingController();
  
  Produto? _selectedProduct;
  String _selectedReason = 'Vencimento';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _reasons = [
    {'label': 'Vencimento', 'icon': Icons.event_busy_rounded, 'color': Colors.orangeAccent},
    {'label': 'Quebra/Avaria', 'icon': Icons.broken_image_rounded, 'color': Colors.redAccent},
    {'label': 'Roubo/Furto', 'icon': Icons.security_update_warning_rounded, 'color': Colors.purpleAccent},
    {'label': 'Extravio', 'icon': Icons.location_off_rounded, 'color': Colors.blueAccent},
    {'label': 'Uso Consumo', 'icon': Icons.restaurant_rounded, 'color': Colors.greenAccent},
    {'label': 'Outro', 'icon': Icons.more_horiz_rounded, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _quantidadeController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedProduct == null) {
      AppNotifications.showError(context, 'Selecione um produto');
      return;
    }
    if (_quantidadeController.text.isEmpty) {
      AppNotifications.showError(context, 'Informe a quantidade');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final request = AjusteEstoqueRequest(
        produtoId: _selectedProduct!.idProduto,
        quantidade: double.parse(_quantidadeController.text.replaceAll(',', '.')),
        tipo: 'perda',
        motivo: '$_selectedReason: ${_motivoController.text}'.trim(),
      );

      final (success, msg) = await ref.read(stockActionsProvider.notifier).ajustar(request);

      if (mounted) {
        if (success) {
          AppNotifications.showSuccess(context, 'Perda registrada com sucesso!');
          context.pop();
        } else {
          AppNotifications.showError(context, msg);
        }
      }
    } catch (e) {
      if (mounted) AppNotifications.showError(context, 'Erro ao processar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Registrar Perda / Avaria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lado Esquerdo: Seleção de Produto
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Selecione o Produto', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildProductSearch(theme),
                  const SizedBox(height: 24),
                  if (_selectedProduct != null) _buildProductDetails(theme),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Lado Direito: Detalhes da Perda
            Expanded(
              flex: 2,
              child: Container(
                decoration: AppTheme.glassCard(),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2. Detalhes da Ocorrência', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildReasonGrid(theme),
                      const SizedBox(height: 32),
                      const Text('Quantidade', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _quantidadeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          suffixText: _selectedProduct?.unidadeVenda ?? 'UN',
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text('Observação adicional (opcional)', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _motivoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Descreva o que aconteceu...',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('CONFIRMAR BAIXA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearch(ThemeData theme) {
    final productsState = ref.watch(productsProvider);
    
    return Column(
      children: [
        Container(
          decoration: AppTheme.glassCard(),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(productsProvider.notifier).setSearch(val),
            decoration: InputDecoration(
              hintText: 'Buscar por nome, código ou EAN...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                    _searchController.clear();
                    ref.read(productsProvider.notifier).setSearch('');
                  })
                : null,
            ),
          ),
        ),
        if (_searchController.text.isNotEmpty && _selectedProduct == null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: AppTheme.glassCard(),
            child: productsState.response is AsyncLoading 
              ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
              : (productsState.response.value?.data ?? []).isEmpty
                ? const Padding(padding: EdgeInsets.all(20), child: Text('Nenhum produto encontrado'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: productsState.response.value?.data.length ?? 0,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                    itemBuilder: (context, index) {
                      final p = productsState.response.value!.data[index];
                      return ListTile(
                        leading: p.fotoPrincipalUrl != null 
                          ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(p.fotoPrincipalUrl!, width: 40, height: 40, fit: BoxFit.cover))
                          : const Icon(Icons.inventory_2_rounded),
                        title: Text(p.nome),
                        subtitle: Text('EAN: ${p.codigoBarras ?? 'N/A'} | Estoque: ${p.estoqueAtual}'),

                        onTap: () {
                          setState(() {
                            _selectedProduct = p;
                            _searchController.text = p.nome;
                          });
                          ref.read(productsProvider.notifier).setSearch('');
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(ThemeData theme) {
    return Container(
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedProduct!.fotoPrincipalUrl != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_selectedProduct!.fotoPrincipalUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.inventory_2_rounded, color: Colors.white24, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedProduct!.nome, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Código: ${_selectedProduct!.idProduto} | EAN: ${_selectedProduct!.codigoBarras ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('Estoque Atual: ${_selectedProduct!.estoqueAtual} ${_selectedProduct!.unidadeVenda}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                onPressed: () => setState(() => _selectedProduct = null),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildReasonGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _reasons.length,
      itemBuilder: (context, index) {
        final reason = _reasons[index];
        final isSelected = _selectedReason == reason['label'];
        
        return InkWell(
          onTap: () => setState(() => _selectedReason = reason['label']),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? (reason['color'] as Color).withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? (reason['color'] as Color) : Colors.white10,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(reason['icon'], color: isSelected ? (reason['color'] as Color) : Colors.white54),
                const SizedBox(height: 8),
                Text(
                  reason['label'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
