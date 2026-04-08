class Compra {
  final int idCompra;
  final int empresaId;
  final int? fornecedorId;
  final int usuarioId;
  final String? numeroNotaFiscal;
  final String? serieNota;
  final String? chaveNfe;
  final DateTime? dataEmissao;
  final DateTime dataEntrada;
  final DateTime dataCadastro;
  final double valorProdutos;
  final double valorFrete;
  final double valorDesconto;
  final double valorTotal;
  final String status;
  final String? observacoes;
  final String? fornecedorNome;
  final List<ItemCompra> itens;

  Compra({
    required this.idCompra,
    required this.empresaId,
    this.fornecedorId,
    required this.usuarioId,
    this.numeroNotaFiscal,
    this.serieNota,
    this.chaveNfe,
    this.dataEmissao,
    required this.dataEntrada,
    required this.dataCadastro,
    this.valorProdutos = 0,
    this.valorFrete = 0,
    this.valorDesconto = 0,
    this.valorTotal = 0,
    this.status = 'pendente',
    this.observacoes,
    this.fornecedorNome,
    this.itens = const [],
  });

  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
        idCompra: json['id_compra'] as int,
        empresaId: json['empresa_id'] as int,
        fornecedorId: json['fornecedor_id'] as int?,
        usuarioId: json['usuario_id'] as int,
        numeroNotaFiscal: json['numero_nota_fiscal'] as String?,
        serieNota: json['serie_nota'] as String?,
        chaveNfe: json['chave_nfe'] as String?,
        dataEmissao: json['data_emissao'] != null
            ? DateTime.parse(json['data_emissao'] as String)
            : null,
        dataEntrada: DateTime.parse(json['data_entrada'] as String),
        dataCadastro: DateTime.parse(json['data_cadastro'] as String),
        valorProdutos: (json['valor_produtos'] as num?)?.toDouble() ?? 0,
        valorFrete: (json['valor_frete'] as num?)?.toDouble() ?? 0,
        valorDesconto: (json['valor_desconto'] as num?)?.toDouble() ?? 0,
        valorTotal: (json['valor_total'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'pendente',
        observacoes: json['observacoes'] as String?,
        fornecedorNome: json['fornecedor_nome'] as String?,
        itens: json['itens'] != null
            ? (json['itens'] as List)
                .map((e) => ItemCompra.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class ItemCompra {
  final int idItemCompra;
  final int compraId;
  final int produtoId;
  final int sequencia;
  final double quantidade;
  final double quantidadeRecebida;
  final double precoUnitario;
  final double valorTotal;
  final double valorDesconto;
  final DateTime? dataRecebimento;
  final String? produtoNome;

  ItemCompra({
    required this.idItemCompra,
    required this.compraId,
    required this.produtoId,
    required this.sequencia,
    required this.quantidade,
    this.quantidadeRecebida = 0,
    required this.precoUnitario,
    required this.valorTotal,
    this.valorDesconto = 0,
    this.dataRecebimento,
    this.produtoNome,
  });

  factory ItemCompra.fromJson(Map<String, dynamic> json) => ItemCompra(
        idItemCompra: json['id_item_compra'] as int,
        compraId: json['compra_id'] as int,
        produtoId: json['produto_id'] as int,
        sequencia: json['sequencia'] as int,
        quantidade: (json['quantidade'] as num).toDouble(),
        quantidadeRecebida:
            (json['quantidade_recebida'] as num?)?.toDouble() ?? 0,
        precoUnitario: (json['preco_unitario'] as num).toDouble(),
        valorTotal: (json['valor_total'] as num).toDouble(),
        valorDesconto: (json['valor_desconto'] as num?)?.toDouble() ?? 0,
        dataRecebimento: json['data_recebimento'] != null
            ? DateTime.parse(json['data_recebimento'] as String)
            : null,
        produtoNome: json['produto_nome'] as String?,
      );
}

class CriarCompraRequest {
  final int fornecedorId;
  final String numeroNotaFiscal;
  final String dataEmissao;
  final List<CriarItemCompraRequest> itens;

  CriarCompraRequest({
    required this.fornecedorId,
    required this.numeroNotaFiscal,
    required this.dataEmissao,
    required this.itens,
  });

  Map<String, dynamic> toJson() => {
        'fornecedor_id': fornecedorId,
        'numero_nota_fiscal': numeroNotaFiscal,
        'data_emissao': dataEmissao,
        'itens': itens.map((e) => e.toJson()).toList(),
      };
}

class CriarItemCompraRequest {
  final int produtoId;
  final double quantidade;
  final double precoUnitario;

  CriarItemCompraRequest({
    required this.produtoId,
    required this.quantidade,
    required this.precoUnitario,
  });

  Map<String, dynamic> toJson() => {
        'produto_id': produtoId,
        'quantidade': quantidade,
        'preco_unitario': precoUnitario,
      };
}

class ReceberCompraRequest {
  final List<ItemRecebidoRequest> itensRecebidos;

  ReceberCompraRequest({required this.itensRecebidos});

  Map<String, dynamic> toJson() => {
        'itens_recebidos': itensRecebidos.map((e) => e.toJson()).toList(),
      };
}

class ItemRecebidoRequest {
  final int produtoId;
  final double quantidadeRecebida;

  ItemRecebidoRequest({
    required this.produtoId,
    required this.quantidadeRecebida,
  });

  Map<String, dynamic> toJson() => {
        'produto_id': produtoId,
        'quantidade_recebida': quantidadeRecebida,
      };
}
