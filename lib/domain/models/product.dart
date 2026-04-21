import 'package:unifytechxenosadmin/domain/models/category.dart';

class Produto {
  final int idProduto;
  final int empresaId;
  final int? categoriaId;
  final String? codigoBarras;
  final String? codigoInterno;
  final String nome;
  final String? descricao;
  final String? marca;
  final String unidadeVenda;
  final String unidadeCompra;
  final double fatorConversao;
  final double estoqueAtual;
  final double estoqueMinimo;
  final double? estoqueMaximo;
  final bool controlarEstoque;
  final double precoCusto;
  final double precoVenda;
  final double? precoPromocional;
  final DateTime? dataInicioPromocao;
  final DateTime? dataFimPromocao;
  final double? margemLucro;
  final String? ncm;
  final DateTime dataCadastro;
  final DateTime? dataUltimaCompra;
  final DateTime? dataUltimaVenda;
  final String? fotoPrincipalUrl;
  final bool ativo;
  final bool destacado;
  final String? localizacao;
  final DateTime? dataVencimento;
  final String? categoriaNome;

  Produto({
    required this.idProduto,
    required this.empresaId,
    this.categoriaId,
    this.codigoBarras,
    this.codigoInterno,
    required this.nome,
    this.descricao,
    this.marca,
    this.unidadeVenda = 'UN',
    this.unidadeCompra = 'UN',
    this.fatorConversao = 1.0,
    this.estoqueAtual = 0,
    this.estoqueMinimo = 0,
    this.estoqueMaximo,
    this.controlarEstoque = true,
    this.precoCusto = 0,
    required this.precoVenda,
    this.precoPromocional,
    this.dataInicioPromocao,
    this.dataFimPromocao,
    this.margemLucro,
    this.ncm,
    required this.dataCadastro,
    this.dataUltimaCompra,
    this.dataUltimaVenda,
    this.fotoPrincipalUrl,
    this.ativo = true,
    this.destacado = false,
    this.localizacao,
    this.dataVencimento,
    this.categoriaNome,
  });

  bool get estoqueBaixo =>
      controlarEstoque && estoqueAtual <= estoqueMinimo;

  bool get emPromocao {
    if (precoPromocional == null) return false;
    final now = DateTime.now();
    if (dataInicioPromocao != null && now.isBefore(dataInicioPromocao!)) {
      return false;
    }
    if (dataFimPromocao != null && now.isAfter(dataFimPromocao!)) return false;
    return true;
  }

  double get precoEfetivo => emPromocao ? precoPromocional! : precoVenda;

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
        idProduto: json['id_produto'] as int,
        empresaId: json['empresa_id'] as int,
        categoriaId: json['categoria_id'] as int?,
        codigoBarras: json['codigo_barras'] as String?,
        codigoInterno: json['codigo_interno'] as String?,
        nome: json['nome'] as String,
        descricao: json['descricao'] as String?,
        marca: json['marca'] as String?,
        unidadeVenda: json['unidade_venda'] as String? ?? 'UN',
        unidadeCompra: json['unidade_compra'] as String? ?? 'UN',
        fatorConversao:
            (json['fator_conversao'] as num?)?.toDouble() ?? 1.0,
        estoqueAtual: (json['estoque_atual'] as num?)?.toDouble() ?? 0,
        estoqueMinimo: (json['estoque_minimo'] as num?)?.toDouble() ?? 0,
        estoqueMaximo: (json['estoque_maximo'] as num?)?.toDouble(),
        controlarEstoque: json['controlar_estoque'] as bool? ?? true,
        precoCusto: (json['preco_custo'] as num?)?.toDouble() ?? 0,
        precoVenda: (json['preco_venda'] as num).toDouble(),
        precoPromocional:
            (json['preco_promocional'] as num?)?.toDouble(),
        dataInicioPromocao: json['data_inicio_promocao'] != null
            ? DateTime.parse(json['data_inicio_promocao'] as String)
            : null,
        dataFimPromocao: json['data_fim_promocao'] != null
            ? DateTime.parse(json['data_fim_promocao'] as String)
            : null,
        margemLucro: (json['margem_lucro'] as num?)?.toDouble(),
        ncm: json['ncm'] as String?,
        dataCadastro: DateTime.parse(json['data_cadastro'] as String),
        dataUltimaCompra: json['data_ultima_compra'] != null
            ? DateTime.parse(json['data_ultima_compra'] as String)
            : null,
        dataUltimaVenda: json['data_ultima_venda'] != null
            ? DateTime.parse(json['data_ultima_venda'] as String)
            : null,
        fotoPrincipalUrl: json['foto_principal_url'] as String?,
        ativo: json['ativo'] as bool? ?? true,
        destacado: json['destacado'] as bool? ?? false,
        localizacao: json['localizacao'] as String?,
        dataVencimento: json['data_vencimento'] != null
            ? DateTime.parse(json['data_vencimento'] as String)
            : null,
        categoriaNome: json['categoria_nome'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'codigo_barras': codigoBarras,
        'codigo_interno': codigoInterno,
        'nome': nome,
        'descricao': descricao,
        'categoria_id': categoriaId,
        'unidade_venda': unidadeVenda,
        'controlar_estoque': controlarEstoque,
        'estoque_minimo': estoqueMinimo,
        'preco_custo': precoCusto,
        'preco_venda': precoVenda,
        'marca': marca,
        'localizacao': localizacao,
        'data_vencimento': dataVencimento?.toIso8601String(),
      };
}

class CriarProdutoRequest {
  final String? codigoBarras;
  final String? codigoInterno;
  final String nome;
  final String? descricao;
  final int? categoriaId;
  final String unidadeVenda;
  final bool controlarEstoque;
  final double estoqueMinimo;
  final double precoCusto;
  final double precoVenda;
  final String? marca;
  final String? localizacao;
  final DateTime? dataVencimento;

  CriarProdutoRequest({
    this.codigoBarras,
    this.codigoInterno,
    required this.nome,
    this.descricao,
    this.categoriaId,
    this.unidadeVenda = 'UN',
    this.controlarEstoque = true,
    this.estoqueMinimo = 0,
    this.precoCusto = 0,
    required this.precoVenda,
    this.marca,
    this.localizacao,
    this.dataVencimento,
  });

  Map<String, dynamic> toJson() => {
        'codigo_barras': codigoBarras,
        'codigo_interno': codigoInterno,
        'nome': nome,
        'descricao': descricao,
        'categoria_id': categoriaId,
        'unidade_venda': unidadeVenda,
        'controlar_estoque': controlarEstoque,
        'estoque_minimo': estoqueMinimo,
        'preco_custo': precoCusto,
        'preco_venda': precoVenda,
        'marca': marca,
        'localizacao': localizacao,
        'data_vencimento': dataVencimento?.toIso8601String(),
      };
}
