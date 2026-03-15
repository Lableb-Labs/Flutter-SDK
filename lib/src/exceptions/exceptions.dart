/// Base exception class for all Lableb SDK exceptions.
/// 
/// All custom exceptions in the SDK extend this class to provide
/// consistent error handling across the application.
abstract class LablebException implements Exception {
  /// Error message describing what went wrong.
  final String message;
  
  /// Optional status code from the API response.
  final int? statusCode;
  
  /// Optional error details from the API response.
  final Map<String, dynamic>? details;

  LablebException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'LablebException: $message';
}

/// Exception thrown when a network error occurs.
/// 
/// This includes connection timeouts, network unavailability,
/// and other network-related issues.
class NetworkException extends LablebException {
  NetworkException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode, details: details);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when a request times out.
/// 
/// This occurs when the server doesn't respond within
/// the configured timeout period.
class TimeoutException extends LablebException {
  TimeoutException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode, details: details);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when an unauthorized request is made.
/// 
/// This typically occurs when:
/// - API key is missing or invalid
/// - Authentication token has expired
/// - User doesn't have permission to access the resource
class UnauthorizedException extends LablebException {
  UnauthorizedException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode ?? 401, details: details);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown when access to a resource is forbidden.
/// 
/// This occurs when the user is authenticated but doesn't
/// have permission to perform the requested action.
class ForbiddenException extends LablebException {
  ForbiddenException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode ?? 403, details: details);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception thrown when a resource is not found.
/// 
/// This occurs when the requested endpoint or resource
/// doesn't exist.
class NotFoundException extends LablebException {
  NotFoundException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode ?? 404, details: details);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when the request validation fails.
/// 
/// This occurs when the request parameters or body
/// don't meet the API requirements.
class ValidationException extends LablebException {
  ValidationException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode ?? 400, details: details);

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when a server error occurs (5xx status codes).
/// 
/// This indicates an issue on the server side, not with the client request.
class ServerException extends LablebException {
  ServerException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode ?? 500, details: details);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown for any other unexpected errors.
class GeneralException extends LablebException {
  GeneralException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode, details: details);

  @override
  String toString() => 'GeneralException: $message';
}

