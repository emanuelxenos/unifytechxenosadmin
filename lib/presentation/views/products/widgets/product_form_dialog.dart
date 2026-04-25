import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Produto? produto;
  final void Function(bool success, String message) onResult;

  const ProductFormDialog({super.key, this.produto, required this.onResult});

  @override
  ConsumerState<ProductFormDialog> createState() =>
      _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
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
  late TextEditingController _precoPromocionalCtrl;
  late TextEditingController _estoqueMinCtrl;
  late TextEditingController _localizacaoCtrl;
  
  DateTime? _dataVencimento;
  DateTime? _dataInicioPromocao;
  DateTime? _dataFimPromocao;

  // State
  int? _selectedCategoriaId;
  String _unidadeVenda = 'UN';
  bool _controlarEstoque = true;

  // Intelligence
  double _margemLucro = 0;
  double _markup = 0;

  bool get isEdit => widget.produto != null && widget.produto!.idProduto != 0;

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
    _precoPromocionalCtrl = TextEditingController(
        text: p?.precoPromocional != null ? p!.precoPromocional.toString() : '');
    _estoqueMinCtrl = TextEditingController(
        text: p != null ? p.estoqueMinimo.toString() : '0');
    _localizacaoCtrl = TextEditingController(text: p?.localizacao ?? '');
    
    _dataVencimento = p?.dataVencimento;
    _dataInicioPromocao = p?.dataInicioPromocao;
    _dataFimPromocao = p?.dataFimPromocao;
    _selectedCategoriaId = p?.categoriaId;
    _unidadeVenda = p?.unidadeVenda ?? 'UN';
    _controlarEstoque = p?.controlarEstoque ?? true;

    _calculateIntelligence();

    // Listeners for real-time calculation
    _precoVendaCtrl.addListener(_calculateIntelligence);
    _precoCustoCtrl.addListener(_calculateIntelligence);
  }

  void _calculateIntelligence() {
    final custo = double.tryParse(_precoCustoCtrl.text) ?? 0;
    final venda = double.tryParse(_precoVendaCtrl.text) ?? 0;

    setState(() {
      if (venda > 0) {
        _margemLucro = ((venda - custo) / venda) * 100;
      } else {
        _margemLucro = 0;
      }

      if (custo > 0) {
        _markup = ((venda - custo) / custo) * 100;
      } else {
        _markup = 0;
      }
    });
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
    _precoPromocionalCtrl.dispose();
    _estoqueMinCtrl.dispose();
    _localizacaoCtrl.dispose();
    super.dispose();
  }

  CriarProdutoRequest _buildRequest() {
    return CriarProdutoRequest(
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isEmpty ? null : _descricaoCtrl.text.trim(),
      codigoBarras: _codigoBarrasCtrl.text.trim().isEmpty ? null : _codigoBarrasCtrl.text.trim(),
      codigoInterno: _codigoInternoCtrl.text.trim().isEmpty ? null : _codigoInternoCtrl.text.trim(),
      categoriaId: _selectedCategoriaId,
      unidadeVenda: _unidadeVenda,
      controlarEstoque: _controlarEstoque,
      estoqueMinimo: double.tryParse(_estoqueMinCtrl.text) ?? 0,
      precoCusto: double.tryParse(_precoCustoCtrl.text) ?? 0,
      precoVenda: double.tryParse(_precoVendaCtrl.text) ?? 0,
      precoPromocional: double.tryParse(_precoPromocionalCtrl.text),
      dataInicioPromocao: _dataInicioPromocao,
      dataFimPromocao: _dataFimPromocao,
      margemLucro: _margemLucro,
      marca: _marcaCtrl.text.trim().isEmpty ? null : _marcaCtrl.text.trim(),
      localizacao: _localizacaoCtrl.text.trim().isEmpty ? null : _localizacaoCtrl.text.trim(),
      dataVencimento: _dataVencimento,
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
        width: 650,
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
                // ─── Preços e Inteligência ───
                Row(
                  children: [
                    Text('Preços e Inteligência',
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _margemLucro >= 30 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _margemLucro >= 30 ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Margem: ${_margemLucro.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _margemLucro >= 30 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Markup: ${_markup.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
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
                // ─── Promoção ───
                Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: AppTheme.accentOrange, size: 20),
                    const SizedBox(width: 8),
                    Text('Promoção',
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precoPromocionalCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Preço Promocional',
                          prefixIcon: Icon(Icons.local_offer_rounded),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            initialDateRange: _dataInicioPromocao != null && _dataFimPromocao != null
                                ? DateTimeRange(start: _dataInicioPromocao!, end: _dataFimPromocao!)
                                : null,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: theme.copyWith(
                                  colorScheme: theme.colorScheme.copyWith(
                                    primary: AppTheme.accentOrange,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (range != null) {
                            setState(() {
                              _dataInicioPromocao = range.start;
                              _dataFimPromocao = range.end;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Vigência Promoção',
                            prefixIcon: Icon(Icons.date_range_rounded),
                          ),
                          child: Text(
                            _dataInicioPromocao != null && _dataFimPromocao != null
                                ? '${Formatters.date(_dataInicioPromocao!)} - ${Formatters.date(_dataFimPromocao!)}'
                                : 'Selecionar período',
                            style: TextStyle(
                              fontSize: 12,
                              color: _dataInicioPromocao != null ? Colors.white : Colors.white38,
                            ),
                          ),
                        ),
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
                const SizedBox(height: 20),
                // ─── Varejo e Validade ───
                Text('Varejo e Validade',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _localizacaoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Localização (Aisle/Shelf)',
                          prefixIcon: Icon(Icons.location_on_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dataVencimento ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setState(() => _dataVencimento = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Vencimento',
                            prefixIcon: Icon(Icons.event_note_rounded),
                          ),
                          child: Text(
                            _dataVencimento != null
                                ? Formatters.date(_dataVencimento!)
                                : 'Selecionar data',
                            style: TextStyle(
                              color: _dataVencimento != null ? Colors.white : Colors.white38,
                            ),
                          ),
                        ),
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
