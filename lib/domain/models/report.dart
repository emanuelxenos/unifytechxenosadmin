class FluxoCaixaItem {
  final DateTime data;
  final String tipo;
  final double valor;

  FluxoCaixaItem({
    required this.data,
    required this.tipo,
    required this.valor,
  });

  factory FluxoCaixaItem.fromJson(Map<String, dynamic> json) =>
      FluxoCaixaItem(
        data: DateTime.parse(json['data'] as String),
        tipo: json['tipo'] as String,
        valor: (json['valor'] as num).toDouble(),
      );
}

class Configuracao {
  final int idConfig;
  final int empresaId;
  final String chave;
  final String? valor;
  final String tipo;
  final String categoria;
  final String? descricao;
  final DateTime dataAtualizacao;

  Configuracao({
    required this.idConfig,
    required this.empresaId,
    required this.chave,
    this.valor,
    this.tipo = 'texto',
    this.categoria = 'geral',
    this.descricao,
    required this.dataAtualizacao,
  });

  factory Configuracao.fromJson(Map<String, dynamic> json) => Configuracao(
        idConfig: json['id_config'] as int,
        empresaId: json['empresa_id'] as int,
        chave: json['chave'] as String,
        valor: json['valor'] as String?,
        tipo: json['tipo'] as String? ?? 'texto',
        categoria: json['categoria'] as String? ?? 'geral',
        descricao: json['descricao'] as String?,
        dataAtualizacao:
            DateTime.parse(json['data_atualizacao'] as String),
      );
}

class AtualizarConfigRequest {
  final List<ConfigItem> configs;

  AtualizarConfigRequest({required this.configs});

  Map<String, dynamic> toJson() => {
        'configs': configs.map((e) => e.toJson()).toList(),
      };
}

class ConfigItem {
  final String chave;
  final String valor;

  ConfigItem({required this.chave, required this.valor});

  Map<String, dynamic> toJson() => {
        'chave': chave,
        'valor': valor,
      };
}

class Auditoria {
  final int idAuditoria;
  final int empresaId;
  final String tabela;
  final String acao;
  final int? registroId;
  final String? valoresAntigos;
  final String? valoresNovos;
  final DateTime dataHora;
  final int? usuarioId;
  final String? ipAddress;
  final String? userAgent;

  Auditoria({
    required this.idAuditoria,
    required this.empresaId,
    required this.tabela,
    required this.acao,
    this.registroId,
    this.valoresAntigos,
    this.valoresNovos,
    required this.dataHora,
    this.usuarioId,
    this.ipAddress,
    this.userAgent,
  });

  factory Auditoria.fromJson(Map<String, dynamic> json) => Auditoria(
        idAuditoria: json['id_auditoria'] as int,
        empresaId: json['empresa_id'] as int,
        tabela: json['tabela'] as String,
        acao: json['acao'] as String,
        registroId: json['registro_id'] as int?,
        valoresAntigos: json['valores_antigos']?.toString(),
        valoresNovos: json['valores_novos']?.toString(),
        dataHora: DateTime.parse(json['data_hora'] as String),
        usuarioId: json['usuario_id'] as int?,
        ipAddress: json['ip_address'] as String?,
        userAgent: json['user_agent'] as String?,
      );
}

/// Generic report data used in dashboard
class DashboardData {
  final double vendasHoje;
  final int totalVendasHoje;
  final double ticketMedio;
  final int produtosEstoqueBaixo;
  final int caixasAbertos;
  final List<VendaDiaItem> vendasPorHora;

  DashboardData({
    this.vendasHoje = 0,
    this.totalVendasHoje = 0,
    this.ticketMedio = 0,
    this.produtosEstoqueBaixo = 0,
    this.caixasAbertos = 0,
    this.vendasPorHora = const [],
  });
}

class VendaDiaItem {
  final int hora;
  final double valor;
  final int quantidade;

  VendaDiaItem({
    required this.hora,
    required this.valor,
    required this.quantidade,
  });
}
