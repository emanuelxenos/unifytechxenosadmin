import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/finance_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/presentation/providers/auth_provider.dart';
import 'package:unifytechxenosadmin/domain/models/account_payable.dart';
import 'package:unifytechxenosadmin/domain/models/account_receivable.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});
  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pagarController = ScrollController();
  final _receberController = ScrollController();
  final _fluxoController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pagarController.dispose();
    _receberController.dispose();
    _fluxoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fluxoAsync = ref.watch(cashFlowProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestão Financeira', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text('Monitoramento de faturamento e despesas administrativas', style: theme.textTheme.bodyMedium),
                  ],
                ),
                IconButton.filled(
                  onPressed: () {
                    ref.read(cashFlowProvider.notifier).refresh();
                    ref.read(accountsPayableProvider.notifier).refresh();
                    ref.read(accountsReceivableProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar Dados',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dashboard KPIs
            fluxoAsync.when(
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
              data: (resp) => Row(
                children: [
                  Expanded(child: _KpiCard(
                    title: 'Entradas (Vendas)',
                    value: resp.totalEntrada,
                    icon: Icons.trending_up,
                    color: AppTheme.accentGreen,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _KpiCard(
                    title: 'Saídas (Compras)',
                    value: resp.totalSaida,
                    icon: Icons.trending_down,
                    color: AppTheme.accentRed,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _KpiCard(
                    title: 'Resultado Líquido',
                    value: resp.saldo,
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Contas a Pagar'),
                  Tab(text: 'Contas a Receber'),
                  Tab(text: 'Extrato de Fluxo'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ContasPagarTab(controller: _pagarController),
                  _ContasReceberTab(controller: _receberController),
                  _FluxoCaixaTab(controller: _fluxoController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.currency(value),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContasPagarTab extends ConsumerWidget {
// ... (rest elements remain mostly same but updated to be ReadOnly style)
  final ScrollController controller;
  const _ContasPagarTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contasAsync = ref.watch(accountsPayableProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: contasAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (contas) {
          if (contas.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas a pagar');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('FORNECEDOR')),
                      DataColumn(label: Text('VENCIMENTO')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('AÇÕES')),
                    ],
                    rows: contas.map((c) {
                      final user = ref.watch(authProvider).user;
                      final bool canManage = user?.perfil == 'admin' || user?.perfil == 'gerente';
                      
                      return DataRow(cells: [
                        DataCell(Text(c.descricao)),
                        DataCell(Text(c.fornecedorNome ?? '-')),
                        DataCell(Text(
                          Formatters.date(c.dataVencimento),
                          style: TextStyle(color: c.isVencida ? AppTheme.accentRed : null),
                        )),
                        DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(StatusChip.fromStatus(c.status)),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              Icons.payments_outlined, 
                              color: (c.status == 'aberta' && canManage) ? AppTheme.primaryColor : Colors.grey.withOpacity(0.5)
                            ),
                            tooltip: canManage ? 'Pagar Conta' : 'Acesso Restrito ao Admin',
                            onPressed: (c.status == 'aberta' && canManage)
                                ? () => showDialog(context: context, builder: (_) => _PaymentDialog(conta: c))
                                : null,
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContasReceberTab extends ConsumerWidget {
  final ScrollController controller;
  const _ContasReceberTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contasAsync = ref.watch(accountsReceivableProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: contasAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (contas) {
          if (contas.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline, title: 'Sem contas a receber');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DESCRIÇÃO')),
                      DataColumn(label: Text('CLIENTE')),
                      DataColumn(label: Text('VENCIMENTO')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('AÇÕES')),
                    ],
                    rows: contas.map((c) {
                      final bool isAtrasada = c.isVencida;
                      final user = ref.watch(authProvider).user;
                      final bool canManage = user?.perfil == 'admin' || user?.perfil == 'gerente';

                      return DataRow(cells: [
                        DataCell(Text(c.descricao)),
                        DataCell(Text(c.clienteNome ?? '-')),
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.date(c.dataVencimento),
                              style: TextStyle(
                                color: isAtrasada ? AppTheme.accentRed : null,
                                fontWeight: isAtrasada ? FontWeight.bold : null,
                              ),
                            ),
                            if (isAtrasada) 
                              Text('ATRASADO', style: TextStyle(color: AppTheme.accentRed, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        )),
                        DataCell(Text(Formatters.currency(c.valorOriginal), style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(StatusChip.fromStatus(c.status)),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              Icons.price_check, 
                              color: (c.status == 'aberta' && canManage) ? AppTheme.accentGreen : Colors.grey.withOpacity(0.5)
                            ),
                            tooltip: canManage ? 'Receber Conta' : 'Acesso Restrito ao Admin',
                            onPressed: (c.status == 'aberta' && canManage)
                                ? () => showDialog(context: context, builder: (_) => _ReceiptDialog(conta: c))
                                : null,
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FluxoCaixaTab extends ConsumerWidget {
  final ScrollController controller;
  const _FluxoCaixaTab({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fluxoAsync = ref.watch(cashFlowProvider);

    return Container(
      decoration: AppTheme.glassCard(),
      clipBehavior: Clip.antiAlias,
      child: fluxoAsync.when(
        loading: () => const LoadingOverlay(message: 'Carregando...'),
        error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Erro', subtitle: '$e'),
        data: (resp) {
          final items = resp.items;
          if (items.isEmpty) {
            return const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'Sem movimentações');
          }
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('DATA')),
                      DataColumn(label: Text('TIPO')),
                      DataColumn(label: Text('VALOR'), numeric: true),
                    ],
                    rows: items.map((item) => DataRow(cells: [
                      DataCell(Text(Formatters.date(item.data))),
                      DataCell(StatusChip(
                        label: item.tipo.toUpperCase(),
                        color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                      )),
                      DataCell(Text(
                        Formatters.currency(item.valor),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.valor >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                        ),
                      )),
                    ])).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final ContaPagar conta;
  const _PaymentDialog({required this.conta});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valorController.text = widget.conta.valorOriginal.toStringAsFixed(2);
    _dataController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Pagamento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Deseja registrar o pagamento da conta:'),
          Text(widget.conta.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: r'Valor Pago (R$)', prefixText: r'R$ '),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data do Pagamento', suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _dataController.text = date.toString().split(' ')[0];
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        Consumer(builder: (context, ref, _) {
          return ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
              final ok = await ref.read(accountsPayableProvider.notifier).pagar(
                widget.conta.idContaPagar,
                PagarContaRequest(valorPago: valor, dataPagamento: _dataController.text),
              );
              if (mounted) {
                if (ok) {
                  ref.read(cashFlowProvider.notifier).refresh();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao processar pagamento')));
                }
              }
            },
            child: const Text('Confirmar'),
          );
        }),
      ],
    );
  }
}

class _ReceiptDialog extends StatefulWidget {
  final ContaReceber conta;
  const _ReceiptDialog({required this.conta});

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _valorController.text = widget.conta.valorOriginal.toStringAsFixed(2);
    _dataController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Recebimento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Deseja registrar o recebimento da conta:'),
          Text(widget.conta.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: r'Valor Recebido (R$)', prefixText: r'R$ '),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: 'Data do Recebimento', suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                _dataController.text = date.toString().split(' ')[0];
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        Consumer(builder: (context, ref, _) {
          return ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
              final ok = await ref.read(accountsReceivableProvider.notifier).receber(
                widget.conta.idContaReceber,
                ReceberContaRequest(valorRecebido: valor, dataRecebimento: _dataController.text),
              );
              if (mounted) {
                if (ok) {
                  ref.read(cashFlowProvider.notifier).refresh();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao processar recebimento')));
                }
              }
            },
            child: const Text('Confirmar'),
          );
        }),
      ],
    );
  }
}
