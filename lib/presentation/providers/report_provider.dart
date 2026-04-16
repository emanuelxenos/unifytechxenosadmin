import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/report_repository.dart';

part 'report_provider.g.dart';

@riverpod
class SalesReportDay extends _$SalesReportDay {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).vendasDia();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).vendasDia());
  }
}

@riverpod
class SalesReportMonth extends _$SalesReportMonth {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).vendasMes();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).vendasMes());
  }
}

@riverpod
class BestSellers extends _$BestSellers {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).maisVendidos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).maisVendidos());
  }
}

@riverpod
class SalesReportPeriod extends _$SalesReportPeriod {
  @override
  Future<Map<String, dynamic>> build(String dataInicio, String dataFim) async {
    return ref.read(reportRepositoryProvider).vendasPeriodo(dataInicio, dataFim);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).vendasPeriodo(dataInicio, dataFim));
  }
}

@riverpod
class StockReport extends _$StockReport {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).estoqueResumo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).estoqueResumo());
  }
}

@riverpod
class FinanceReport extends _$FinanceReport {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).financeiroResumo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).financeiroResumo());
  }
}
