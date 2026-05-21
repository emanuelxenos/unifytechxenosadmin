import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/debouncer.dart';
import 'package:unifytechxenosadmin/domain/models/customer.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/customer_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _debouncer = Debouncer(milliseconds: 300);
  final _searchController = TextEditingController();
  bool _showKPIs = true;
  final Set<int> _selectedIds = {};

  void _onSort(String field) {
    final currentField = ref.read(customerSortFieldProvider);
    final currentAsc = ref.read(customerSortAscendingProvider);
    if (currentField == field) {
      ref.read(customerSortAscendingProvider.notifier).state = !currentAsc;
    } else {
      ref.read(customerSortFieldProvider.notifier).state = field;
      ref.read(customerSortAscendingProvider.notifier).state = true;
    }
    ref.read(customerPageProvider.notifier).state = 0; // reset to page 0
  }

  int? _getSortColumnIndex(String? field) {
    switch (field) {
      case 'nome': return 0;
      case 'tipo_pessoa': return 1;
      case 'limite_credito': return 4;
      case 'saldo_devedor': return 5;
      case 'data_cadastro': return 6;
      default: return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.text = ref.read(customerSearchProvider);
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildKPIRow(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(customerStatsNotifierProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Clientes Ativos',
                value: '${stats.totalClientes}',
                icon: Icons.people_rounded,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Saldo Devedor Total',
                value: 'R\$ ${stats.saldoDevedorTotal.toStringAsFixed(2)}',
                icon: Icons.money_off_rounded,
                color: AppTheme.accentRed,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Limite de Crédito Total',
                value: 'R\$ ${stats.limiteCreditoTotal.toStringAsFixed(2)}',
                icon: Icons.credit_card_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                context,
                title: 'Clientes Inadimplentes',
                value: '${stats.totalInadimplentes}',
                icon: Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.glassCard().copyWith(
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar(BuildContext context) {
    return Container(
      decoration: AppTheme.glassCard().copyWith(
        color: const Color(0xFF1F2244).withValues(alpha: 0.95),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_box_outlined, color: AppTheme.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                '${_selectedIds.length} selecionado(s)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.blueAccent),
                label: const Text('Reajustar Limite', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _BulkLimitAdjustmentDialog(
                      ids: _selectedIds.toList(),
                      onSuccess: () {
                        setState(() {
                          _selectedIds.clear();
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: const Icon(Icons.person_off_outlined, size: 14, color: AppTheme.accentRed),
                label: const Text('Inativar Selecionados', style: TextStyle(color: AppTheme.accentRed, fontSize: 13)),
                onPressed: () => _confirmBulkInactivate(context),
              ),
              const SizedBox(width: 16),
              const SizedBox(
                height: 24,
                child: VerticalDivider(color: Colors.white24, width: 1, thickness: 1),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                tooltip: 'Limpar seleção',
                onPressed: () {
                  setState(() {
                    _selectedIds.clear();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBulkInactivate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2039),
        title: const Text('Inativar Clientes em Lote', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deseja inativar os ${_selectedIds.length} clientes selecionados?\nEles não aparecerão mais nas novas vendas.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Inativar Todos', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final (success, message) = await ref
          .read(customersProvider.notifier)
          .inativarEmLote(_selectedIds.toList());
      if (context.mounted) {
        if (success) {
          AppNotifications.showSuccess(context, message);
          setState(() {
            _selectedIds.clear();
          });
        } else {
          AppNotifications.showError(context, message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customersAsync = ref.watch(customersProvider);
    final filtered = ref.watch(filteredCustomersProvider);
    final page = ref.watch(customerPageProvider);
    final itemsPerPage = ref.watch(customerItemsPerPageProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Clientes',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          _showKPIs ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => _showKPIs = !_showKPIs),
                        tooltip: _showKPIs ? 'Ocultar Indicadores' : 'Mostrar Indicadores',
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCustomerForm(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Novo Cliente'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KPI indicators with animation
              AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildKPIRow(context, ref),
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _showKPIs ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
              ),

              // Toolbar: Search + Inactive toggle
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: AppTheme.glassCard(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          _debouncer.run(() {
                            if (mounted) {
                              ref.read(customerSearchProvider.notifier).setQuery(v);
                              ref.read(customerPageProvider.notifier).state = 0;
                            }
                          });
                        },
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
                    onSelected: (v) {
                      ref.read(customerInactivesProvider.notifier).set(v);
                      ref.read(customerPageProvider.notifier).state = 0;
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Table Card
              Expanded(
                child: Container(
                  decoration: AppTheme.glassCard(),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
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
                          data: (res) {
                            // Dynamically adjust page index if it goes out of bounds
                            final totalPages = (res.total / itemsPerPage).ceil();
                            if (page >= totalPages && totalPages > 0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  ref.read(customerPageProvider.notifier).state = totalPages - 1;
                                }
                              });
                            }

                            if (filtered.isEmpty) {
                              return const EmptyState(
                                icon: Icons.people_alt_outlined,
                                title: 'Nenhum cliente encontrado',
                                subtitle: 'Cadastre clientes para utilizá-los nas vendas e no crediário.',
                              );
                            }
                            return SizedBox.expand(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    showCheckboxColumn: true,
                                    headingTextStyle: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    sortColumnIndex: _getSortColumnIndex(ref.watch(customerSortFieldProvider)),
                                    sortAscending: ref.watch(customerSortAscendingProvider),
                                    onSelectAll: (isSelected) {
                                      setState(() {
                                        if (isSelected == true) {
                                          for (final c in filtered) {
                                            _selectedIds.add(c.idCliente);
                                          }
                                        } else {
                                          for (final c in filtered) {
                                            _selectedIds.remove(c.idCliente);
                                          }
                                        }
                                      });
                                    },
                                    columns: [
                                      DataColumn(
                                        label: const Text('NOME'),
                                        onSort: (_, __) => _onSort('nome'),
                                      ),
                                      DataColumn(
                                        label: const Text('TIPO'),
                                        onSort: (_, __) => _onSort('tipo_pessoa'),
                                      ),
                                      const DataColumn(label: Text('CPF / CNPJ')),
                                      const DataColumn(label: Text('TELEFONE')),
                                      DataColumn(
                                        label: const Text('LIMITE CRÉDITO'),
                                        onSort: (_, __) => _onSort('limite_credito'),
                                      ),
                                      DataColumn(
                                        label: const Text('SALDO DEVEDOR'),
                                        onSort: (_, __) => _onSort('saldo_devedor'),
                                      ),
                                      DataColumn(
                                        label: const Text('CADASTRO'),
                                        onSort: (_, __) => _onSort('data_cadastro'),
                                      ),
                                      const DataColumn(label: Text('STATUS')),
                                      const DataColumn(label: Text('AÇÕES')),
                                    ],
                                    rows: filtered
                                        .map((c) => _buildRow(context, ref, c))
                                        .toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Pagination Footer
                      customersAsync.maybeWhen(
                        data: (res) {
                          if (res.total > 0) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(color: Colors.white10, height: 1),
                                _buildPaginationFooter(context, res.total),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedIds.isNotEmpty)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildBulkActionsBar(context),
          ),
      ],
    );
  }

  Widget _buildPaginationFooter(BuildContext context, int totalItems) {
    final page = ref.watch(customerPageProvider);
    final itemsPerPage = ref.watch(customerItemsPerPageProvider);
    final totalPages = (totalItems / itemsPerPage).ceil();

    final startItem = page * itemsPerPage + 1;
    final endItem = math.min((page + 1) * itemsPerPage, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items Per Page Selector
          Row(
            children: [
              const Text(
                'Itens por página:',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFF1C2039),
                ),
                child: DropdownButton<int>(
                  value: itemsPerPage,
                  dropdownColor: const Color(0xFF1C2039),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: [5, 10, 15, 25, 50].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      ref.read(customerItemsPerPageProvider.notifier).state = newValue;
                      ref.read(customerPageProvider.notifier).state = 0; // reset to first page
                    }
                  },
                ),
              ),
            ],
          ),

          // Page indicators and controls
          Row(
            children: [
              Text(
                'Exibindo $startItem-$endItem de $totalItems',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 24),
              // Navigation Buttons
              IconButton(
                icon: const Icon(Icons.first_page_rounded, color: Colors.white70),
                tooltip: 'Primeira Página',
                onPressed: page > 0
                    ? () => ref.read(customerPageProvider.notifier).state = 0
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                tooltip: 'Página Anterior',
                onPressed: page > 0
                    ? () => ref.read(customerPageProvider.notifier).state = page - 1
                    : null,
              ),
              Text(
                '${page + 1} / $totalPages',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                tooltip: 'Próxima Página',
                onPressed: page < totalPages - 1
                    ? () => ref.read(customerPageProvider.notifier).state = page + 1
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page_rounded, color: Colors.white70),
                tooltip: 'Última Página',
                onPressed: page < totalPages - 1
                    ? () => ref.read(customerPageProvider.notifier).state = totalPages - 1
                    : null,
              ),
            ],
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
      selected: _selectedIds.contains(c.idCliente),
      onSelectChanged: (selected) {
        setState(() {
          if (selected == true) {
            _selectedIds.add(c.idCliente);
          } else {
            _selectedIds.remove(c.idCliente);
          }
        });
      },
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
        DataCell(Text(
          c.dataCadastro != null
              ? '${c.dataCadastro!.day.toString().padLeft(2, '0')}/${c.dataCadastro!.month.toString().padLeft(2, '0')}/${c.dataCadastro!.year}'
              : '-',
          style: const TextStyle(color: Colors.white70),
        )),
        DataCell(StatusChip.fromStatus(c.ativo ? 'ativo' : 'inativo')),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.history_rounded, size: 18, color: Colors.blueAccent),
              tooltip: 'Histórico',
              onPressed: () => _showCustomerHistory(context, ref, c),
            ),
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

  void _showCustomerHistory(BuildContext context, WidgetRef ref, Cliente c) {
    showDialog(
      context: context,
      builder: (context) => _CustomerHistoryDialog(cliente: c),
    );
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

// ---------------------------------------------------------------------------
// CRM Features (Amortizar & History)
// ---------------------------------------------------------------------------

class _PagarVendaDialog extends ConsumerStatefulWidget {
  final Cliente cliente;
  final Venda venda;
  const _PagarVendaDialog({required this.cliente, required this.venda});

  @override
  ConsumerState<_PagarVendaDialog> createState() => _PagarVendaDialogState();
}

class _PagarVendaDialogState extends ConsumerState<_PagarVendaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();
  bool _saving = false;
  late double saldoDevedor;

  @override
  void initState() {
    super.initState();
    saldoDevedor = widget.venda.valorTotal - widget.venda.valorPago;
    _valorCtrl.text = saldoDevedor.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C2039),
      title: const Text('Pagar Venda', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Venda: ${widget.venda.numeroVenda}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Saldo a Pagar: R\$ ${saldoDevedor.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor a Pagar (R\$)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obrigatório';
                  final valor = double.tryParse(v.replaceAll(',', '.'));
                  if (valor == null || valor <= 0) return 'Valor inválido';
                  if (valor > saldoDevedor) {
                    return 'Não pode ser maior que o saldo da venda';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Confirmar Pagamento'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final valor = double.tryParse(_valorCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;
    final (success, message) = await ref.read(customersProvider.notifier).amortizarDivida(widget.cliente.idCliente, widget.venda.idVenda, valor);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context, success);
      if (success) {
        AppNotifications.showSuccess(context, message);
        ref.invalidate(customerHistoryProvider(widget.cliente.idCliente));
        ref.invalidate(customerAmortizationsProvider(widget.cliente.idCliente));
      } else {
        AppNotifications.showError(context, message);
      }
    }
  }
}

class _CustomerHistoryDialog extends ConsumerWidget {
  final Cliente cliente;
  const _CustomerHistoryDialog({required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1C2039),
        title: Row(
          children: [
            const Icon(Icons.account_box_rounded, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text('Histórico - ${cliente.nome}', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 650,
          height: 450,
          child: Column(
            children: [
              const TabBar(
                indicatorColor: AppTheme.primaryColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: [
                  Tab(text: 'Compras e Dívidas', icon: Icon(Icons.shopping_bag_outlined)),
                  Tab(text: 'Pagamentos Realizados', icon: Icon(Icons.payments_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildComprasTab(context, ref),
                    _buildPagamentosTab(ref),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildComprasTab(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(customerHistoryProvider(cliente.idCliente));
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppTheme.accentRed))),
      data: (vendas) {
        if (vendas.isEmpty) {
          return const Center(child: Text('Nenhuma compra encontrada para este cliente.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: vendas.length,
          itemBuilder: (context, index) {
            final venda = vendas[index];
            final saldo = venda.valorTotal - venda.valorPago;
            final isPendente = saldo > 0 && venda.status == 'concluida';

            return Card(
              color: Colors.white.withValues(alpha: 0.05),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: venda.status == 'concluida' ? Colors.green.withValues(alpha: 0.2) : AppTheme.accentRed.withValues(alpha: 0.2),
                  child: Icon(
                    venda.status == 'concluida' ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: venda.status == 'concluida' ? Colors.green : AppTheme.accentRed,
                  ),
                ),
                title: Text('${venda.numeroVenda} - R\$ ${venda.valorTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data: ${venda.dataVenda.day.toString().padLeft(2, '0')}/${venda.dataVenda.month.toString().padLeft(2, '0')}/${venda.dataVenda.year}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    if (isPendente)
                      Text('Falta pagar: R\$ ${saldo.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                trailing: isPendente
                    ? ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => _PagarVendaDialog(cliente: cliente, venda: venda),
                        ),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pagar'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
                      )
                    : Text(
                        venda.status == 'concluida' ? 'Quitado' : 'Cancelada',
                        style: TextStyle(color: venda.status == 'concluida' ? Colors.green : AppTheme.accentRed, fontWeight: FontWeight.bold),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPagamentosTab(WidgetRef ref) {
    final amortizationsAsync = ref.watch(customerAmortizationsProvider(cliente.idCliente));
    return amortizationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e', style: const TextStyle(color: AppTheme.accentRed))),
      data: (pagamentos) {
        if (pagamentos.isEmpty) {
          return const Center(child: Text('Nenhum pagamento registrado.', style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: pagamentos.length,
          itemBuilder: (context, index) {
            final pag = pagamentos[index];
            return Card(
              color: Colors.white.withValues(alpha: 0.05),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  child: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                ),
                title: Text('Ref. ${pag.numeroVenda}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Recebido em: ${pag.dataPagamento.day.toString().padLeft(2, '0')}/${pag.dataPagamento.month.toString().padLeft(2, '0')}/${pag.dataPagamento.year}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: Text(
                  '+ R\$ ${pag.valor.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BulkLimitAdjustmentDialog extends StatefulWidget {
  final List<int> ids;
  final VoidCallback onSuccess;

  const _BulkLimitAdjustmentDialog({
    super.key,
    required this.ids,
    required this.onSuccess,
  });

  @override
  State<_BulkLimitAdjustmentDialog> createState() => _BulkLimitAdjustmentDialogState();
}

class _BulkLimitAdjustmentDialogState extends State<_BulkLimitAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _porcentagemCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  bool _saving = false;
  String _tipoReajuste = 'porcentagem'; // 'porcentagem' or 'valor'

  @override
  void dispose() {
    _porcentagemCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C2039),
          title: Text(
            'Ajustar Limites (${widget.ids.length} selecionados)',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione a forma de reajuste:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('Percentual (%)', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('Ex: 10 para aumentar 10%, -5 para diminuir 5%', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    value: 'porcentagem',
                    groupValue: _tipoReajuste,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _tipoReajuste = val;
                          _valorCtrl.clear();
                        });
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Valor em Reais (R\$)', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('Ex: 100 para aumentar R\$ 100, -50 para diminuir R\$ 50', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    value: 'valor',
                    groupValue: _tipoReajuste,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _tipoReajuste = val;
                          _porcentagemCtrl.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_tipoReajuste == 'porcentagem')
                    TextFormField(
                      controller: _porcentagemCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Ajuste Percentual (%)',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Ex: 10 ou -5',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Obrigatório';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  if (_tipoReajuste == 'valor')
                    TextFormField(
                      controller: _valorCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Ajuste de Valor (R\$)',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Ex: 150 ou -50',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Obrigatório';
                        final val = double.tryParse(v.replaceAll(',', '.'));
                        if (val == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: _saving ? null : () => _submit(ref),
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Aplicar Reajuste'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final String valStr = _tipoReajuste == 'porcentagem' ? _porcentagemCtrl.text : _valorCtrl.text;
    final double valor = double.tryParse(valStr.trim().replaceAll(',', '.')) ?? 0.0;

    final (success, message) = await ref
        .read(customersProvider.notifier)
        .ajustarLimitesEmLote(widget.ids, _tipoReajuste, valor);

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        AppNotifications.showSuccess(context, message);
        Navigator.pop(context);
        widget.onSuccess();
      } else {
        AppNotifications.showError(context, message);
      }
    }
  }
}

