import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => ref.read(supplierSearchProvider.notifier).setQuery(v),
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
                onSelected: (v) => ref.read(supplierInactivesProvider.notifier).set(v),
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
                return SingleChildScrollView(
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
                    rows: filtered.map((s) => DataRow(
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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _razaoSocialCtrl.text = widget.supplier!.razaoSocial;
      _cnpjCtrl.text = widget.supplier!.cnpj ?? '';
      _telefoneCtrl.text = widget.supplier!.telefone ?? '';
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
    final isEditing = widget.supplier != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _razaoSocialCtrl,
                decoration: const InputDecoration(labelText: 'Razão Social *'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjCtrl,
                decoration: const InputDecoration(labelText: 'CNPJ'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telefoneCtrl,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
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
          child: _saving ? const CircularProgressIndicator() : Text(isEditing ? 'Salvar' : 'Cadastrar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final req = CriarFornecedorRequest(
      razaoSocial: _razaoSocialCtrl.text.trim(),
      cnpj: _cnpjCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    final bool success;
    final String message;

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
        SnackBar(content: Text(message), backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed),
      );
    }
  }
}
