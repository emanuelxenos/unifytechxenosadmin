import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unifytechxenosadmin/core/constants/api_endpoints.dart';
import 'package:unifytechxenosadmin/domain/models/user.dart';
import 'package:unifytechxenosadmin/domain/models/report.dart';
import 'package:unifytechxenosadmin/services/api_service.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(ref.read(apiServiceProvider));
}

class UserRepository {
  final ApiService _api;
  UserRepository(this._api);

  Future<List<Usuario>> listar() async {
    final response = await _api.get(ApiEndpoints.usuarios);
    final data = response.data;
    if (data is List) {
      return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> criar(CriarUsuarioRequest request) async {
    await _api.post(ApiEndpoints.usuarios, data: request.toJson());
  }

  Future<List<Configuracao>> listarConfigs() async {
    final response = await _api.get(ApiEndpoints.config);
    final data = response.data;
    if (data is List) {
      return data.map((e) => Configuracao.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => Configuracao.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> atualizarConfigs(AtualizarConfigRequest request) async {
    await _api.put(ApiEndpoints.config, data: request.toJson());
  }
}
