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
  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return AutocompleteResponse(
      suggestions: (json['suggestions'] as List? ?? 
                     json['results'] as List? ?? [])
          .map((item) => AutocompleteModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      executionTime: json['execution_time'] as int?,
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

