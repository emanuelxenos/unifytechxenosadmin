class Empresa {
  final int idEmpresa;
  final String razaoSocial;
  final String nomeFantasia;
  final String cnpj;
  final String? inscricaoEstadual;
  final String? inscricaoMunicipal;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String telefone;
  final String? telefone2;
  final String email;
  final String? site;
  final String regimeTributario;
  final String moeda;
  final int casasDecimais;
  final bool ativo;
  final DateTime dataCadastro;
  final DateTime? dataAtualizacao;

  Empresa({
    required this.idEmpresa,
    required this.razaoSocial,
    required this.nomeFantasia,
    required this.cnpj,
    this.inscricaoEstadual,
    this.inscricaoMunicipal,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    required this.telefone,
    this.telefone2,
    required this.email,
    this.site,
    this.regimeTributario = 'SIMPLES',
    this.moeda = 'R\$',
    this.casasDecimais = 2,
    this.ativo = true,
    required this.dataCadastro,
    this.dataAtualizacao,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
        idEmpresa: json['id_empresa'] as int,
        razaoSocial: json['razao_social'] as String,
        nomeFantasia: json['nome_fantasia'] as String,
        cnpj: json['cnpj'] as String,
        inscricaoEstadual: json['inscricao_estadual'] as String?,
        inscricaoMunicipal: json['inscricao_municipal'] as String?,
        logradouro: json['logradouro'] as String? ?? '',
        numero: json['numero'] as String? ?? '',
        complemento: json['complemento'] as String?,
        bairro: json['bairro'] as String? ?? '',
        cidade: json['cidade'] as String? ?? '',
        estado: json['estado'] as String? ?? '',
        cep: json['cep'] as String? ?? '',
        telefone: json['telefone'] as String? ?? '',
        telefone2: json['telefone2'] as String?,
        email: json['email'] as String? ?? '',
        site: json['site'] as String?,
        regimeTributario: json['regime_tributario'] as String? ?? 'SIMPLES',
        moeda: json['moeda'] as String? ?? 'R\$',
        casasDecimais: json['casas_decimais'] as int? ?? 2,
        ativo: json['ativo'] as bool? ?? true,
        dataCadastro: DateTime.parse(json['data_cadastro'] as String),
        dataAtualizacao: json['data_atualizacao'] != null
            ? DateTime.parse(json['data_atualizacao'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id_empresa': idEmpresa,
        'razao_social': razaoSocial,
        'nome_fantasia': nomeFantasia,
        'cnpj': cnpj,
        'inscricao_estadual': inscricaoEstadual,
        'inscricao_municipal': inscricaoMunicipal,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'cep': cep,
        'telefone': telefone,
        'telefone2': telefone2,
        'email': email,
        'site': site,
        'regime_tributario': regimeTributario,
        'moeda': moeda,
        'casas_decimais': casasDecimais,
        'ativo': ativo,
      };
}
