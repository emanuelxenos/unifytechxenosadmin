import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/supplier.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'supplier_repository.g.dart';

@riverpod
SupplierRepository supplierRepository(SupplierRepositoryRef ref) {
  return SupplierRepository(ref.read(apiServiceProvider));
}

class SupplierRepository {
  final ApiService _api;

  SupplierRepository(this._api);

  Future<List<Fornecedor>> listar() async {
    final response = await _api.get(ApiEndpoints.fornecedores);
    final data = response.data;
    if (data is List) {
      return data.map((e) => Fornecedor.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => Fornecedor.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Fornecedor> criar(CriarFornecedorRequest request) async {
    final response = await _api.post(ApiEndpoints.fornecedores, data: request.toJson());
    return Fornecedor.fromJson(response.data as Map<String, dynamic>);
  }
}
