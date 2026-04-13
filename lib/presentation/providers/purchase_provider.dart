import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/purchase_repository.dart';
import 'package:unifytechxenosadmin/domain/models/purchase.dart';
import 'package:unifytechxenosadmin/presentation/providers/product_provider.dart';
import 'package:unifytechxenosadmin/presentation/providers/stock_provider.dart';

part 'purchase_provider.g.dart';

class PurchaseFilters {
  final String? status;
  final String? notaFiscal;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const PurchaseFilters({this.status, this.notaFiscal, this.dataInicio, this.dataFim});

  PurchaseFilters copyWith({
    String? status,
    String? notaFiscal,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return PurchaseFilters(
      status: status ?? this.status,
      notaFiscal: notaFiscal ?? this.notaFiscal,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
    );
  }
}

@riverpod
class Purchases extends _$Purchases {
  @override
  FutureOr<List<Compra>> build() async {
    final filters = ref.watch(purchaseFilterStateProvider);
    return _fetch(filters);
  }

  Future<List<Compra>> _fetch(PurchaseFilters filters) async {
    return ref.read(purchaseRepositoryProvider).listar(
      status: filters.status,
      notaFiscal: filters.notaFiscal,
      dataInicio: filters.dataInicio,
      dataFim: filters.dataFim,
    );
  }

  Future<void> refresh() async {
    final filters = ref.read(purchaseFilterStateProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(filters));
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

@riverpod
class PurchaseFilterState extends _$PurchaseFilterState {
  @override
  PurchaseFilters build() => const PurchaseFilters();

  void setStatus(String? status) => state = state.copyWith(status: status);
  void setNotaFiscal(String? nf) => state = state.copyWith(notaFiscal: nf);
  void setRange(DateTimeRange? range) => state = state.copyWith(
    dataInicio: range?.start,
    dataFim: range?.end,
  );
  void clear() => state = const PurchaseFilters();
}

@riverpod
Future<Compra> purchaseDetail(PurchaseDetailRef ref, int id) {
  return ref.read(purchaseRepositoryProvider).buscarPorID(id);
}
