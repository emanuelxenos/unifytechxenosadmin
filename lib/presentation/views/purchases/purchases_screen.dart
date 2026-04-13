import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/presentation/providers/purchase_provider.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/suppliers_tab.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/history_tab.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/supplier_analytics_tab.dart';
import 'package:unifytechxenosadmin/presentation/views/purchases/widgets/purchase_form_dialog.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                        Text('Compras', style: theme.textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        Text('Gestão de suprimentos e fornecedores', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewPurchaseForm(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Nova Compra'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tabs
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.primaryColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'HISTÓRICO DE COMPRAS'),
                  Tab(text: 'FORNECEDORES'),
                  Tab(text: 'CONSULTAS POR FORNECEDOR'),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: TabBarView(
                  children: [
                    // History Tab
                    const HistoryTab(),
                    // Suppliers Tab
                    const SuppliersTab(),
                    // Analytics Tab
                    const SupplierAnalyticsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewPurchaseForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PurchaseFormDialog(),
    );
  }
}
