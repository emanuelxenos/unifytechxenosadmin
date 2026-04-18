class Cliente {
  final int idCliente;
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final double limiteCredito;
  final double saldoDevedor;
  final bool ativo;

  Cliente({
    required this.idCliente,
    required this.nome,
    required this.tipoPessoa,
    this.cpfCnpj,
    this.telefone,
    this.email,
    required this.limiteCredito,
    required this.saldoDevedor,
    this.ativo = true,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        idCliente: json['id_cliente'] as int,
        nome: json['nome'] as String,
        tipoPessoa: json['tipo_pessoa'] as String,
        cpfCnpj: json['cpf_cnpj'] as String?,
        telefone: json['telefone'] as String?,
        email: json['email'] as String?,
        limiteCredito: (json['limite_credito'] as num).toDouble(),
        saldoDevedor: (json['saldo_devedor'] as num).toDouble(),
        ativo: json['ativo'] as bool? ?? true,
      );
}

class CriarClienteRequest {
  final String nome;
  final String tipoPessoa;
  final String? cpfCnpj;
  final String? telefone;
  final String? email;
  final double limiteCredito;

  CriarClienteRequest({
    required this.nome,
    required this.tipoPessoa,
    this.cpfCnpj,
    this.telefone,
    this.email,
    required this.limiteCredito,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'tipo_pessoa': tipoPessoa,
        'cpf_cnpj': cpfCnpj,
        'telefone': telefone,
        'email': email,
        'limite_credito': limiteCredito,
      };
}
