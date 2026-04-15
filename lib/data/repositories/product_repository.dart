import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.read(apiServiceProvider));
}

class ProductRepository {
  final ApiService _api;

  ProductRepository(this._api);

  /// Extrai os dados da resposta do backend.
  /// O Go retorna: { "success": true, "data": ... }
  /// ou Paginated: { "success": true, "data": [...], "total": N, "page": N }
  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<List<Produto>> listar() async {
    final response = await _api.get(ApiEndpoints.produtos);
    final data = _extractData(response.data);
    if (data is List) {
      return data
          .map((e) => Produto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<Produto>> buscar(String query) async {
    final response = await _api.get(
      ApiEndpoints.produtosBusca,
      queryParameters: {'nome': query},
    );
    final data = _extractData(response.data);
    if (data is List) {
      return data
          .map((e) => Produto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // A busca do backend pode retornar um único produto
    if (data is Map<String, dynamic>) {
      return [Produto.fromJson(data)];
    }
    return [];
  }

  Future<Produto> buscarPorId(int id) async {
    final response = await _api.get(ApiEndpoints.produtoPorId(id));
    final data = _extractData(response.data);
    return Produto.fromJson(data as Map<String, dynamic>);
  }

  Future<Produto> criar(CriarProdutoRequest request) async {
    final response = await _api.post(
      ApiEndpoints.produtos,
      data: request.toJson(),
    );
    final data = _extractData(response.data);
    return Produto.fromJson(data as Map<String, dynamic>);
  }

  Future<void> atualizar(int id, CriarProdutoRequest request) async {
    await _api.put(
      ApiEndpoints.produtoPorId(id),
      data: request.toJson(),
    );
  }

  Future<void> inativar(int id) async {
    await _api.delete(ApiEndpoints.produtoPorId(id));
  }

}
