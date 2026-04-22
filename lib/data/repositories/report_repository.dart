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

  Map<String, dynamic> _extractMapData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return {};
  }

  Future<Map<String, dynamic>> vendasDia() async {
    final response = await _api.get(ApiEndpoints.relatorioVendasDia);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> vendasMes() async {
    final response = await _api.get(ApiEndpoints.relatorioVendasMes);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> vendasPeriodo(String dataInicio, String dataFim) async {
    final response = await _api.get(
      ApiEndpoints.relatorioVendasPeriodo,
      queryParameters: {'data_inicio': dataInicio, 'data_fim': dataFim},
    );
    return _extractMapData(response.data);
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

  Future<Map<String, dynamic>> estoqueResumo() async {
    final response = await _api.get(ApiEndpoints.relatorioEstoqueResumo);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> financeiroResumo() async {
    final response = await _api.get(ApiEndpoints.relatorioFinanceiroResumo);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> dre({int? mes, int? ano}) async {
    final response = await _api.get(ApiEndpoints.relatorioDRE, queryParameters: {
      if (mes != null) 'mes': mes,
      if (ano != null) 'ano': ano,
    });
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> inadimplencia() async {
    final response = await _api.get(ApiEndpoints.relatorioInadimplencia);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> curvaABC() async {
    final response = await _api.get(ApiEndpoints.relatorioCurvaABC);
    return _extractMapData(response.data);
  }

  Future<Map<String, dynamic>> comissoes({int? mes, int? ano}) async {
    final response = await _api.get(ApiEndpoints.relatorioComissoes, queryParameters: {
      if (mes != null) 'mes': mes,
      if (ano != null) 'ano': ano,
    });
    return _extractMapData(response.data);
  }

  Future<void> exportarRelatorio(String formato, String savePath, String tipo, {Map<String, dynamic>? params}) async {
    final endpoint = formato == 'pdf' 
        ? ApiEndpoints.relatorioExportPdf 
        : ApiEndpoints.relatorioExportExcel;
    
    final Map<String, dynamic> queryParams = {'tipo': tipo};
    if (params != null) {
      queryParams.addAll(params);
    }
    
    await _api.download(endpoint, savePath, queryParameters: queryParams);
  }

  Future<void> imprimirEtiqueta(int produtoId, String savePath) async {
    await _api.download(
      ApiEndpoints.relatorioEtiqueta, 
      savePath, 
      queryParameters: {'id': produtoId},
    );
  }

  Future<List<Map<String, dynamic>>> sugestaoCompra() async {
    final response = await _api.get(ApiEndpoints.relatorioSugestaoCompra);
    
    // O backend retorna um JSON array diretamente ou dentro de um campo 'data'
    dynamic rawData = response.data;
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      rawData = rawData['data'];
    }

    if (rawData is List) {
      return rawData.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> imprimirEtiquetasLote(List<int> ids, String savePath) async {
    await _api.download(
      ApiEndpoints.relatorioEtiquetas,
      savePath,
      queryParameters: {'ids': ids.join(',')},
    );
  }
}
