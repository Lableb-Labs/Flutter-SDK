import '../../api/settings_api_client.dart';
import '../../domain/entities/global_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../responses/settings_response.dart';

/// Implementation of [SettingsRepository] for the Lableb settings endpoint.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsApiClient _apiClient;

  SettingsRepositoryImpl(this._apiClient);

  @override
  Future<GlobalSettings> getSettings({required String platformName}) async {
    final response = await _apiClient.get(
      '/v2/projects/$platformName/settings',
    );

    return SettingsResponse.fromJson(
      response.data as Map<String, dynamic>,
    ).toEntity();
  }
}
