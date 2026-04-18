import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/customer.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'customer_repository.g.dart';

@riverpod
CustomerRepository customerRepository(CustomerRepositoryRef ref) {
  return CustomerRepository(ref.read(apiServiceProvider));
}

class CustomerRepository {
  final ApiService _api;

  CustomerRepository(this._api);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<List<Cliente>> listar({bool incluirInativos = false}) async {
    final response = await _api.get(
      ApiEndpoints.clientes,
      queryParameters: {'incluir_inativos': incluirInativos},
    );
    final data = _extractData(response.data);
    if (data is List) {
      return data
          .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Cliente> criar(CriarClienteRequest request) async {
    final response =
        await _api.post(ApiEndpoints.clientes, data: request.toJson());
    final data = _extractData(response.data);
    return Cliente.fromJson(data as Map<String, dynamic>);
  }

  Future<void> atualizar(int id, CriarClienteRequest request) async {
    await _api.put(ApiEndpoints.clientePorId(id), data: request.toJson());
  }

  Future<void> inativar(int id) async {
    await _api.delete(ApiEndpoints.clientePorId(id));
  }
}
