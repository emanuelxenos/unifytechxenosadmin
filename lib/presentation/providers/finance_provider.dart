import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/finance_repository.dart';
import 'package:unifytechxenosadmin/domain/models/account_payable.dart';
import 'package:unifytechxenosadmin/domain/models/account_receivable.dart';
import 'package:unifytechxenosadmin/domain/models/report.dart';

part 'finance_provider.g.dart';

@riverpod
class AccountsPayable extends _$AccountsPayable {
  @override
  Future<List<ContaPagar>> build() async {
    return ref.read(financeRepositoryProvider).contasPagar();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(financeRepositoryProvider).contasPagar());
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
    return ref.read(financeRepositoryProvider).contasReceber();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(financeRepositoryProvider).contasReceber());
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
    return ref.read(financeRepositoryProvider).fluxoCaixa();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(financeRepositoryProvider).fluxoCaixa());
  }
}
