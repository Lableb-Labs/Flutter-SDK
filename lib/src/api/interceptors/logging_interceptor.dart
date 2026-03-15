import 'package:dio/dio.dart';

/// Interceptor for logging HTTP requests and responses.
/// 
/// This interceptor logs request/response details for debugging purposes.
/// It should only be enabled in debug mode to avoid performance overhead
/// and potential security issues in production.
class LoggingInterceptor extends Interceptor {
  /// Whether to log request body.
  final bool logRequestBody;
  
  /// Whether to log response body.
  final bool logResponseBody;
  
  /// Whether to log headers.
  final bool logHeaders;
  
  /// Whether logging is enabled.
  final bool enabled;

  LoggingInterceptor({
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logHeaders = false,
    this.enabled = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) {
      super.onRequest(options, handler);
      return;
    }

    // ignore: avoid_print
    print('┌─────────────────────────────────────────────────────────');
    // ignore: avoid_print
    print('│ REQUEST: ${options.method} ${options.uri}');
    
    if (logHeaders && options.headers.isNotEmpty) {
      // ignore: avoid_print
      print('│ Headers:');
      options.headers.forEach((key, value) {
        // ignore: avoid_print
        print('│   $key: $value');
      });
    }
    
    if (logRequestBody && options.data != null) {
      // ignore: avoid_print
      print('│ Body: ${options.data}');
    }
    
    // ignore: avoid_print
    print('└─────────────────────────────────────────────────────────');
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) {
      super.onResponse(response, handler);
      return;
    }

    // ignore: avoid_print
    print('┌─────────────────────────────────────────────────────────');
    // ignore: avoid_print
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    
    if (logResponseBody && response.data != null) {
      // ignore: avoid_print
      print('│ Body: ${response.data}');
    }
    
    // ignore: avoid_print
    print('└─────────────────────────────────────────────────────────');
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      super.onError(err, handler);
      return;
    }

    // ignore: avoid_print
    print('┌─────────────────────────────────────────────────────────');
    // ignore: avoid_print
    print('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    // ignore: avoid_print
    print('│ Status: ${err.response?.statusCode ?? 'N/A'}');
    // ignore: avoid_print
    print('│ Message: ${err.message}');
    
    if (err.response?.data != null) {
      // ignore: avoid_print
      print('│ Response: ${err.response?.data}');
    }
    
    // ignore: avoid_print
    print('└─────────────────────────────────────────────────────────');
    
    super.onError(err, handler);
  }
}

