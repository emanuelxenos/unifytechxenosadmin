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
class PhysicalTerminals extends _$PhysicalTerminals {
  @override
  Future<List<CaixaFisico>> build() async {
    return ref.read(caixaRepositoryProvider).listarCaixasFisicos();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<bool> criar(Map<String, dynamic> data) async {
    try {
      await ref.read(caixaRepositoryProvider).criarCaixaFisico(data);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> atualizar(int id, Map<String, dynamic> data) async {
    try {
      await ref.read(caixaRepositoryProvider).atualizarCaixaFisico(id, data);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> excluir(int id) async {
    try {
      await ref.read(caixaRepositoryProvider).excluirCaixaFisico(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
FutureOr<CaixaStatusResponse> caixaStatus(CaixaStatusRef ref) {
  return ref.read(caixaRepositoryProvider).status();
}
