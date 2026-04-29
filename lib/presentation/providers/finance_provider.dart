import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/finance_repository.dart';
import 'package:unifytechxenosadmin/domain/models/account_payable.dart';
import 'package:unifytechxenosadmin/domain/models/account_receivable.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';
import 'package:unifytechxenosadmin/domain/models/report.dart';

part 'finance_provider.g.dart';

@riverpod
class AccountsPayable extends _$AccountsPayable {
  @override
  Future<List<ContaPagar>> build() async {
    final filters = ref.watch(financialFiltersProvider);
    return ref.read(financeRepositoryProvider).contasPagar(
      vencInicio: filters.start?.toString().split(' ')[0],
      vencFim: filters.end?.toString().split(' ')[0],
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<bool> criar(CriarContaPagarRequest request) async {
    try {
      await ref.read(financeRepositoryProvider).criarContaPagar(request);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pagar(int id, PagarContaRequest request) async {
    try {
      await ref.read(financeRepositoryProvider).pagarConta(id, request);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
class AccountsReceivable extends _$AccountsReceivable {
  @override
  Future<List<ContaReceber>> build() async {
    final filters = ref.watch(financialFiltersProvider);
    return ref.read(financeRepositoryProvider).contasReceber(
      vencInicio: filters.start?.toString().split(' ')[0],
      vencFim: filters.end?.toString().split(' ')[0],
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<bool> criar(CriarContaReceberRequest request) async {
    try {
      await ref.read(financeRepositoryProvider).criarContaReceber(request);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> receber(int id, ReceberContaRequest request) async {
    try {
      await ref.read(financeRepositoryProvider).receberConta(id, request);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
class CashFlow extends _$CashFlow {
  @override
  Future<FluxoCaixaResponse> build() async {
    final filters = ref.watch(financialFiltersProvider);
    return ref.read(financeRepositoryProvider).fluxoCaixa(
      dataInicio: filters.start?.toString().split(' ')[0],
      dataFim: filters.end?.toString().split(' ')[0],
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class FinancialFilters extends _$FinancialFilters {
  @override
  ({DateTime? start, DateTime? end}) build() => (start: null, end: null);

  void setRange(DateTime? start, DateTime? end) {
    state = (start: start, end: end);
  }
}
