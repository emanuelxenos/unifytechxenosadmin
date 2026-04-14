import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/data/repositories/empresa_repository.dart';
import 'package:unifytechxenosadmin/domain/models/company.dart';

part 'empresa_provider.g.dart';

@riverpod
class EmpresaState extends _$EmpresaState {
  @override
  FutureOr<Empresa> build() async {
    return ref.read(empresaRepositoryProvider).buscar();
  }

  Future<void> atualizarEmpresa(Empresa empresa) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(empresaRepositoryProvider).atualizar(empresa);
      return empresa;
    });
  }
}
