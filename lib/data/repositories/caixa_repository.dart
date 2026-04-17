import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'caixa_repository.g.dart';

@riverpod
CaixaRepository caixaRepository(CaixaRepositoryRef ref) {
  return CaixaRepository(ref.read(apiServiceProvider));
}

class CaixaRepository {
  final ApiService _api;
  CaixaRepository(this._api);

  Future<List<SessaoCaixa>> sessoes({String? inicio, String? fim}) async {
    final Map<String, dynamic> queryParameters = {};
    if (inicio != null) queryParameters['data_inicio'] = inicio;
    if (fim != null) queryParameters['data_fim'] = fim;

    final response = await _api.get(
      ApiEndpoints.caixaSessoes,
      queryParameters: queryParameters,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => SessaoCaixa.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<CaixaMovimentacao>> movimentacoes({String? inicio, String? fim}) async {
    final Map<String, dynamic> queryParameters = {};
    if (inicio != null) queryParameters['data_inicio'] = inicio;
    if (fim != null) queryParameters['data_fim'] = fim;

    final response = await _api.get(
      ApiEndpoints.caixaMovimentacoes,
      queryParameters: queryParameters,
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => CaixaMovimentacao.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CaixaStatusResponse> status() async {
    final response = await _api.get(ApiEndpoints.caixaStatus);
    return CaixaStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
