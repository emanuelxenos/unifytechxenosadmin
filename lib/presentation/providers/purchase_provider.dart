import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/purchase_repository.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';

part 'purchase_provider.g.dart';

@riverpod
class PurchaseActions extends _$PurchaseActions {
  @override
  bool build() => false;

  Future<bool> criar(CriarCompraRequest request) async {
    try {
      await ref.read(purchaseRepositoryProvider).criar(request);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> receber(int id, ReceberCompraRequest request) async {
    try {
      await ref.read(purchaseRepositoryProvider).receber(id, request);
      return true;
    } catch (_) {
      return false;
    }
  }
}
