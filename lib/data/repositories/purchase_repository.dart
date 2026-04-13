import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'purchase_repository.g.dart';

@riverpod
PurchaseRepository purchaseRepository(PurchaseRepositoryRef ref) {
  return PurchaseRepository(ref.read(apiServiceProvider));
}

class PurchaseRepository {
  final ApiService _api;
  PurchaseRepository(this._api);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<void> criar(CriarCompraRequest request) async {
    await _api.post(ApiEndpoints.compras, data: request.toJson());
  }

  Future<List<Compra>> listar({int? fornecedorId}) async {
    final queryParams = <String, dynamic>{};
    if (fornecedorId != null && fornecedorId > 0) {
      queryParams['fornecedor_id'] = fornecedorId;
    }

    final response = await _api.get(
      ApiEndpoints.compras,
      queryParameters: queryParams,
    );
    final data = _extractData(response.data);
    if (data is List) {
      return data.map((e) => Compra.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> receber(int id, ReceberCompraRequest request) async {
    await _api.post(ApiEndpoints.compraReceber(id), data: request.toJson());
  }
}
