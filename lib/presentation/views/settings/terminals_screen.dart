import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';
import 'package:unifytechxenosadmin/presentation/providers/caixa_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class TerminalsScreen extends ConsumerStatefulWidget {
  const TerminalsScreen({super.key});

  @override
  ConsumerState<TerminalsScreen> createState() => _TerminalsScreenState();
}

class _TerminalsScreenState extends ConsumerState<TerminalsScreen> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  void _showPasswordDialog() {
    final TextEditingController passCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog( // Nomeado como dialogContext para não confundir
        title: const Row(
          children: [
            Icon(Icons.lock_person_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Acesso Restrito'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Esta área é restrita ao Suporte Técnico. Digite a senha master para prosseguir.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passCtrl,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Senha Técnica',
                prefixIcon: Icon(Icons.key_rounded),
              ),
              onSubmitted: (val) => _verify(dialogContext, val), // Passa o context do dialog
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Fecha o dialog com o context correto
              context.go('/'); // Volta para o dashboard
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _verify(dialogContext, passCtrl.text), // Passa o context do dialog
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _verify(BuildContext dialogCtx, String pass) {
    if (pass == 'suporte2026@xenos') {
      setState(() => _isUnlocked = true);
      Navigator.pop(dialogCtx); // Agora fecha apenas o DIALOG
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha de suporte inválida!'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Container(
        color: const Color(0xFF0F1225), // Mesma cor do fundo do app para não ficar preto
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text(
                'Acesso Restrito ao Suporte',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Aguardando desbloqueio...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final terminalsAsync = ref.watch(physicalTerminalsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terminais de Venda',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gerencie os pontos de venda (PDVs) da sua loja',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showTerminalForm(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Novo Terminal'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  onPressed: () => ref.read(physicalTerminalsProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar lista',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: terminalsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.accentRed),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar terminais: $err'),
                    ],
                  ),
                ),
                data: (terminals) {
                  if (terminals.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        icon: Icons.computer_rounded,
                        title: 'Nenhum terminal cadastrado',
                        subtitle: 'Clique no botão acima para adicionar seu primeiro PDV',
                      ),
                    );
                  }

                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: GridView.builder(
                      controller: _scrollController,
                      primary: false, // Importante: desativa o scroll controller padrão
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: terminals.length,
                      itemBuilder: (context, index) {
                        final terminal = terminals[index];
                        return _TerminalCard(terminal: terminal);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerminalForm(BuildContext context, [CaixaFisico? terminal]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TerminalFormDialog(terminal: terminal),
    );
  }
}

class _TerminalCard extends ConsumerWidget {
  final CaixaFisico terminal;

  const _TerminalCard({required this.terminal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnline = terminal.dataUltimoUso != null &&
        DateTime.now().difference(terminal.dataUltimoUso!).inMinutes < 5;

    return Container(
      decoration: AppTheme.glassCard(
        backgroundColor: terminal.ativo ? null : Colors.grey.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.computer_rounded,
                  color: terminal.ativo ? AppTheme.primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terminal.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Código: ${terminal.codigo}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: terminal.ativo ? 'ATIVO' : 'INATIVO',
                color: terminal.ativo ? AppTheme.accentGreen : Colors.grey,
              ),
            ],
          ),
          const Spacer(),
          if (terminal.descricao != null && terminal.descricao!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                terminal.descricao!,
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                terminal.localizacao ?? 'Não informada',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const Spacer(),
              if (isOnline)
                const Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Colors.green),
                    SizedBox(width: 6),
                    Text('Online',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )
              else
                Text(
                  terminal.dataUltimoUso != null
                      ? 'Visto em: ${Formatters.date(terminal.dataUltimoUso!)}'
                      : 'Nunca utilizado',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Excluir'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _showEditForm(context),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TerminalFormDialog(terminal: terminal),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Terminal'),
        content: Text('Deseja realmente excluir o terminal "${terminal.nome}"? Se houver histórico de vendas, ele será apenas inativado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final success = await ref.read(physicalTerminalsProvider.notifier).excluir(terminal.idCaixaFisico);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terminal removido com sucesso')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _TerminalFormDialog extends ConsumerStatefulWidget {
  final CaixaFisico? terminal;

  const _TerminalFormDialog({this.terminal});

  @override
  ConsumerState<_TerminalFormDialog> createState() => _TerminalFormDialogState();
}

class _TerminalFormDialogState extends ConsumerState<_TerminalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoCtrl;
  late TextEditingController _nomeCtrl;
  late TextEditingController _descricaoCtrl;
  late TextEditingController _localizacaoCtrl;
  late TextEditingController _setorCtrl;
  bool _ativo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codigoCtrl = TextEditingController(text: widget.terminal?.codigo);
    _nomeCtrl = TextEditingController(text: widget.terminal?.nome);
    _descricaoCtrl = TextEditingController(text: widget.terminal?.descricao);
    _localizacaoCtrl = TextEditingController(text: widget.terminal?.localizacao);
    _setorCtrl = TextEditingController(text: widget.terminal?.setor);
    _ativo = widget.terminal?.ativo ?? true;
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _localizacaoCtrl.dispose();
    _setorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.terminal != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Terminal' : 'Novo Terminal'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _codigoCtrl,
                        enabled: !isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Código do Terminal',
                          hintText: 'Ex: CAIXA-01',
                          prefixIcon: Icon(Icons.qr_code_rounded),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome de Exibição',
                          hintText: 'Ex: Caixa Frente de Loja',
                          prefixIcon: Icon(Icons.badge_rounded),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / Observações',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _localizacaoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Localização',
                          hintText: 'Ex: Balcão Principal',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _setorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Setor',
                          hintText: 'Ex: Checkout',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isEditing) ...[
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Terminal Ativo'),
                    subtitle: const Text('Determina se este terminal pode realizar vendas'),
                    value: _ativo,
                    onChanged: (v) => setState(() => _ativo = v),
                    secondary: Icon(
                      _ativo ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                      color: _ativo ? Colors.green : Colors.grey,
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEditing ? 'Salvar Alterações' : 'Criar Terminal'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'codigo': _codigoCtrl.text,
      'nome': _nomeCtrl.text,
      'descricao': _descricaoCtrl.text,
      'localizacao': _localizacaoCtrl.text,
      'setor': _setorCtrl.text,
      if (widget.terminal != null) 'ativo': _ativo,
    };

    final success = widget.terminal != null
        ? await ref.read(physicalTerminalsProvider.notifier).atualizar(widget.terminal!.idCaixaFisico, data)
        : await ref.read(physicalTerminalsProvider.notifier).criar(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.terminal != null ? 'Terminal atualizado' : 'Terminal criado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar terminal. Verifique se o código já existe.')),
        );
      }
    }
  }
}
