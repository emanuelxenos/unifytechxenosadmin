import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/account_payable.dart';
import 'package:unifytechxenosadmin/domain/models/account_receivable.dart';
import 'package:unifytechxenosadmin/domain/models/report.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'finance_repository.g.dart';

@riverpod
FinanceRepository financeRepository(FinanceRepositoryRef ref) {
  return FinanceRepository(ref.read(apiServiceProvider));
}

class FinanceRepository {
  final ApiService _api;
  FinanceRepository(this._api);

  Future<List<ContaPagar>> contasPagar({String? status}) async {
    final response = await _api.get(
      ApiEndpoints.contasPagar,
      queryParameters: status != null ? {'status': status} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ContaPagar.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => ContaPagar.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> criarContaPagar(CriarContaPagarRequest request) async {
    await _api.post(ApiEndpoints.contasPagar, data: request.toJson());
  }

  Future<void> pagarConta(int id, PagarContaRequest request) async {
    await _api.post(ApiEndpoints.contaPagarPagar(id), data: request.toJson());
  }

  Future<List<ContaReceber>> contasReceber({String? status}) async {
    final response = await _api.get(
      ApiEndpoints.contasReceber,
      queryParameters: status != null ? {'status': status} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ContaReceber.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => ContaReceber.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> receberConta(int id, ReceberContaRequest request) async {
    await _api.post(ApiEndpoints.contaReceberReceber(id), data: request.toJson());
  }

  Future<FluxoCaixaResponse> fluxoCaixa({String? dataInicio, String? dataFim}) async {
    final response = await _api.get(
      ApiEndpoints.fluxoCaixa,
      queryParameters: {
        if (dataInicio != null) 'data_inicio': dataInicio,
        if (dataFim != null) 'data_fim': dataFim,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return FluxoCaixaResponse.fromJson(data['data'] as Map<String, dynamic>);
    }
    if (data is Map<String, dynamic>) {
      return FluxoCaixaResponse.fromJson(data);
    }
    return FluxoCaixaResponse(items: [], totalEntrada: 0, totalSaida: 0, saldo: 0);
  }
}
