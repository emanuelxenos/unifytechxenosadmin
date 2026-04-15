import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/category_repository.dart';
import 'package:unifytechxenosadmin/domain/models/category.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'category_provider.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<List<Categoria>> build() async {
    return ref.read(categoryRepositoryProvider).listarCategorias();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(categoryRepositoryProvider).listarCategorias());
  }

  Future<(bool, String)> criar(CriarCategoriaRequest request) async {
    try {
      await ref.read(categoryRepositoryProvider).criarCategoria(request);
      await refresh();
      return (true, 'Categoria cadastrada com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> atualizar(int id, CriarCategoriaRequest request) async {
    try {
      await ref.read(categoryRepositoryProvider).atualizarCategoria(id, request);
      await refresh();
      return (true, 'Categoria atualizada com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> inativar(int id) async {
    try {
      await ref.read(categoryRepositoryProvider).inativarCategoria(id);
      await refresh();
      return (true, 'Categoria inativada com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
}
