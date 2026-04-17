import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/caixa_repository.dart';
import 'package:unifytechxenosadmin/domain/models/caixa.dart';

part 'caixa_provider.g.dart';

@riverpod
class CaixaSessions extends _$CaixaSessions {
  @override
  Future<List<SessaoCaixa>> build({String? inicio, String? fim}) async {
    return ref.read(caixaRepositoryProvider).sessoes(inicio: inicio, fim: fim);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(inicio: inicio, fim: fim));
  }
}

@riverpod
class CaixaMovements extends _$CaixaMovements {
  @override
  Future<List<CaixaMovimentacao>> build({String? inicio, String? fim}) async {
    return ref.read(caixaRepositoryProvider).movimentacoes(inicio: inicio, fim: fim);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(inicio: inicio, fim: fim));
  }
}

@riverpod
FutureOr<CaixaStatusResponse> caixaStatus(CaixaStatusRef ref) {
  return ref.read(caixaRepositoryProvider).status();
}
