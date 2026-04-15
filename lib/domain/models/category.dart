class Categoria {
  final int idCategoria;
  final int empresaId;
  final String nome;
  final String? descricao;
  final int? categoriaPaiId;
  final int nivel;
  final bool ativo;
  final int ordemExibicao;
  final DateTime dataCadastro;

  Categoria({
    required this.idCategoria,
    required this.empresaId,
    required this.nome,
    this.descricao,
    this.categoriaPaiId,
    this.nivel = 1,
    this.ativo = true,
    this.ordemExibicao = 0,
    required this.dataCadastro,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idCategoria: json['id_categoria'] as int,
        empresaId: json['empresa_id'] as int,
        nome: json['nome'] as String,
        descricao: json['descricao'] as String?,
        categoriaPaiId: json['categoria_pai_id'] as int?,
        nivel: json['nivel'] as int? ?? 1,
        ativo: json['ativo'] as bool? ?? true,
        ordemExibicao: json['ordem_exibicao'] as int? ?? 0,
        dataCadastro: DateTime.parse(json['data_cadastro'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id_categoria': idCategoria,
        'empresa_id': empresaId,
        'nome': nome,
        'descricao': descricao,
        'ativo': ativo,
      };
}

class CriarCategoriaRequest {
  final String nome;
  final String? descricao;
  final int? categoriaPaiId;
  final int ordemExibicao;

  CriarCategoriaRequest({
    required this.nome,
    this.descricao,
    this.categoriaPaiId,
    this.ordemExibicao = 0,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'descricao': descricao,
        'categoria_pai_id': categoriaPaiId,
        'ordem_exibicao': ordemExibicao,
      };
}
