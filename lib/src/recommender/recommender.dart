import '../di/locator.dart';
import '../sdk_initializer.dart';
import 'recommendations_builder.dart';

/// Fluent builders for Recommender API calls.
extension RecommenderModule on LablebSDK {
  /// Starts a fluent builder for recommendations.
  ///
  /// Example:
  /// ```dart
  /// final recs = await sdk
  ///     .recommendations()
  ///     .fromUser('user-123')
  ///     .limit(10)
  ///     .withContext({'page': 'home'})
  ///     .send();
  /// ```
  RecommendationsBuilderStart recommendations() =>
      locator<RecommendationsBuilderStart>();
}

