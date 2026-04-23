import 'package:flutter/material.dart';
import 'package:unifytechxenosadmin/core/theme/app_theme.dart';
import 'package:unifytechxenosadmin/core/utils/formatters.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';

class ReceivePurchaseDialog extends StatefulWidget {
  final Compra compra;

  const ReceivePurchaseDialog({super.key, required this.compra});

  @override
  State<ReceivePurchaseDialog> createState() => _ReceivePurchaseDialogState();
}

class _ReceivePurchaseDialogState extends State<ReceivePurchaseDialog> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.compra.itens.map((item) => {
      'produto_id': item.produtoId,
      'produto_nome': item.produtoNome,
      'quantidade': item.quantidade,
      'controller': TextEditingController(text: ''), // Lote
    }).toList();
  }

  @override
  void dispose() {
    for (var item in _items) {
      (item['controller'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Receber Mercadoria'),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirme os lotes dos produtos recebidos da Nota Fiscal ${widget.compra.numeroNotaFiscal ?? 'S/N'}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              '* Se deixar o lote vazio, o número da nota será usado como padrão.',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['produto_nome'] ?? 'Produto ${item['produto_id']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Qtd: ${Formatters.quantity(item['quantidade'])}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item['controller'] as TextEditingController,
                            decoration: const InputDecoration(
                              labelText: 'Lote (Opcional)',
                              hintText: 'Ex: L1234',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final requests = _items.map((item) => ItemRecebidoRequest(
              produtoId: item['produto_id'],
              quantidadeRecebida: item['quantidade'],
              loteFabricante: (item['controller'] as TextEditingController).text.trim().isEmpty 
                ? null 
                : (item['controller'] as TextEditingController).text.trim(),
            )).toList();
            
            Navigator.pop(context, ReceberCompraRequest(itensRecebidos: requests));
          },
          child: const Text('Confirmar Recebimento'),
        ),
      ],
    );
  }
}
