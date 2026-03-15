import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

abstract interface class AutocompleteFeedbackBuilderStart {
  AutocompleteFeedbackBuilderSuggestion forQuery(String query);
}

abstract interface class AutocompleteFeedbackBuilderSuggestion {
  AutocompleteFeedbackBuilderValue forSuggestion(String suggestion);
}

abstract interface class AutocompleteFeedbackBuilderValue {
  AutocompleteFeedbackBuilderReady value(String feedbackValue);
}

abstract interface class AutocompleteFeedbackBuilderReady {
  AutocompleteFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  });

  AutocompleteFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata);

  Future<void> send();
}

class AutocompleteFeedbackBuilder
    implements
        AutocompleteFeedbackBuilderStart,
        AutocompleteFeedbackBuilderSuggestion,
        AutocompleteFeedbackBuilderValue,
        AutocompleteFeedbackBuilderReady {
  String? _query;
  String? _suggestion;
  String? _feedbackValue;
  String? _userId;
  final Map<String, dynamic> _metadata = <String, dynamic>{};

  @override
  AutocompleteFeedbackBuilderSuggestion forQuery(String query) {
    assert(query.trim().isNotEmpty, 'query is required');
    _query = query;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderValue forSuggestion(String suggestion) {
    assert(suggestion.trim().isNotEmpty, 'suggestion is required');
    _suggestion = suggestion;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady value(String feedbackValue) {
    assert(feedbackValue.trim().isNotEmpty, 'feedbackValue is required');
    _feedbackValue = feedbackValue;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  }) {
    _userId = id;
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      _metadata['session_id'] = sessionId;
    }
    if (ip != null && ip.trim().isNotEmpty) {
      _metadata['user_ip'] = ip;
    }
    if (country != null && country.trim().isNotEmpty) {
      _metadata['user_country'] = country;
    }
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }

  @override
  Future<void> send() async {
    final query = _query;
    final suggestion = _suggestion;
    final feedbackValue = _feedbackValue;

    assert(query != null && query.trim().isNotEmpty, 'query is required');
    assert(
      suggestion != null && suggestion.trim().isNotEmpty,
      'suggestion is required',
    );
    assert(
      feedbackValue != null && feedbackValue.trim().isNotEmpty,
      'feedbackValue is required',
    );

    final repo = GetIt.instance<FeedbackRepository>();
    // ignore: deprecated_member_use_from_same_package
    await repo.submitAutocompleteFeedback(
      query: query!,
      suggestion: suggestion!,
      feedbackValue: feedbackValue!,
      userId: _userId,
      metadata: _metadata.isEmpty ? null : Map<String, dynamic>.from(_metadata),
    );
  }
}

