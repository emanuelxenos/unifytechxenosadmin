import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/presentation/widgets/shared_widgets.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compras', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text('Registro de compras e fornecedores', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Para registrar compras, use o formulário de compras')),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nova Compra'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: AppTheme.glassCard(),
                child: const EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Compras',
                  subtitle: 'Registre compras de fornecedores e controle o recebimento de mercadorias.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
