import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'stock_repository.g.dart';

@riverpod
StockRepository stockRepository(StockRepositoryRef ref) {
  return StockRepository(ref.read(apiServiceProvider));
}

class StockRepository {
  final ApiService _api;
  StockRepository(this._api);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<List<EstoqueBaixoResponse>> estoqueBaixo() async {
    final response = await _api.get(ApiEndpoints.estoqueBaixo);
    final data = _extractData(response.data);
    if (data is List) {
      return data.map((e) => EstoqueBaixoResponse.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> ajustarEstoque(AjusteEstoqueRequest request) async {
    await _api.post(ApiEndpoints.estoqueAjuste, data: request.toJson());
  }

  Future<void> criarInventario(CriarInventarioRequest request) async {
    await _api.post(ApiEndpoints.estoqueInventario, data: request.toJson());
  }
}
