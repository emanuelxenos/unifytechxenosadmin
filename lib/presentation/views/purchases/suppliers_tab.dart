import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/presentation/providers/supplier_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/domain/models/supplier.dart';

class SuppliersTab extends ConsumerWidget {
  const SuppliersTab({super.key});

  void _showFeedback(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppTheme.accentGreen : AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suppliersAsync = ref.watch(suppliersProvider);
    final filtered = ref.watch(filteredSuppliersProvider);
    final paginatedFiltered = ref.watch(paginatedFilteredSuppliersProvider);
    final pagination = ref.watch(supplierPaginationStateProvider);

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) {
                    ref.read(supplierSearchProvider.notifier).setQuery(v);
                    ref.read(supplierPaginationStateProvider.notifier).setPage(1);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar fornecedor por nome ou CNPJ...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Mostrar Inativos'),
                selected: ref.watch(supplierInactivesProvider),
                onSelected: (v) {
                  ref.read(supplierInactivesProvider.notifier).set(v);
                  ref.read(supplierPaginationStateProvider.notifier).setPage(1);
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showSupplierForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo Fornecedor'),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: Container(
            decoration: AppTheme.glassCard(),
            clipBehavior: Clip.antiAlias,
            child: suppliersAsync.when(
              loading: () => const LoadingOverlay(message: 'Carregando fornecedores...'),
              error: (e, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Erro ao carregar',
                subtitle: e.toString(),
                action: ElevatedButton(
                  onPressed: () => ref.read(suppliersProvider.notifier).refresh(),
                  child: const Text('Tentar novamente'),
                ),
              ),
              data: (_) {
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: 'Nenhum fornecedor encontrado',
                    subtitle: 'Cadastre fornecedores para registrar compras.',
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('RAZÃO SOCIAL')),
                            DataColumn(label: Text('CNPJ')),
                            DataColumn(label: Text('TELEFONE')),
                            DataColumn(label: Text('CIDADE')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('AÇÕES')),
                          ],
                          rows: paginatedFiltered.map((s) => DataRow(
                            cells: [
                              DataCell(Text(s.razaoSocial)),
                              DataCell(Text(s.cnpj ?? '-')),
                              DataCell(Text(s.telefone ?? '-')),
                              DataCell(Text(s.cidade ?? '-')),
                              DataCell(StatusChip.fromStatus(s.ativo ? 'ativo' : 'inativo')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.analytics_outlined, size: 18, color: AppTheme.accentBlue),
                                      tooltip: 'Análises e Histórico',
                                      onPressed: () {
                                        ref.read(selectedSupplierAnalyticsProvider.notifier).select(s.idFornecedor);
                                        DefaultTabController.of(context).animateTo(2);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      tooltip: 'Editar',
                                      onPressed: () => _showSupplierForm(context, supplier: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.accentRed),
                                      tooltip: 'Inativar',
                                      onPressed: () => _confirmInactivate(context, ref, s),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Itens por página:', style: theme.textTheme.bodyMedium),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: pagination.limit,
                                underline: const SizedBox(),
                                items: [5, 10, 20, 50].map((limit) => DropdownMenuItem(
                                  value: limit,
                                  child: Text('$limit'),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(supplierPaginationStateProvider.notifier).setLimit(val);
                                  }
                                },
                              ),
                            ],
                          ),
                          Text(
                            'Mostrando ${filtered.isEmpty ? 0 : (pagination.page - 1) * pagination.limit + 1} - '
                            '${(pagination.page - 1) * pagination.limit + paginatedFiltered.length} de '
                            '${filtered.length}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: pagination.page > 1
                                    ? () => ref.read(supplierPaginationStateProvider.notifier).setPage(pagination.page - 1)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pág. ${pagination.page}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: filtered.length > pagination.page * pagination.limit
                                    ? () => ref.read(supplierPaginationStateProvider.notifier).setPage(pagination.page + 1)
                                    : null,
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

  void _showSupplierForm(BuildContext context, {Fornecedor? supplier}) {
    showDialog(
      context: context,
      builder: (context) => _SupplierFormDialog(supplier: supplier),
    );
  }

  Future<void> _confirmInactivate(BuildContext context, WidgetRef ref, Fornecedor supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inativar Fornecedor'),
        content: Text('Deseja inativar o fornecedor "${supplier.razaoSocial}"?\nEle não aparecerá mais para novas compras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Inativar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final (success, message) = await ref.read(suppliersProvider.notifier).inativar(supplier.idFornecedor);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed),
        );
      }
    }
  }
}

class _SupplierFormDialog extends ConsumerStatefulWidget {
  final Fornecedor? supplier;
  const _SupplierFormDialog({this.supplier});

  @override
  ConsumerState<_SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends ConsumerState<_SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _razaoSocialCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cnpjFormatter = MaskTextInputFormatter(mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9A-Za-z]')});
  final _phoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _razaoSocialCtrl.text = widget.supplier!.razaoSocial;
      _cnpjCtrl.text = _cnpjFormatter.maskText(widget.supplier!.cnpj?.replaceAll(RegExp(r'[^0-9A-Za-z]'), '') ?? '');
      _telefoneCtrl.text = _phoneFormatter.maskText(widget.supplier!.telefone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '');
      _emailCtrl.text = widget.supplier!.email ?? '';
    }
  }

  @override
  void dispose() {
    _razaoSocialCtrl.dispose();
    _cnpjCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.supplier != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_outlined : Icons.add_business_rounded,
            color: AppTheme.primaryColor,
            size: 26,
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _razaoSocialCtrl,
                decoration: const InputDecoration(
                  labelText: 'Razão Social *',
                  prefixIcon: Icon(Icons.business_rounded, size: 20),
                  hintText: 'Ex: UnifyTech Distribuidores Ltda',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'A Razão Social é obrigatória';
                  if (v.trim().length < 3) return 'Deve ter pelo menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  prefixIcon: Icon(Icons.badge_rounded, size: 20),
                  hintText: '00.000.000/0000-00',
                ),
                inputFormatters: [_cnpjFormatter],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final clean = _cnpjFormatter.getUnmaskedText();
                  if (clean.length != 14) return 'CNPJ incompleto (deve conter 14 dígitos)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telefoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone_rounded, size: 20),
                        hintText: '(00) 00000-0000',
                      ),
                      inputFormatters: [_phoneFormatter],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final clean = _phoneFormatter.getUnmaskedText();
                        if (clean.length < 10) return 'Telefone incompleto';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded, size: 20),
                        hintText: 'contato@fornecedor.com',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final email = v.trim();
                        if (!email.contains('@') || !email.contains('.')) return 'Email inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isEditing ? 'Salvar' : 'Cadastrar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final req = CriarFornecedorRequest(
      razaoSocial: _razaoSocialCtrl.text.trim(),
      cnpj: _cnpjFormatter.getUnmaskedText(),
      telefone: _phoneFormatter.getUnmaskedText(),
      email: _emailCtrl.text.trim(),
    );

    final bool success;
    final String message;

    try {
      if (widget.supplier != null) {
        final result = await ref.read(suppliersProvider.notifier).atualizar(widget.supplier!.idFornecedor, req);
        success = result.$1;
        message = result.$2;
      } else {
        final result = await ref.read(suppliersProvider.notifier).criar(req);
        success = result.$1;
        message = result.$2;
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
