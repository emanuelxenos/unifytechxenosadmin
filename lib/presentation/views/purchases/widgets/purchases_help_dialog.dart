import 'package:flutter/material.dart';

class _HelpCategory {
  final String title;
  final IconData icon;
  final List<_HelpItem> items;
  const _HelpCategory({required this.title, required this.icon, required this.items});
}

class _HelpItem {
  final String title;
  final String categoryName;
  final String finalidade;
  final String utilidade;
  final List<String> indicadores;
  const _HelpItem({
    required this.title,
    required this.categoryName,
    required this.finalidade,
    required this.utilidade,
    required this.indicadores,
  });
}

class PurchasesHelpDialog extends StatefulWidget {
  const PurchasesHelpDialog({super.key});

  @override
  State<PurchasesHelpDialog> createState() => _PurchasesHelpDialogState();
}

class _PurchasesHelpDialogState extends State<PurchasesHelpDialog> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<_HelpCategory> _categories = const [
    _HelpCategory(
      title: 'Fluxo de Compras',
      icon: Icons.shopping_cart_rounded,
      items: [
        _HelpItem(
          title: 'Pedidos de Compra',
          categoryName: 'Fluxo de Compras',
          finalidade: 'Registrar intenções de compra, cotações e orçamentos junto aos fornecedores.',
          utilidade: 'Garante o planejamento da reposição de estoque, permitindo conferir preços cotados antes da chegada física da mercadoria e evitando compras duplicadas.',
          indicadores: [
            'Código identificador do pedido',
            'Status do pedido (Pendente, Aprovado, Recebido, Cancelado)',
            'Fornecedor associado e data de emissão',
            'Valor total estimado do pedido e lista de itens cotados'
          ],
        ),
        _HelpItem(
          title: 'Entrada de Mercadorias (XML)',
          categoryName: 'Fluxo de Compras',
          finalidade: 'Dar entrada física de produtos no estoque através da importação de Notas Fiscais (NF-e/XML).',
          utilidade: 'Automatiza o processo de recebimento de cargas. O sistema lê o XML da nota, atualiza o saldo físico dos produtos no estoque, recalcula o preço médio de custo e vincula as faturas financeiras automaticamente.',
          indicadores: [
            'Número da Nota Fiscal (NF-e) e Série',
            'Chave de Acesso da Nota (44 dígitos)',
            'Valor Total da Nota Fiscal',
            'Divergência entre quantidade pedida e recebida'
          ],
        ),
      ],
    ),
    _HelpCategory(
      title: 'Fornecedores',
      icon: Icons.business_rounded,
      items: [
        _HelpItem(
          title: 'Cadastro de Fornecedores',
          categoryName: 'Fornecedores',
          finalidade: 'Centralizar os dados cadastrais, contatos, termos de logística e finanças de cada parceiro comercial.',
          utilidade: 'Essencial para a equipe de compras negociar prazos e entregas. Permite consultar telefones rápidos, limites de crédito acordados e e-mails de faturamento de forma imediata.',
          indicadores: [
            'Razão Social, Nome Fantasia e CNPJ',
            'Limite de Crédito Disponível para compras a prazo',
            'Prazos acordados de Entrega (lead time) e de Pagamento',
            'Contatos comerciais diretos (telefone e e-mail)'
          ],
        ),
        _HelpItem(
          title: 'Histórico de Compras',
          categoryName: 'Fornecedores',
          finalidade: 'Consultar compras passadas realizadas com cada fornecedor.',
          utilidade: 'Ajuda a monitorar a pontualidade de entrega do fornecedor, auditar flutuações de preços de custo ao longo do tempo e renegociar contratos de fornecimento.',
          indicadores: [
            'Valor acumulado de compras por fornecedor',
            'Data da última compra física realizada',
            'Variação percentual histórica do custo das mercadorias',
            'Índice de devoluções ou itens avariados recebidos'
          ],
        ),
      ],
    ),
    _HelpCategory(
      title: 'Financeiro & Impostos',
      icon: Icons.account_balance_wallet_rounded,
      items: [
        _HelpItem(
          title: 'Integração de Contas a Pagar',
          categoryName: 'Financeiro & Impostos',
          finalidade: 'Gerar faturas financeiras a pagar automaticamente a partir das entradas de notas.',
          utilidade: 'Evita falhas manuais e esquecimentos de pagamento. O sistema gera os desdobramentos de parcelas com base nos prazos de pagamento informados (ex: 30/60 dias).',
          indicadores: [
            'Datas de vencimento projetadas das parcelas',
            'Valor de cada duplicata e conta de origem',
            'Status de integração financeira no contas a pagar',
            'Banco ou forma de liquidação definida no XML'
          ],
        ),
        _HelpItem(
          title: 'Custo de Aquisição & Tributos',
          categoryName: 'Financeiro & Impostos',
          finalidade: 'Mapear o custo real de entrada dos itens descontando tributos recuperáveis.',
          utilidade: 'Fundamental para a correta precificação de venda. Permite apurar o custo real adicionando frete (FOB), IPI, ST e deduzindo créditos de ICMS/PIS/COFINS.',
          indicadores: [
            'Preço de compra unitário bruto',
            'Créditos tributários calculados (ICMS, PIS, COFINS)',
            'Custos adicionais aplicados (frete, seguros, embalagens)',
            'Preço de custo líquido final para precificação'
          ],
        ),
      ],
    ),
  ];

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'fluxo de compras': return Colors.teal;
      case 'fornecedores': return Colors.amber;
      case 'financeiro & impostos': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<_HelpItem> searchResults = [];
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      for (var cat in _categories) {
        for (var item in cat.items) {
          if (item.title.toLowerCase().contains(q) ||
              item.finalidade.toLowerCase().contains(q) ||
              item.utilidade.toLowerCase().contains(q) ||
              item.categoryName.toLowerCase().contains(q) ||
              item.indicadores.any((ind) => ind.toLowerCase().contains(q))) {
            searchResults.add(item);
          }
        }
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 1000,
        height: 700,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(32, 24, 24, 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181824) : Colors.grey[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: Colors.teal, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual de Gestão de Compras',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Saiba como gerenciar pedidos, XML de Notas Fiscais e fornecedores',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Pesquise por termos, processos ou indicadores (ex: xml, fornecedor, impostos)...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF161622) : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchQuery.isEmpty) ...[
                      Container(
                        width: 240,
                        color: isDark ? const Color(0xFF181824) : Colors.grey[50],
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          itemCount: _categories.length,
                          itemBuilder: (context, idx) {
                            final cat = _categories[idx];
                            final isSel = idx == _selectedCategoryIndex;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  cat.icon, 
                                  color: isSel 
                                    ? _getCategoryColor(cat.title) 
                                    : (isDark ? Colors.white38 : Colors.black38),
                                  size: 20,
                                ),
                                title: Text(
                                  cat.title,
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel 
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark ? Colors.white60 : Colors.black54),
                                    fontSize: 14,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: isSel 
                                  ? _getCategoryColor(cat.title).withOpacity(0.12)
                                  : Colors.transparent,
                                hoverColor: Colors.teal.withOpacity(0.05),
                                onTap: () => setState(() => _selectedCategoryIndex = idx),
                              ),
                            );
                          },
                        ),
                      ),
                      VerticalDivider(width: 1, color: isDark ? Colors.white10 : Colors.black12),
                    ],
                    Expanded(
                      child: Container(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        child: _searchQuery.isNotEmpty && searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[600]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum tópico encontrado',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tente pesquisar com termos mais simples.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(32),
                              itemCount: _searchQuery.isNotEmpty 
                                ? searchResults.length 
                                : _categories[_selectedCategoryIndex].items.length,
                              itemBuilder: (context, idx) {
                                final item = _searchQuery.isNotEmpty
                                  ? searchResults[idx]
                                  : _categories[_selectedCategoryIndex].items[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF242438) : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.title,
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getCategoryColor(item.categoryName).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: _getCategoryColor(item.categoryName).withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              item.categoryName,
                                              style: TextStyle(
                                                color: _getCategoryColor(item.categoryName),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.info_outline_rounded, color: Colors.teal, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: isDark ? Colors.white70 : Colors.black87,
                                                  ),
                                                  children: [
                                                    const TextSpan(text: 'Finalidade: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: item.finalidade),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.insights_rounded, color: Colors.orangeAccent, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: isDark ? Colors.white70 : Colors.black87,
                                                  ),
                                                  children: [
                                                    const TextSpan(text: 'Utilidade Prática: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: item.utilidade),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Aspectos Chave:',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        ...item.indicadores.map((ind) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(top: 6),
                                                  child: Icon(Icons.circle, size: 6, color: Colors.tealAccent),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    ind,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: isDark ? Colors.white70 : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
