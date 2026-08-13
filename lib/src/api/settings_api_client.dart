import 'api_client.dart';

/// API client for Lableb's settings endpoint, which is hosted on a
/// different host (`platform-integration-service.lableb.com`) than the
/// rest of the SDK's endpoints (`api.lableb.com` / `sandbox-api.lableb.com`).
class SettingsApiClient extends ApiClient {
  SettingsApiClient({
    required String apiKey,
    bool enableLogging = false,
  }) : super(
          baseUrl: 'https://platform-integration-service.lableb.com',
          apiKey: apiKey,
          enableLogging: enableLogging,
        );
}
