import '../entities/global_settings_entity.dart';

/// Repository for fetching Lableb's merchant-level dashboard settings.
abstract class SettingsRepository {
  /// Fetches the global settings for the given Lableb project id
  /// (`platformName`), e.g. `zid_56705`.
  Future<GlobalSettings> getSettings({required String platformName});
}
