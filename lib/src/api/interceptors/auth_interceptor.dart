import 'package:dio/dio.dart';

/// Interceptor for adding authentication headers to all API requests.
/// 
/// This interceptor automatically adds the API key to the Authorization header
/// for all outgoing requests. It supports both Bearer token and API key formats.
class AuthInterceptor extends Interceptor {
  /// The API key to use for authentication.
  final String apiKey;
  
  /// The authentication type (Bearer or ApiKey).
  final AuthType authType;
  
  /// Custom header name for API key (if not using Bearer).
  final String? customHeaderName;

  AuthInterceptor({
    required this.apiKey,
    this.authType = AuthType.bearer,
    this.customHeaderName,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    switch (authType) {
      case AuthType.bearer:
        options.headers['Authorization'] = 'Bearer $apiKey';
        break;
      case AuthType.apiKey:
        final headerName = customHeaderName ?? 'X-API-Key';
        options.headers[headerName] = apiKey;
        break;
      case AuthType.custom:
        if (customHeaderName != null) {
          options.headers[customHeaderName!] = apiKey;
        }
        break;
    }
    
    super.onRequest(options, handler);
  }
}

/// Enum representing different authentication types.
enum AuthType {
  /// Bearer token authentication (default).
  bearer,
  
  /// API key authentication.
  apiKey,
  
  /// Custom header authentication.
  custom,
}

