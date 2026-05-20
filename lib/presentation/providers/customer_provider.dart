import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/customer_repository.dart';
import 'package:unifytechxenosadmin/domain/models/customer.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'customer_provider.g.dart';

final customerPageProvider = StateProvider<int>((ref) => 0);
final customerItemsPerPageProvider = StateProvider<int>((ref) => 10);

class PaginatedCustomersResult {
  final List<Cliente> clientes;
  final int total;

  PaginatedCustomersResult({required this.clientes, required this.total});
}

@riverpod
class Customers extends _$Customers {
  @override
  FutureOr<PaginatedCustomersResult> build() async {
    final incluirInativos = ref.watch(customerInactivesProvider);
    final page = ref.watch(customerPageProvider);
    final limit = ref.watch(customerItemsPerPageProvider);
    final search = ref.watch(customerSearchProvider);
    return _fetch(incluirInativos, page + 1, limit, search);
  }

  Future<PaginatedCustomersResult> _fetch(
      bool incluirInativos, int page, int limit, String search) async {
    final (list, total) = await ref
        .read(customerRepositoryProvider)
        .listarPaginado(
            incluirInativos: incluirInativos,
            page: page,
            limit: limit,
            search: search);
    return PaginatedCustomersResult(clientes: list, total: total);
  }

  Future<void> refresh() async {
    final incluirInativos = ref.read(customerInactivesProvider);
    final page = ref.read(customerPageProvider);
    final limit = ref.read(customerItemsPerPageProvider);
    final search = ref.read(customerSearchProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _fetch(incluirInativos, page + 1, limit, search));
  }

  Future<(bool, String)> criar(CriarClienteRequest request) async {
    try {
      await ref.read(customerRepositoryProvider).criar(request);
      await refresh();
      return (true, 'Cliente cadastrado com sucesso');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> atualizar(int id, CriarClienteRequest request) async {
    try {
      await ref.read(customerRepositoryProvider).atualizar(id, request);
      await refresh();
      return (true, 'Cliente atualizado com sucesso');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> inativar(int id) async {
    try {
      await ref.read(customerRepositoryProvider).inativar(id);
      await refresh();
      return (true, 'Cliente inativado com sucesso');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
  Future<(bool, String)> amortizarDivida(int id, int vendaId, double valor) async {
    try {
      await ref.read(customerRepositoryProvider).amortizar(id, vendaId, valor);
      await refresh();
      return (true, 'Dívida amortizada com sucesso');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
}

@riverpod
List<Cliente> filteredCustomers(FilteredCustomersRef ref) {
  final customersAsync = ref.watch(customersProvider);

  return customersAsync.maybeWhen(
    data: (res) => res.clientes,
    orElse: () => [],
  );
}

@riverpod
class CustomerSearch extends _$CustomerSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@riverpod
class CustomerInactives extends _$CustomerInactives {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@riverpod
Future<List<Venda>> customerHistory(CustomerHistoryRef ref, int clienteId) async {
  final data = await ref.read(customerRepositoryProvider).listarCompras(clienteId);
  return data.map((e) => Venda.fromJson(e as Map<String, dynamic>)).toList();
}

@riverpod
Future<List<AmortizacaoHistorico>> customerAmortizations(CustomerAmortizationsRef ref, int clienteId) async {
  final data = await ref.read(customerRepositoryProvider).listarAmortizacoes(clienteId);
  return data.map((e) => AmortizacaoHistorico.fromJson(e as Map<String, dynamic>)).toList();
}
