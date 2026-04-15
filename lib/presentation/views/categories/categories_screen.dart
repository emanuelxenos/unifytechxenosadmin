import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/domain/models/category.dart';
import 'package:unifytechxenosadmin/core/utils/debouncer.dart';
import 'package:unifytechxenosadmin/presentation/providers/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

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
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogCategoria(),
                icon: const Icon(Icons.add),
                label: const Text('Nova Categoria'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search Box
          Container(
            decoration: AppTheme.glassCard(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                _debouncer.run(() => ref.read(categoriesProvider.notifier).setSearch(v));
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar categorias...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(categoriesProvider.notifier).setSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(16),
              child: state.response.when(
                data: (paginated) {
                  final categories = paginated.data;
                  if (categories.isEmpty) {
                    return const Center(child: Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.white70)));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
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
                              rows: categories.map((cat) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(cat.nome, style: const TextStyle(color: Colors.white))),
                                    DataCell(Text(cat.descricao ?? '-', style: const TextStyle(color: Colors.white70))),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                          onPressed: () => _mostrarDialogCategoria(cat),
                                          tooltip: 'Editar',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                                          onPressed: () => _confirmarInativacao(cat),
                                          tooltip: 'Inativar',
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Pagination controls
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${paginated.total} categorias',
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
                                      ? () => ref.read(categoriesProvider.notifier).setPage(paginated.page - 1)
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                  color: Colors.white,
                                ),
                                IconButton(
                                  onPressed: paginated.hasNextPage
                                      ? () => ref.read(categoriesProvider.notifier).setPage(paginated.page + 1)
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

  void _mostrarDialogCategoria([Categoria? categoria]) {
    showDialog(
      context: context,
      builder: (context) => _CategoriaDialog(categoria: categoria),
    );
  }

  void _confirmarInativacao(Categoria cat) {
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
              if (mounted) {
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
