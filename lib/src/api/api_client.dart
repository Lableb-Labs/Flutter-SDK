import 'package:dio/dio.dart';
import '../exceptions/exceptions.dart';
import 'interceptors/logging_interceptor.dart';

/// Abstract base for the SDK API client.
///
/// Register and depend on this type to keep the SDK decoupled and testable.
abstract interface class ApiClientBase {
  Dio get dio;
  String get baseUrl;
  String get apiKeySearch;
  String get apiKeyIndex;
  Duration get connectTimeout;
  Duration get receiveTimeout;
  Duration get sendTimeout;

  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
}

/// API client for making HTTP requests to the Lableb API.
///
/// This class wraps Dio and provides a clean interface for making
/// authenticated requests with proper error handling and retry logic.
class ApiClient implements ApiClientBase {
  /// The underlying Dio instance.
  final Dio _dio;

  /// Base URL for the API.
  @override
  final String baseUrl;

  /// API key used for search and all non-index requests.
  @override
  final String apiKeySearch;

  /// API key used for index create/update/delete requests.
  @override
  final String apiKeyIndex;

  /// Optional project identifier used to prefix all relative endpoints.
  final String? projectId;

  /// Optional index identifier used to prefix all relative endpoints.
  final String? indexName;

  /// Connection timeout in milliseconds.
  @override
  final Duration connectTimeout;

  /// Receive timeout in milliseconds.
  @override
  final Duration receiveTimeout;

  /// Send timeout in milliseconds.
  @override
  final Duration sendTimeout;

  final String _pathPrefix;

  static String _buildPathPrefix(String? projectId, String? indexName) {
    if (projectId == null ||
        projectId.trim().isEmpty ||
        indexName == null ||
        indexName.trim().isEmpty) {
      return '';
    }
    return '/v2/projects/${projectId.trim()}/indices/${indexName.trim()}';
  }

  ApiClient({
    required this.baseUrl,
    required this.apiKeySearch,
    required this.apiKeyIndex,
    this.projectId,
    this.indexName,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    bool enableLogging = false,
    Map<String, String>? defaultHeaders,
  })  : _pathPrefix = _buildPathPrefix(projectId, indexName),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            headers: defaultHeaders ?? {},
          ),
        ) {
    // Add logging interceptor if enabled
    if (enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // Add error handling interceptor
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Gets the underlying Dio instance.
  @override
  Dio get dio => _dio;

  /// Sends a GET request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint path (relative to baseUrl).
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional request options.
  ///
  /// Returns the response data.
  /// Throws [LablebException] if the request fails.
  @override
  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final resolvedEndpoint = _resolveEndpoint(endpoint);
    try {
      return await _dio.get<T>(
        resolvedEndpoint,
        queryParameters:
            _resolveQueryParameters(queryParameters, resolvedEndpoint),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _resolveEndpoint(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }

    final normalized = endpoint.trim();
    if (_pathPrefix.isEmpty) {
      return normalized;
    }

    var trimmed = normalized;
    if (trimmed.startsWith('/')) {
      trimmed = trimmed.substring(1);
    }

    if (trimmed.startsWith('v2/projects/')) {
      return '/$trimmed';
    }

    if (trimmed.isEmpty) {
      return _pathPrefix;
    }

    return '$_pathPrefix/$trimmed';
  }

  Map<String, dynamic>? _resolveQueryParameters(
    Map<String, dynamic>? queryParameters,
    String resolvedEndpoint,
  ) {
    final params = <String, dynamic>{};

    if (queryParameters != null) {
      params.addAll(queryParameters);
    }

    params['apikey'] = _selectApiKeyForEndpoint(resolvedEndpoint);
    return params;
  }

  String _selectApiKeyForEndpoint(String endpoint) {
    final path = _extractPath(endpoint);
    return _isIndexEndpoint(path) ? apiKeyIndex : apiKeySearch;
  }

  String _extractPath(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return Uri.parse(endpoint).path;
    }

    return endpoint.startsWith('/') ? endpoint : '/$endpoint';
  }

  bool _isIndexEndpoint(String path) {
    final trimmedPath = path.startsWith('/') ? path.substring(1) : path;
    final segments = trimmedPath.split('/');
    return segments.contains('documents');
  }

  /// Sends a POST request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint path (relative to baseUrl).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional request options.
  ///
  /// Returns the response data.
  /// Throws [LablebException] if the request fails.
  @override
  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final resolvedEndpoint = _resolveEndpoint(endpoint);
    try {
      return await _dio.post<T>(
        resolvedEndpoint,
        data: data,
        queryParameters:
            _resolveQueryParameters(queryParameters, resolvedEndpoint),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a PUT request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint path (relative to baseUrl).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional request options.
  ///
  /// Returns the response data.
  /// Throws [LablebException] if the request fails.
  @override
  Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final resolvedEndpoint = _resolveEndpoint(endpoint);
    try {
      return await _dio.put<T>(
        resolvedEndpoint,
        data: data,
        queryParameters:
            _resolveQueryParameters(queryParameters, resolvedEndpoint),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a PATCH request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint path (relative to baseUrl).
  /// [data] - The request body data.
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional request options.
  ///
  /// Returns the response data.
  /// Throws [LablebException] if the request fails.
  @override
  Future<Response<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final resolvedEndpoint = _resolveEndpoint(endpoint);
    try {
      return await _dio.patch<T>(
        resolvedEndpoint,
        data: data,
        queryParameters:
            _resolveQueryParameters(queryParameters, resolvedEndpoint),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sends a DELETE request to the specified endpoint.
  ///
  /// [endpoint] - The API endpoint path (relative to baseUrl).
  /// [data] - Optional request body data.
  /// [queryParameters] - Optional query parameters.
  /// [options] - Optional request options.
  ///
  /// Returns the response data.
  /// Throws [LablebException] if the request fails.
  @override
  Future<Response<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final resolvedEndpoint = _resolveEndpoint(endpoint);
    try {
      return await _dio.delete<T>(
        resolvedEndpoint,
        data: data,
        queryParameters:
            _resolveQueryParameters(queryParameters, resolvedEndpoint),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handles DioException and converts it to appropriate LablebException.
  LablebException _handleDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    Map<String, dynamic>? details;
    String message = error.message ?? 'An unknown error occurred';

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ??
          responseData['error'] ??
          responseData['error_message'] ??
          message;
      details = responseData;
    } else if (responseData is String) {
      message = responseData;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timed out: $message',
          statusCode: statusCode,
          details: details,
        );

      case DioExceptionType.badResponse:
        final code = statusCode ?? -1;
        switch (code) {
          case 400:
            return ValidationException(
              message,
              statusCode: statusCode,
              details: details,
            );
          case 401:
            return UnauthorizedException(
              message,
              statusCode: statusCode,
              details: details,
            );
          case 403:
            return ForbiddenException(
              message,
              statusCode: statusCode,
              details: details,
            );
          case 404:
            return NotFoundException(
              message,
              statusCode: statusCode,
              details: details,
            );
          case >= 500:
            return ServerException(
              message,
              statusCode: statusCode,
              details: details,
            );
          default:
            return GeneralException(
              message,
              statusCode: statusCode,
              details: details,
            );
        }

      case DioExceptionType.cancel:
        return GeneralException(
          'Request was cancelled',
          statusCode: statusCode,
          details: details,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'Network error: $message',
          statusCode: statusCode,
          details: details,
        );
    }
  }
}

/// Interceptor for handling errors globally.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Error handling is done in ApiClient._handleDioException
    super.onError(err, handler);
  }
}
