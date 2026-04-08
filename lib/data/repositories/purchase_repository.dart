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

  Future<void> criar(CriarCompraRequest request) async {
    await _api.post(ApiEndpoints.compras, data: request.toJson());
  }

  Future<void> receber(int id, ReceberCompraRequest request) async {
    await _api.post(ApiEndpoints.compraReceber(id), data: request.toJson());
  }
}
