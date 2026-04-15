import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/category.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'category_repository.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(ref.read(apiServiceProvider));
}

class CategoryRepository {
  final ApiService _api;

  CategoryRepository(this._api);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<List<Categoria>> listarCategorias() async {
    final response = await _api.get(ApiEndpoints.categorias);
    final data = _extractData(response.data);
    if (data is List) {
      return data
          .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Categoria> criarCategoria(CriarCategoriaRequest request) async {
    final response = await _api.post(
      ApiEndpoints.categorias,
      data: request.toJson(),
    );
    final data = _extractData(response.data);
    return Categoria.fromJson(data as Map<String, dynamic>);
  }

  Future<void> atualizarCategoria(int id, CriarCategoriaRequest request) async {
    await _api.put(
      ApiEndpoints.categoriaPorId(id),
      data: request.toJson(),
    );
  }

  Future<void> inativarCategoria(int id) async {
    await _api.delete(ApiEndpoints.categoriaPorId(id));
  }
}
