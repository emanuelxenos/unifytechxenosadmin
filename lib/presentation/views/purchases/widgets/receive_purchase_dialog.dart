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
      'lote_original': item.localizacao, // O campo localizacao as vezes é usado para lote em modelos antigos, mas vamos usar o campo especifico
      'controller': TextEditingController(text: ''), // Iniciamos vazio, mas vamos preencher abaixo
    }).toList();

    // Preencher com o lote que veio da compra, se existir
    for (int i = 0; i < widget.compra.itens.length; i++) {
        final itemCompra = widget.compra.itens[i];
        if (itemCompra.lote != null && itemCompra.lote!.isNotEmpty) {
            (_items[i]['controller'] as TextEditingController).text = itemCompra.lote!;
        }
    }
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
        width: 700, // Um pouco mais largo para caber tudo
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Confirme os lotes dos produtos da NF ${widget.compra.numeroNotaFiscal ?? 'S/N'}.\nLotes vazios usarão o número da nota como padrão.',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['produto_nome'] ?? 'Produto ${item['produto_id']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Quantidade: ${Formatters.quantity(item['quantidade'])}',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 250, // LARGURA FIXA PARA O CAMPO DE LOTE APARECER
                          child: TextField(
                            controller: item['controller'] as TextEditingController,
                            decoration: InputDecoration(
                              labelText: 'Lote do Fabricante',
                              hintText: 'Digite o lote...',
                              prefixIcon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
