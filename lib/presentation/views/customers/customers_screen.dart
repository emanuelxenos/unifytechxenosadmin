import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/domain/models/customer.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/customer_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customersAsync = ref.watch(customersProvider);
    final filtered = ref.watch(filteredCustomersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clientes',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCustomerForm(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Novo Cliente'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Toolbar: Search + Inactive toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: AppTheme.glassCard(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (v) =>
                        ref.read(customerSearchProvider.notifier).setQuery(v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Buscar cliente por nome, CPF/CNPJ ou email...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Mostrar Inativos'),
                selected: ref.watch(customerInactivesProvider),
                onSelected: (v) =>
                    ref.read(customerInactivesProvider.notifier).set(v),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: Container(
              decoration: AppTheme.glassCard(),
              clipBehavior: Clip.antiAlias,
              child: customersAsync.when(
                loading: () => const LoadingOverlay(message: 'Carregando clientes...'),
                error: (e, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Erro ao carregar',
                  subtitle: e.toString(),
                  action: ElevatedButton(
                    onPressed: () =>
                        ref.read(customersProvider.notifier).refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ),
                data: (_) {
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_alt_outlined,
                      title: 'Nenhum cliente encontrado',
                      subtitle: 'Cadastre clientes para utilizá-los nas vendas e no crediário.',
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingTextStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text('NOME')),
                          DataColumn(label: Text('TIPO')),
                          DataColumn(label: Text('CPF / CNPJ')),
                          DataColumn(label: Text('TELEFONE')),
                          DataColumn(label: Text('LIMITE CRÉDITO')),
                          DataColumn(label: Text('SALDO DEVEDOR')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('AÇÕES')),
                        ],
                        rows: filtered
                            .map((c) => _buildRow(context, ref, c))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, WidgetRef ref, Cliente c) {
    final authState = ref.watch(authProvider);
    final perfil = authState.user?.perfil ?? '';
    final podeEditarLimite =
        perfil == 'admin' || perfil == 'gerente';

    return DataRow(
      cells: [
        DataCell(Text(c.nome, style: const TextStyle(color: Colors.white))),
        DataCell(Text(
          c.tipoPessoa == 'J' ? 'Pessoa Jurídica' : 'Pessoa Física',
          style: const TextStyle(color: Colors.white70),
        )),
        DataCell(Text(
            _formatDocumento(c.tipoPessoa, c.cpfCnpj),
            style: const TextStyle(color: Colors.white70))),  
        DataCell(Text(c.telefone ?? '-',
            style: const TextStyle(color: Colors.white70))),
        DataCell(_LimiteBadge(
          valor: c.limiteCredito,
          canEdit: podeEditarLimite,
        )),
        DataCell(_SaldoDevedorBadge(valor: c.saldoDevedor)),
        DataCell(StatusChip.fromStatus(c.ativo ? 'ativo' : 'inativo')),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Editar',
              onPressed: () => _showCustomerForm(context, cliente: c),
            ),
            if (c.ativo)
              IconButton(
                icon: const Icon(Icons.person_off_outlined,
                    size: 18, color: AppTheme.accentRed),
                tooltip: 'Inativar',
                onPressed: () => _confirmInactivate(context, ref, c),
              ),
          ],
        )),
      ],
    );
  }

  void _showCustomerForm(BuildContext context, {Cliente? cliente}) {
    showDialog(
      context: context,
      builder: (context) => _CustomerFormDialog(cliente: cliente),
    );
  }

  Future<void> _confirmInactivate(
      BuildContext context, WidgetRef ref, Cliente cliente) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2039),
        title: const Text('Inativar Cliente',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja inativar o cliente "${cliente.nome}"?\nEle não aparecerá mais nas novas vendas.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed),
            child: const Text('Inativar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final (success, message) = await ref
          .read(customersProvider.notifier)
          .inativar(cliente.idCliente);
      if (context.mounted) {
        AppNotifications.showSuccess(context, message);
        if (!success) AppNotifications.showError(context, message);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

/// Aplica a máscara de CPF (###.###.###-##) ou CNPJ (##.###.###/####-##)
/// ao valor bruto armazenado no banco (sem pontuação).
String _formatDocumento(String tipoPessoa, String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final v = raw.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');

  if (tipoPessoa == 'F') {
    // CPF: 11 dígitos → ###.###.###-##
    if (v.length != 11) return raw;
    return '${v.substring(0, 3)}.${v.substring(3, 6)}.${v.substring(6, 9)}-${v.substring(9)}';
  } else {
    // CNPJ: 14 chars → ##.###.###/####-##
    if (v.length != 14) return raw;
    return '${v.substring(0, 2)}.${v.substring(2, 5)}.${v.substring(5, 8)}/${v.substring(8, 12)}-${v.substring(12)}';
  }
}

// ---------------------------------------------------------------------------
// Auxiliary display widgets
// ---------------------------------------------------------------------------

class _LimiteBadge extends StatelessWidget {
  final double valor;
  final bool canEdit;
  const _LimiteBadge({required this.valor, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Text(
      'R\$ ${valor.toStringAsFixed(2)}',
      style: TextStyle(
        color: canEdit ? Colors.white : Colors.white54,
        fontWeight: canEdit ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _SaldoDevedorBadge extends StatelessWidget {
  final double valor;
  const _SaldoDevedorBadge({required this.valor});

  @override
  Widget build(BuildContext context) {
    final color = valor > 0 ? AppTheme.accentRed : Colors.white54;
    return Text(
      'R\$ ${valor.toStringAsFixed(2)}',
      style: TextStyle(
        color: color,
        fontWeight: valor > 0 ? FontWeight.w700 : FontWeight.normal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Customer Form Dialog
// ---------------------------------------------------------------------------

class _CustomerFormDialog extends ConsumerStatefulWidget {
  final Cliente? cliente;
  const _CustomerFormDialog({this.cliente});

  @override
  ConsumerState<_CustomerFormDialog> createState() =>
      _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<_CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCnpjCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _limiteCreditoCtrl = TextEditingController();

  final _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', filter: {'#': RegExp(r'[0-9]')});
  final _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {'#': RegExp(r'[0-9]')});
  final _cnpjFormatter = MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: {'#': RegExp(r'[0-9A-Za-z]')});

  String _tipoPessoa = 'F';
  bool _saving = false;

  MaskTextInputFormatter get _docFormatter =>
      _tipoPessoa == 'F' ? _cpfFormatter : _cnpjFormatter;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    if (c != null) {
      _nomeCtrl.text = c.nome;
      _tipoPessoa = c.tipoPessoa; // 'F' or 'J'
      _cpfCnpjCtrl.text = c.cpfCnpj ?? '';
      _telefoneCtrl.text =
          _phoneFormatter.maskText(c.telefone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '');
      _emailCtrl.text = c.email ?? '';
      _limiteCreditoCtrl.text = c.limiteCredito.toStringAsFixed(2);
    } else {
      _limiteCreditoCtrl.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _telefoneCtrl.dispose();
    _emailCtrl.dispose();
    _limiteCreditoCtrl.dispose();
    super.dispose();
  }

  bool get _canEditLimite {
    final authState = ref.watch(authProvider);
    final perfil = authState.user?.perfil ?? '';
    return perfil == 'admin' || perfil == 'gerente';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cliente != null;
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: Text(
        isEditing ? 'Editar Cliente' : 'Novo Cliente',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo Pessoa
                const Text('Tipo de Pessoa',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _TipoButton(
                        label: 'Pessoa Física',
                        selected: _tipoPessoa == 'F',
                        onTap: () => setState(() {
                          _tipoPessoa = 'F';
                          _cpfCnpjCtrl.clear();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TipoButton(
                        label: 'Pessoa Jurídica',
                        selected: _tipoPessoa == 'J',
                        onTap: () => setState(() {
                          _tipoPessoa = 'J';
                          _cpfCnpjCtrl.clear();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nome
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: InputDecoration(
                    labelText: _tipoPessoa == 'J'
                        ? 'Razão Social *'
                        : 'Nome Completo *',
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 12),
                // CPF / CNPJ
                TextFormField(
                  controller: _cpfCnpjCtrl,
                  decoration: InputDecoration(
                    labelText: _tipoPessoa == 'F' ? 'CPF' : 'CNPJ',
                    hintText: _tipoPessoa == 'F'
                        ? '000.000.000-00'
                        : '00.000.000/0000-00',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [_docFormatter],
                  key: ValueKey(_tipoPessoa),
                ),
                const SizedBox(height: 12),
                // Telefone + Email
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _telefoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(00) 00000-0000',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                        style: const TextStyle(color: Colors.white),
                        inputFormatters: [_phoneFormatter],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Limite de Crédito
                TextFormField(
                  controller: _limiteCreditoCtrl,
                  enabled: _canEditLimite,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Limite de Crédito (R\$)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    helperText: _canEditLimite
                        ? null
                        : 'Apenas gerentes e admins podem alterar o limite',
                    helperStyle: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obrigatório';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEditing ? 'Salvar' : 'Cadastrar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final limite = double.tryParse(
            _limiteCreditoCtrl.text.trim().replaceAll(',', '.')) ??
        0.0;

    // Extrair texto limpo diretamente dos controllers (funciona tanto no
    // fluxo de criação quanto no de edição, independente do formatter interno).
    final cpfCnpjRaw =
        _cpfCnpjCtrl.text.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final telefoneRaw =
        _telefoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    final req = CriarClienteRequest(
      nome: _nomeCtrl.text.trim(),
      tipoPessoa: _tipoPessoa,
      cpfCnpj: cpfCnpjRaw.isEmpty ? null : cpfCnpjRaw,
      telefone: telefoneRaw.isEmpty ? null : telefoneRaw,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      limiteCredito: limite,
    );

    final bool success;
    final String message;

    if (widget.cliente != null) {
      final result = await ref
          .read(customersProvider.notifier)
          .atualizar(widget.cliente!.idCliente, req);
      success = result.$1;
      message = result.$2;
    } else {
      final result =
          await ref.read(customersProvider.notifier).criar(req);
      success = result.$1;
      message = result.$2;
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      if (success) {
        AppNotifications.showSuccess(context, message);
      } else {
        AppNotifications.showError(context, message);
      }
    }
  }
}

class _TipoButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TipoButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppTheme.primaryColor : Colors.white70,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
