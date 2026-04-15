import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/product_repository.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'product_provider.g.dart';

@riverpod
class Products extends _$Products {
  @override
  Future<List<Produto>> build() async {
    return ref.read(productRepositoryProvider).listar();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(productRepositoryProvider).listar());
  }

  Future<(bool, String)> criar(CriarProdutoRequest request) async {
    try {
      await ref.read(productRepositoryProvider).criar(request);
      await refresh();
      return (true, 'Produto cadastrado com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> atualizar(int id, CriarProdutoRequest request) async {
    try {
      await ref.read(productRepositoryProvider).atualizar(id, request);
      await refresh();
      return (true, 'Produto atualizado com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> inativar(int id) async {
    try {
      await ref.read(productRepositoryProvider).inativar(id);
      await refresh();
      return (true, 'Produto inativado com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
}

@riverpod
class ProductSearch extends _$ProductSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@riverpod
List<Produto> filteredProducts(FilteredProductsRef ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(productSearchProvider).toLowerCase();

  return productsAsync.when(
    data: (products) {
      if (query.isEmpty) return products;
      return products.where((p) {
        return p.nome.toLowerCase().contains(query) ||
            (p.codigoBarras?.toLowerCase().contains(query) ?? false) ||
            (p.categoriaNome?.toLowerCase().contains(query) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
}

