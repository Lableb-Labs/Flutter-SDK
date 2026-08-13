import '../models/autocomplete_model.dart';

/// Response model for autocomplete operations.
/// 
/// This model represents the response from the autocomplete API.
class AutocompleteResponse {
  /// List of autocomplete suggestions.
  final List<AutocompleteModel> suggestions;
  
  /// Query execution time in milliseconds.
  final int? executionTime;

  AutocompleteResponse({
    required this.suggestions,
    this.executionTime,
  });

  /// Creates an [AutocompleteResponse] from a JSON map.
  ///
  /// Unwraps Lableb's `{"time", "code", "response": {...}}` envelope, and
  /// falls back to `results` (the real field name) when `suggestions` isn't
  /// present.
  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    final body = json['response'] is Map<String, dynamic>
        ? json['response'] as Map<String, dynamic>
        : json;

    return AutocompleteResponse(
      suggestions: (body['suggestions'] as List? ??
              body['results'] as List? ??
              [])
          .map((item) => AutocompleteModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      executionTime: json['time'] as int? ?? body['execution_time'] as int?,
    );
  }

  /// Converts the [AutocompleteResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'suggestions': suggestions.map((suggestion) => suggestion.toJson()).toList(),
      if (executionTime != null) 'execution_time': executionTime,
    };
  }
}

