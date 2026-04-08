import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/sale_repository.dart';
import 'package:unifytechxenosadmin/domain/models/sale.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'sale_provider.g.dart';

@riverpod
class SalesToday extends _$SalesToday {
  @override
  Future<List<Venda>> build() async {
    return ref.read(saleRepositoryProvider).vendasDia();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(saleRepositoryProvider).vendasDia());
  }
}

@riverpod
class SaleDetail extends _$SaleDetail {
  @override
  Future<Venda?> build(int id) async {
    return ref.read(saleRepositoryProvider).buscarPorId(id);
  }
}

@riverpod
class SaleActions extends _$SaleActions {
  @override
  bool build() => false;

  Future<(bool, String)> cancelar(int id, CancelarVendaRequest request) async {
    try {
      await ref.read(saleRepositoryProvider).cancelar(id, request);
      ref.invalidate(salesTodayProvider);
      return (true, 'Venda cancelada com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
}
