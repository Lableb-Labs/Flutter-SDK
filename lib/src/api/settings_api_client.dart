import 'api_client.dart';

/// API client for Lableb's settings endpoint, which is hosted on a
/// different host (`platform-integration-service.lableb.com`) than the
/// rest of the SDK's endpoints (`api.lableb.com` / `sandbox-api.lableb.com`).
class SettingsApiClient extends ApiClient {
  SettingsApiClient({
    required super.apiKey,
    super.enableLogging,
  }) : super(
          baseUrl: 'https://platform-integration-service.lableb.com',
        );
}
