import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

abstract interface class RecommenderFeedbackBuilderStart {
  RecommenderFeedbackBuilderValue forRecommendation(String id);
}

abstract interface class RecommenderFeedbackBuilderValue {
  RecommenderFeedbackBuilderReady value(String feedbackValue);
}

abstract interface class RecommenderFeedbackBuilderReady {
  RecommenderFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  });

  RecommenderFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata);

  Future<void> send();
}

class RecommenderFeedbackBuilder
    implements
        RecommenderFeedbackBuilderStart,
        RecommenderFeedbackBuilderValue,
        RecommenderFeedbackBuilderReady {
  String? _recommendationId;
  String? _feedbackValue;
  String? _userId;
  final Map<String, dynamic> _metadata = <String, dynamic>{};

  @override
  RecommenderFeedbackBuilderValue forRecommendation(String id) {
    assert(id.trim().isNotEmpty, 'recommendationId is required');
    _recommendationId = id;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady value(String feedbackValue) {
    assert(feedbackValue.trim().isNotEmpty, 'feedbackValue is required');
    _feedbackValue = feedbackValue;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady fromUser({
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
  RecommenderFeedbackBuilderReady withMetadata(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }

  @override
  Future<void> send() async {
    final recommendationId = _recommendationId;
    final feedbackValue = _feedbackValue;

    assert(
      recommendationId != null && recommendationId.trim().isNotEmpty,
      'recommendationId is required',
    );
    assert(
      feedbackValue != null && feedbackValue.trim().isNotEmpty,
      'feedbackValue is required',
    );

    final repo = GetIt.instance<FeedbackRepository>();
    // ignore: deprecated_member_use_from_same_package
    await repo.submitRecommenderFeedback(
      recommendationId: recommendationId!,
      feedbackValue: feedbackValue!,
      userId: _userId,
      metadata: _metadata.isEmpty ? null : Map<String, dynamic>.from(_metadata),
    );
  }
}

