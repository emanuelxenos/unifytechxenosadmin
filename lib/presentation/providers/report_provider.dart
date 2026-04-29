import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/report_repository.dart';
import 'package:unifytechxenosadmin/domain/models/report.dart';

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
  Future<List<Map<String, dynamic>>> build({int? categoriaId}) async {
    return ref.read(reportRepositoryProvider).maisVendidos(categoriaId: categoriaId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).maisVendidos(categoriaId: categoriaId));
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
  Future<RelatorioEstoque> build() async {
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

@riverpod
class DreReport extends _$DreReport {
  @override
  Future<Map<String, dynamic>> build({int? mes, int? ano}) async {
    return ref.read(reportRepositoryProvider).dre(mes: mes, ano: ano);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).dre(mes: mes, ano: ano));
  }
}

@riverpod
class InadimplenciaReport extends _$InadimplenciaReport {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).inadimplencia();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).inadimplencia());
  }
}

@riverpod
class CurvaABCReport extends _$CurvaABCReport {
  @override
  Future<Map<String, dynamic>> build() async {
    return ref.read(reportRepositoryProvider).curvaABC();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).curvaABC());
  }
}

@riverpod
class ComissoesReport extends _$ComissoesReport {
  @override
  Future<Map<String, dynamic>> build({int? mes, int? ano}) async {
    return ref.read(reportRepositoryProvider).comissoes(mes: mes, ano: ano);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).comissoes(mes: mes, ano: ano));
  }
}

@riverpod
class RankingClientesReport extends _$RankingClientesReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).rankingClientes();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).rankingClientes());
  }
}

@riverpod
class ClientesInativosReport extends _$ClientesInativosReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).clientesInativos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).clientesInativos());
  }
}

@riverpod
class ClientesAusentesReport extends _$ClientesAusentesReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).clientesAusentes(dias: 30);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).clientesAusentes(dias: 30));
  }
}

@riverpod
class DreDetalhadoReport extends _$DreDetalhadoReport {
  @override
  Future<Map<String, dynamic>> build({int? mes, int? ano}) async {
    return ref.read(reportRepositoryProvider).dreDetalhado(mes: mes, ano: ano);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).dreDetalhado(mes: mes, ano: ano));
  }
}

@riverpod
class ProjecaoCaixaReport extends _$ProjecaoCaixaReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).projecaoCaixa();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).projecaoCaixa());
  }
}

@riverpod
class CancelamentosReport extends _$CancelamentosReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).cancelamentos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).cancelamentos());
  }
}

@riverpod
class GiroEstoqueReport extends _$GiroEstoqueReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).giroEstoque();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).giroEstoque());
  }
}

@riverpod
class RupturaEstoqueReport extends _$RupturaEstoqueReport {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(reportRepositoryProvider).rupturaEstoque();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportRepositoryProvider).rupturaEstoque());
  }
}
