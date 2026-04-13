import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/purchase_repository.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';

part 'purchase_provider.g.dart';

@riverpod
class Purchases extends _$Purchases {
  @override
  FutureOr<List<Compra>> build() async {
    return _fetch();
  }

  Future<List<Compra>> _fetch() async {
    return ref.read(purchaseRepositoryProvider).listar();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

@riverpod
class PurchaseActions extends _$PurchaseActions {
  @override
  bool build() => false;

  Future<(bool, String)> criar(CriarCompraRequest request) async {
    try {
      await ref.read(purchaseRepositoryProvider).criar(request);
      ref.invalidate(purchasesProvider);
      return (true, 'Compra registrada com sucesso');
    } catch (e) {
      return (false, 'Erro ao registrar compra: $e');
    }
  }

  Future<(bool, String)> receber(int id, ReceberCompraRequest request) async {
    try {
      await ref.read(purchaseRepositoryProvider).receber(id, request);
      ref.invalidate(purchasesProvider);
      ref.invalidate(productsProvider); 
      ref.invalidate(lowStockProvider);
      return (true, 'Compra marcada como recebida');
    } catch (e) {
      return (false, 'Erro ao receber compra: $e');
    }
  }
}

@riverpod
Future<List<Compra>> supplierHistory(SupplierHistoryRef ref, int supplierId) {
  if (supplierId == 0) return Future.value([]);
  return ref.read(purchaseRepositoryProvider).listar(fornecedorId: supplierId);
}
