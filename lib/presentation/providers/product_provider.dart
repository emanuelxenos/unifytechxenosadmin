import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/product_repository.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';
import 'package:unifytechxenosadmin/domain/models/pagination.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'product_provider.g.dart';

class ProductState {
  final int page;
  final int limit;
  final int? categoriaId;
  final String search;
  final AsyncValue<PaginatedResponse<Produto>> response;

  ProductState({
    this.page = 1,
    this.limit = 50,
    this.categoriaId,
    this.search = '',
    this.response = const AsyncLoading(),
  });

  ProductState copyWith({
    int? page,
    int? limit,
    int? categoriaId,
    String? search,
    AsyncValue<PaginatedResponse<Produto>>? response,
  }) {
    return ProductState(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoriaId: categoriaId ?? this.categoriaId,
      search: search ?? this.search,
      response: response ?? this.response,
    );
  }
}

@riverpod
class Products extends _$Products {
  @override
  ProductState build() {
    Future.microtask(() => _load());
    return ProductState();
  }

  Future<void> _load() async {
    state = state.copyWith(response: const AsyncLoading());
    final repo = ref.read(productRepositoryProvider);
    
    final result = await AsyncValue.guard(() => repo.listar(
      page: state.page,
      limit: state.limit,
      categoriaId: state.categoriaId,
      search: state.search,
    ));
    
    state = state.copyWith(response: result);
  }

  Future<void> refresh() => _load();

  void setPage(int page) {
    if (page < 1) return;
    state = state.copyWith(page: page);
    _load();
  }

  void setCategoria(int? catId) {
    state = state.copyWith(categoriaId: catId, page: 1);
    _load();
  }

  void setSearch(String query) {
    state = state.copyWith(search: query, page: 1);
    _load();
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
AsyncValue<List<Produto>> filteredProducts(FilteredProductsRef ref) {
  final productsState = ref.watch(productsProvider);
  final query = ref.watch(productSearchProvider).toLowerCase();

  return productsState.response.when(
    data: (paginated) {
      final products = paginated.data;
      if (query.isEmpty) return AsyncValue.data(products);
      final filtered = products.where((p) {
        return p.nome.toLowerCase().contains(query) ||
            (p.codigoBarras?.toLowerCase().contains(query) ?? false) ||
            (p.categoriaNome?.toLowerCase().contains(query) ?? false);
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
}
