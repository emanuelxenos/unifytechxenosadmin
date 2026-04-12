import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/supplier_repository.dart';
import 'package:unifytechxenosadmin/domain/models/supplier.dart';

part 'supplier_provider.g.dart';

@riverpod
class Suppliers extends _$Suppliers {
  @override
  FutureOr<List<Fornecedor>> build() async {
    return _fetch();
  }

  Future<List<Fornecedor>> _fetch() async {
    return ref.read(supplierRepositoryProvider).listar();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<(bool, String)> criar(CriarFornecedorRequest request) async {
    try {
      await ref.read(supplierRepositoryProvider).criar(request);
      await refresh();
      return (true, 'Fornecedor cadastrado com sucesso');
    } catch (e) {
      return (false, 'Erro ao cadastrar fornecedor: $e');
    }
  }

  Future<(bool, String)> atualizar(int id, CriarFornecedorRequest request) async {
    try {
      await ref.read(supplierRepositoryProvider).atualizar(id, request);
      await refresh();
      return (true, 'Fornecedor atualizado com sucesso');
    } catch (e) {
      return (false, 'Erro ao atualizar fornecedor: $e');
    }
  }

  Future<(bool, String)> inativar(int id) async {
    try {
      await ref.read(supplierRepositoryProvider).inativar(id);
      await refresh();
      return (true, 'Fornecedor inativado com sucesso');
    } catch (e) {
      return (false, 'Erro ao inativar fornecedor: $e');
    }
  }
}

@riverpod
List<Fornecedor> filteredSuppliers(FilteredSuppliersRef ref) {
  final suppliersAsync = ref.watch(suppliersProvider);
  final query = ref.watch(supplierSearchProvider).toLowerCase();

  return suppliersAsync.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((s) => 
        s.razaoSocial.toLowerCase().contains(query) ||
        (s.nomeFantasia?.toLowerCase().contains(query) ?? false) ||
        (s.cnpj?.contains(query) ?? false)
      ).toList();
    },
    orElse: () => [],
  );
}

@riverpod
class SupplierSearch extends _$SupplierSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}
