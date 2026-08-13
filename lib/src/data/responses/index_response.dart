import '../models/index_model.dart';

/// Response model for index operations.
/// 
/// This model represents the response from the index API.
class IndexResponse {
  /// Whether the operation was successful.
  final bool success;
  
  /// Response message.
  final String message;
  
  /// List of indexed items.
  final List<IndexModel>? items;
  
  /// Number of items successfully indexed.
  final int? indexedCount;
  
  /// Number of items that failed to index.
  final int? failedCount;
  
  /// List of errors, if any.
  final List<String>? errors;

  IndexResponse({
    required this.success,
    required this.message,
    this.items,
    this.indexedCount,
    this.failedCount,
    this.errors,
  });

  /// Creates an [IndexResponse] from a JSON map.
  factory IndexResponse.fromJson(Map<String, dynamic> json) {
    return IndexResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => IndexModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      indexedCount: json['indexed_count'] as int?,
      failedCount: json['failed_count'] as int?,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : null,
    );
  }

  /// Converts the [IndexResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (indexedCount != null) 'indexed_count': indexedCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (errors != null) 'errors': errors,
    };
  }
}

