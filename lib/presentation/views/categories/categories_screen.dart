import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/domain/models/category.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';


class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorias',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogCategoria(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Nova Categoria'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(16),
              child: categoriesAsync.when(
                data: (categories) {
                  final activeCategories = categories.where((c) => c.ativo).toList();
                  if (activeCategories.isEmpty) {
                    return const Center(child: Text('Nenhuma categoria encontrada.'));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Descrição')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: activeCategories.map((cat) {
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                cat.nome,
                                style: const TextStyle(color: Colors.white),
                              )),
                              DataCell(Text(
                                cat.descricao ?? '-',
                                style: const TextStyle(color: Colors.white70),
                              )),
                              DataCell(Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                    onPressed: () =>
                                        _mostrarDialogCategoria(context, ref, cat),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                    onPressed: () => _confirmarInativacao(context, ref, cat),
                                    tooltip: 'Inativar',
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'Erro ao carregar categorias: $error',
                    style: const TextStyle(color: AppTheme.accentRed),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogCategoria(BuildContext context, WidgetRef ref, [Categoria? categoria]) {
    showDialog(
      context: context,
      builder: (context) => _CategoriaDialog(categoria: categoria),
    );
  }

  void _confirmarInativacao(BuildContext context, WidgetRef ref, Categoria cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2039),
        title: const Text('Inativar Categoria', style: TextStyle(color: Colors.white)),
        content: Text('Deseja realmente inativar a categoria "${cat.nome}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              Navigator.pop(context);
              final (success, msg) = await ref.read(categoriesProvider.notifier).inativar(cat.idCategoria);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Inativar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CategoriaDialog extends ConsumerStatefulWidget {
  final Categoria? categoria;

  const _CategoriaDialog({this.categoria});

  @override
  ConsumerState<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends ConsumerState<_CategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.categoria?.nome);
    _descricaoController = TextEditingController(text: widget.categoria?.descricao);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final req = CriarCategoriaRequest(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim().isNotEmpty ? _descricaoController.text.trim() : null,
      ordemExibicao: widget.categoria?.ordemExibicao ?? 0,
      categoriaPaiId: widget.categoria?.categoriaPaiId,
    );

    final notifier = ref.read(categoriesProvider.notifier);
    bool success;
    String msg;

    if (widget.categoria == null) {
      final res = await notifier.criar(req);
      success = res.$1;
      msg = res.$2;
    } else {
      final res = await notifier.atualizar(widget.categoria!.idCategoria, req);
      success = res.$1;
      msg = res.$2;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppTheme.accentGreen : AppTheme.accentRed,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoria != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria',
          style: const TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val == null || val.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvar,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }
}
