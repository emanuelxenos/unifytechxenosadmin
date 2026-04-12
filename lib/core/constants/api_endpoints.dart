class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/api/login';
  static const String discover = '/api/discover';
  static const String health = '/health';

  // Caixa
  static const String caixaStatus = '/api/caixa/status';
  static const String caixaAbrir = '/api/caixa/abrir';
  static const String caixaFechar = '/api/caixa/fechar';
  static const String caixaSangria = '/api/caixa/sangria';
  static const String caixaSuprimento = '/api/caixa/suprimento';

  // Vendas
  static const String vendas = '/api/vendas';
  static const String vendasDia = '/api/vendas/dia';
  static String vendaPorId(int id) => '/api/vendas/$id';
  static String vendaCancelar(int id) => '/api/vendas/$id/cancelar';

  // Produtos
  static const String produtos = '/api/produtos';
  static const String produtosBusca = '/api/produtos/busca';
  static String produtoPorId(int id) => '/api/produtos/$id';

  // Clientes
  static const String clientes = '/api/clientes';
  static String clientePorId(int id) => '/api/clientes/$id';

  // Fornecedores
  static const String fornecedores = '/api/fornecedores';
  static String fornecedorPorId(int id) => '/api/fornecedores/$id';

  // Estoque
  static const String estoqueBaixo = '/api/estoque/baixo';
  static const String estoqueAjuste = '/api/estoque/ajuste';
  static const String estoqueInventario = '/api/estoque/inventario';
  static String estoqueInventarioFinalizar(int id) => '/api/estoque/inventario/$id';

  // Compras
  static const String compras = '/api/compras';
  static String compraReceber(int id) => '/api/compras/$id/receber';

  // Financeiro
  static const String contasPagar = '/api/financeiro/contas-pagar';
  static String contaPagarPagar(int id) => '/api/financeiro/contas-pagar/$id/pagar';
  static const String contasReceber = '/api/financeiro/contas-receber';
  static String contaReceberReceber(int id) => '/api/financeiro/contas-receber/$id/receber';
  static const String fluxoCaixa = '/api/financeiro/fluxo-caixa';

  // Relatórios
  static const String relatorioVendasDia = '/api/relatorios/vendas/dia';
  static const String relatorioVendasMes = '/api/relatorios/vendas/mes';
  static const String relatorioVendasPeriodo = '/api/relatorios/vendas/periodo';
  static const String relatorioMaisVendidos = '/api/relatorios/produtos/mais-vendidos';
  static const String relatorioExportPdf = '/api/relatorios/exportar/pdf';
  static const String relatorioExportExcel = '/api/relatorios/exportar/excel';

  // Config (Admin)
  static const String config = '/api/config';

  // Usuários (Admin)
  static const String usuarios = '/api/usuarios';

  // Backup (Admin)
  static const String backup = '/api/backup';
  static const String backupRestaurar = '/api/backup/restaurar';

  // WebSocket
  static const String ws = '/ws';
}
