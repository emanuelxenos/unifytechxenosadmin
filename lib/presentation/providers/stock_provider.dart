import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/stock_repository.dart';
import 'package:unifytechxenosadmin/domain/models/stock_movement.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'stock_provider.g.dart';

@riverpod
class LowStock extends _$LowStock {
  @override
  Future<List<EstoqueBaixoResponse>> build() async {
    return ref.read(stockRepositoryProvider).estoqueBaixo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(stockRepositoryProvider).estoqueBaixo());
  }
}

@riverpod
class StockActions extends _$StockActions {
  @override
  bool build() => false;

  Future<(bool, String)> ajustar(AjusteEstoqueRequest request) async {
    try {
      await ref.read(stockRepositoryProvider).ajustarEstoque(request);
      ref.invalidate(lowStockProvider);
      return (true, 'Estoque ajustado com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }

  Future<(bool, String)> criarInventario(CriarInventarioRequest request) async {
    try {
      await ref.read(stockRepositoryProvider).criarInventario(request);
      return (true, 'Inventário criado com sucesso!');
    } catch (e) {
      return (false, ApiService.extractError(e));
    }
  }
}

@riverpod
class StockMovements extends _$StockMovements {
  @override
  Future<List<EstoqueMovimentacao>> build({int? produtoId, DateTime? inicio, DateTime? fim}) async {
    return ref.read(stockRepositoryProvider).listarMovimentacoes(
      produtoId: produtoId,
      inicio: inicio,
      fim: fim,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(stockRepositoryProvider).listarMovimentacoes(
      produtoId: produtoId,
      inicio: inicio,
      fim: fim,
    ));
  }
}

@riverpod
class Inventories extends _$Inventories {
  @override
  Future<List<Inventario>> build() async {
    return ref.read(stockRepositoryProvider).listarInventarios();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(stockRepositoryProvider).listarInventarios());
  }
}
