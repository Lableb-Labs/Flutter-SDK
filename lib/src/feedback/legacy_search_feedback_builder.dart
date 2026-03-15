import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

abstract interface class LegacySearchFeedbackBuilderStart {
  LegacySearchFeedbackBuilderResult forQuery(String query);
}

abstract interface class LegacySearchFeedbackBuilderResult {
  LegacySearchFeedbackBuilderValue forResult(String id);
}

abstract interface class LegacySearchFeedbackBuilderValue {
  LegacySearchFeedbackBuilderReady value(String feedbackValue);
}

abstract interface class LegacySearchFeedbackBuilderReady {
  LegacySearchFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  });

  LegacySearchFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata);

  Future<void> send();
}

class LegacySearchFeedbackBuilder
    implements
        LegacySearchFeedbackBuilderStart,
        LegacySearchFeedbackBuilderResult,
        LegacySearchFeedbackBuilderValue,
        LegacySearchFeedbackBuilderReady {
  String? _query;
  String? _resultId;
  String? _feedbackValue;
  final Map<String, dynamic> _metadata = <String, dynamic>{};

  @override
  LegacySearchFeedbackBuilderResult forQuery(String query) {
    assert(query.trim().isNotEmpty, 'query is required');
    _query = query;
    return this;
  }

  @override
  LegacySearchFeedbackBuilderValue forResult(String id) {
    assert(id.trim().isNotEmpty, 'resultId is required');
    _resultId = id;
    return this;
  }

  @override
  LegacySearchFeedbackBuilderReady value(String feedbackValue) {
    assert(feedbackValue.trim().isNotEmpty, 'feedbackValue is required');
    _feedbackValue = feedbackValue;
    return this;
  }

  @override
  LegacySearchFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  }) {
    if (id != null && id.trim().isNotEmpty) {
      _metadata['user_id'] = id;
    }
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
  LegacySearchFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }

  @override
  Future<void> send() async {
    final query = _query;
    final resultId = _resultId;
    final feedbackValue = _feedbackValue;

    assert(query != null && query.trim().isNotEmpty, 'query is required');
    assert(resultId != null && resultId.trim().isNotEmpty, 'resultId is required');
    assert(
      feedbackValue != null && feedbackValue.trim().isNotEmpty,
      'feedbackValue is required',
    );

    final repo = GetIt.instance<FeedbackRepository>();
    // ignore: deprecated_member_use_from_same_package
    await repo.submitSearchFeedback(
      query: query!,
      resultId: resultId!,
      feedbackValue: feedbackValue!,
      metadata: _metadata.isEmpty ? null : Map<String, dynamic>.from(_metadata),
    );
  }
}

