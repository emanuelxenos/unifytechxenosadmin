import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';
import 'package:unifytechxenosadmin/domain/models/system_parameters.dart';

part 'system_parameters_repository.g.dart';

@riverpod
SystemParametersRepository systemParametersRepository(SystemParametersRepositoryRef ref) {
  return SystemParametersRepository(ref.read(apiServiceProvider));
}

class SystemParametersRepository {
  final ApiService _api;
  SystemParametersRepository(this._api);

  Future<SystemParameters> getParameters() async {
    final response = await _api.get('/api/empresa/config');
    final data = response.data['data'] as Map<String, dynamic>;
    return SystemParameters.fromJson(data);
  }

  Future<void> updateParameters(SystemParameters params) async {
    await _api.put('/api/empresa/config', data: params.toJson());
  }
}
