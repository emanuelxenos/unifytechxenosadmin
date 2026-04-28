import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/customer_repository.dart';
import 'package:unifytechxenosadmin/domain/models/customer.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'customer_provider.g.dart';

@riverpod
class Customers extends _$Customers {
  @override
  FutureOr<List<Cliente>> build() async {
    final incluirInativos = ref.watch(customerInactivesProvider);
    return _fetch(incluirInativos);
  }

  Future<List<Cliente>> _fetch(bool incluirInativos) async {
    return ref
        .read(customerRepositoryProvider)
        .listar(incluirInativos: incluirInativos);
  }

  Future<void> refresh() async {
    final incluirInativos = ref.read(customerInactivesProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(incluirInativos));
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
  final query = ref.watch(customerSearchProvider).toLowerCase();

  return customersAsync.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;
      return list
          .where((c) =>
              c.nome.toLowerCase().contains(query) ||
              (c.cpfCnpj?.contains(query) ?? false) ||
              (c.email?.toLowerCase().contains(query) ?? false))
          .toList();
    },
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
