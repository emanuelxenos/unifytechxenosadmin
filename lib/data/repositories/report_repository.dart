import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'report_repository.g.dart';

@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  return ReportRepository(ref.read(apiServiceProvider));
}

class ReportRepository {
  final ApiService _api;
  ReportRepository(this._api);

  Future<Map<String, dynamic>> vendasDia() async {
    final response = await _api.get(ApiEndpoints.relatorioVendasDia);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> vendasMes() async {
    final response = await _api.get(ApiEndpoints.relatorioVendasMes);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> vendasPeriodo(String dataInicio, String dataFim) async {
    final response = await _api.get(
      ApiEndpoints.relatorioVendasPeriodo,
      queryParameters: {'data_inicio': dataInicio, 'data_fim': dataFim},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> maisVendidos({String periodo = '30d'}) async {
    final response = await _api.get(
      ApiEndpoints.relatorioMaisVendidos,
      queryParameters: {'periodo': periodo},
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
