import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/core/utils/debouncer.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/presentation/widgets/confirmation_dialog.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/domain/models/category.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _horizontalController = ScrollController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppTheme.accentGreen : AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isSuccess ? 3 : 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final filtered = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Produtos', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text('Gerencie o catálogo de produtos',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProductForm(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Novo Produto'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search bar
            Container(
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        _debouncer.run(() => ref.read(productsProvider.notifier).setSearch(v));
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por nome, código de barras ou categoria...',
                        prefixIcon:
                            const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(productsProvider.notifier).setSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () =>
                        ref.read(productsProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Products table
            Expanded(
              child: Container(
                decoration: AppTheme.glassCard(),
                clipBehavior: Clip.antiAlias,
                child: productsAsync.response.when(
                  loading: () => const LoadingOverlay(
                      message: 'Carregando produtos...'),
                  error: (e, _) => EmptyState(
                    icon: Icons.error_outline,
                    title: 'Erro ao carregar',
                    subtitle: e.toString(),
                    action: ElevatedButton(
                      onPressed: () =>
                          ref.read(productsProvider.notifier).refresh(),
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                  data: (paginated) {
                    final products = paginated.data;
                    if (products.isEmpty) {
                      return const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Nenhum produto encontrado',
                        subtitle:
                            'Cadastre produtos ou ajuste o filtro de busca',
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Scrollbar(
                                controller: _horizontalController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text('CÓDIGO')),
                                      DataColumn(label: Text('NOME')),
                                      DataColumn(label: Text('CATEGORIA')),
                                      DataColumn(label: Text('UNIDADE')),
                                      DataColumn(label: Text('ESTOQUE'), numeric: true),
                                      DataColumn(label: Text('PREÇO CUSTO'), numeric: true),
                                      DataColumn(label: Text('PREÇO VENDA'), numeric: true),
                                      DataColumn(label: Text('STATUS')),
                                      DataColumn(label: Text('AÇÕES')),
                                    ],
                                    rows: products
                                        .map((p) => _buildProductRow(p, theme))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${paginated.total} produtos',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Página ${paginated.page} de ${(paginated.total / paginated.limit).ceil() == 0 ? 1 : (paginated.total / paginated.limit).ceil()}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: paginated.hasPreviousPage
                                        ? () => ref.read(productsProvider.notifier).setPage(paginated.page - 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_left, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: paginated.hasNextPage
                                        ? () => ref.read(productsProvider.notifier).setPage(paginated.page + 1)
                                        : null,
                                    icon: const Icon(Icons.chevron_right, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
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
        ),
      ),
    );
  }

  DataRow _buildProductRow(Produto p, ThemeData theme) {
    return DataRow(
      cells: [
        DataCell(Text(
          p.codigoBarras ?? p.codigoInterno ?? '#${p.idProduto}',
          style: theme.textTheme.bodySmall,
        )),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (p.estoqueBaixo)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.warning_amber,
                      size: 14, color: AppTheme.accentOrange),
                ),
              Flexible(
                  child: Text(p.nome, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        DataCell(Text(p.categoriaNome ?? 'Sem categoria')),
        DataCell(Text(p.unidadeVenda)),
        DataCell(
          Text(
            Formatters.quantity(p.estoqueAtual),
            style: TextStyle(
              color: p.estoqueBaixo ? AppTheme.accentRed : null,
              fontWeight: p.estoqueBaixo ? FontWeight.w600 : null,
            ),
          ),
        ),
        DataCell(Text(Formatters.currency(p.precoCusto))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.currency(p.precoVenda),
                  style: theme.textTheme.bodyLarge),
              if (p.emPromocao)
                Text(
                  Formatters.currency(p.precoPromocional!),
                  style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        DataCell(StatusChip.fromStatus(p.ativo ? 'ativo' : 'inativo')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showProductForm(context, produto: p),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: Icon(
                  p.ativo ? Icons.block : Icons.check_circle_outline,
                  size: 18,
                  color:
                      p.ativo ? AppTheme.accentRed : AppTheme.accentGreen,
                ),
                onPressed: () async {
                  if (p.ativo) {
                    final confirm = await ConfirmationDialog.show(
                      context,
                      title: 'Inativar Produto',
                      message:
                          'Tem certeza que deseja inativar "${p.nome}"?\nO produto não aparecerá no PDV.',
                      confirmText: 'Inativar',
                      isDangerous: true,
                    );
                    if (confirm == true) {
                      final (success, msg) = await ref
                          .read(productsProvider.notifier)
                          .inativar(p.idProduto);
                      _showFeedback(msg, success);
                    }
                  }
                },
                tooltip: p.ativo ? 'Inativar' : 'Ativar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProductForm(BuildContext context, {Produto? produto}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ProductFormDialog(
        produto: produto,
        onResult: (success, message) {
          _showFeedback(message, success);
        },
      ),
    );
  }
}

// ─── PRODUCT FORM DIALOG ────────────────────────────────────────────────────

class _ProductFormDialog extends ConsumerStatefulWidget {
  final Produto? produto;
  final void Function(bool success, String message) onResult;

  const _ProductFormDialog({this.produto, required this.onResult});

  @override
  ConsumerState<_ProductFormDialog> createState() =>
      _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Controllers
  late TextEditingController _nomeCtrl;
  late TextEditingController _descricaoCtrl;
  late TextEditingController _codigoBarrasCtrl;
  late TextEditingController _codigoInternoCtrl;
  late TextEditingController _marcaCtrl;
  late TextEditingController _precoVendaCtrl;
  late TextEditingController _precoCustoCtrl;
  late TextEditingController _estoqueMinCtrl;

  // State
  int? _selectedCategoriaId;
  String _unidadeVenda = 'UN';
  bool _controlarEstoque = true;

  bool get isEdit => widget.produto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _nomeCtrl = TextEditingController(text: p?.nome ?? '');
    _descricaoCtrl = TextEditingController(text: p?.descricao ?? '');
    _codigoBarrasCtrl = TextEditingController(text: p?.codigoBarras ?? '');
    _codigoInternoCtrl =
        TextEditingController(text: p?.codigoInterno ?? '');
    _marcaCtrl = TextEditingController(text: p?.marca ?? '');
    _precoVendaCtrl =
        TextEditingController(text: p != null ? p.precoVenda.toString() : '');
    _precoCustoCtrl =
        TextEditingController(text: p != null ? p.precoCusto.toString() : '0');
    _estoqueMinCtrl = TextEditingController(
        text: p != null ? p.estoqueMinimo.toString() : '0');
    _selectedCategoriaId = p?.categoriaId;
    _unidadeVenda = p?.unidadeVenda ?? 'UN';
    _controlarEstoque = p?.controlarEstoque ?? true;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _codigoBarrasCtrl.dispose();
    _codigoInternoCtrl.dispose();
    _marcaCtrl.dispose();
    _precoVendaCtrl.dispose();
    _precoCustoCtrl.dispose();
    _estoqueMinCtrl.dispose();
    super.dispose();
  }

  CriarProdutoRequest _buildRequest() {
    return CriarProdutoRequest(
      nome: _nomeCtrl.text.trim(),
      descricao:
          _descricaoCtrl.text.trim().isEmpty ? null : _descricaoCtrl.text.trim(),
      codigoBarras: _codigoBarrasCtrl.text.trim().isEmpty
          ? null
          : _codigoBarrasCtrl.text.trim(),
      codigoInterno: _codigoInternoCtrl.text.trim().isEmpty
          ? null
          : _codigoInternoCtrl.text.trim(),
      marca:
          _marcaCtrl.text.trim().isEmpty ? null : _marcaCtrl.text.trim(),
      categoriaId: _selectedCategoriaId,
      unidadeVenda: _unidadeVenda,
      controlarEstoque: _controlarEstoque,
      estoqueMinimo: double.tryParse(_estoqueMinCtrl.text) ?? 0,
      precoCusto: double.tryParse(_precoCustoCtrl.text) ?? 0,
      precoVenda: double.parse(_precoVendaCtrl.text),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final (success, message) = isEdit
        ? await ref
            .read(productsProvider.notifier)
            .atualizar(widget.produto!.idProduto, _buildRequest())
        : await ref.read(productsProvider.notifier).criar(_buildRequest());

    setState(() => _saving = false);

    if (mounted) {
      Navigator.pop(context);
      widget.onResult(success, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriasAsync = ref.watch(categoriesProvider);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEdit ? Icons.edit : Icons.add_box_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(isEdit ? 'Editar Produto' : 'Novo Produto'),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Informações Básicas ───
                Text('Informações Básicas',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto *',
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _marcaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          prefixIcon: Icon(Icons.branding_watermark_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: categoriasAsync.response.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, _) => DropdownButtonFormField<int>(
                          value: _selectedCategoriaId,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            prefixIcon: Icon(Icons.category_rounded),
                          ),
                          items: const [],
                          onChanged: (v) =>
                              setState(() => _selectedCategoriaId = v),
                          hint: const Text('Sem categorias'),
                        ),
                        data: (categorias) {
                          return DropdownButtonFormField<int?>(
                            value: _selectedCategoriaId,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              prefixIcon: Icon(Icons.category_rounded),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Sem categoria'),
                              ),
                              ...categorias.data.map((c) => DropdownMenuItem<int?>(
                                    value: c.idCategoria,
                                    child: Text(c.nome),
                                  )),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedCategoriaId = v),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ─── Códigos ───
                Text('Códigos',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codigoBarrasCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras',
                          prefixIcon: Icon(Icons.qr_code_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _codigoInternoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Código Interno',
                          prefixIcon: Icon(Icons.tag_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ─── Preços ───
                Text('Preços',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precoCustoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Preço de Custo',
                          prefixIcon: Icon(Icons.money_off_rounded),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _precoVendaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Preço de Venda *',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Preço inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ─── Estoque e Unidade ───
                Text('Estoque e Unidade',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _unidadeVenda,
                        decoration: const InputDecoration(
                          labelText: 'Unidade de Venda',
                          prefixIcon: Icon(Icons.straighten_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'UN', child: Text('UN - Unidade')),
                          DropdownMenuItem(value: 'KG', child: Text('KG - Quilograma')),
                          DropdownMenuItem(value: 'LT', child: Text('LT - Litro')),
                          DropdownMenuItem(value: 'MT', child: Text('MT - Metro')),
                          DropdownMenuItem(value: 'CX', child: Text('CX - Caixa')),
                          DropdownMenuItem(value: 'PC', child: Text('PC - Peça')),
                          DropdownMenuItem(value: 'FD', child: Text('FD - Fardo')),
                          DropdownMenuItem(value: 'PT', child: Text('PT - Pacote')),
                        ],
                        onChanged: (v) =>
                            setState(() => _unidadeVenda = v ?? 'UN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _estoqueMinCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Estoque Mínimo',
                          prefixIcon: Icon(Icons.inventory_2_rounded),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Controlar Estoque'),
                  subtitle: const Text(
                      'Ativar o controle de estoque para este produto'),
                  value: _controlarEstoque,
                  onChanged: (v) =>
                      setState(() => _controlarEstoque = v),
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isEdit) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.accentBlue, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'O estoque inicial é zero. Para dar entrada, use a tela de Estoque > Ajustar Estoque ou registre uma compra.',
                            style: TextStyle(
                                color: AppTheme.accentBlue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(isEdit ? Icons.save_rounded : Icons.add_rounded,
                  size: 18),
          label: Text(_saving
              ? 'Salvando...'
              : isEdit
                  ? 'Salvar Alterações'
                  : 'Cadastrar Produto'),
        ),
      ],
    );
  }
}
