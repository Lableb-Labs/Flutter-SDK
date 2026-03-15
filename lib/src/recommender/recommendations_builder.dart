import 'package:get_it/get_it.dart';

import '../domain/entities/recommender_entity.dart';
import '../domain/repositories/recommender_repository.dart';

/// Entry step for building a recommendations request.
abstract interface class RecommendationsBuilderStart {
  /// Request recommendations for a specific user.
  RecommendationsBuilderOptions fromUser(String id);

  /// Request recommendations based on a specific item.
  RecommendationsBuilderOptions forItem(String id);

  /// Request recommendations using both user and item signals.
  RecommendationsBuilderOptions fromUserForItem({
    required String userId,
    required String itemId,
  });
}

/// Options step for enriching and executing recommendations.
abstract interface class RecommendationsBuilderOptions {
  RecommendationsBuilderOptions limit(int value);

  RecommendationsBuilderOptions withFilters(Map<String, dynamic> filters);

  RecommendationsBuilderOptions withContext(Map<String, dynamic> context);

  Future<List<RecommenderEntity>> send();
}

class RecommendationsBuilder
    implements RecommendationsBuilderStart, RecommendationsBuilderOptions {
  String? _userId;
  String? _itemId;
  int _limit = 10;
  Map<String, dynamic>? _filters;
  Map<String, dynamic>? _context;

  @override
  RecommendationsBuilderOptions fromUser(String id) {
    assert(id.trim().isNotEmpty, 'user id is required');
    _userId = id;
    return this;
  }

  @override
  RecommendationsBuilderOptions forItem(String id) {
    assert(id.trim().isNotEmpty, 'item id is required');
    _itemId = id;
    return this;
  }

  @override
  RecommendationsBuilderOptions fromUserForItem({
    required String userId,
    required String itemId,
  }) {
    assert(userId.trim().isNotEmpty, 'userId is required');
    assert(itemId.trim().isNotEmpty, 'itemId is required');
    _userId = userId;
    _itemId = itemId;
    return this;
  }

  @override
  RecommendationsBuilderOptions limit(int value) {
    assert(value >= 1, 'limit must be >= 1');
    _limit = value;
    return this;
  }

  @override
  RecommendationsBuilderOptions withFilters(Map<String, dynamic> filters) {
    _filters = Map<String, dynamic>.from(filters);
    return this;
  }

  @override
  RecommendationsBuilderOptions withContext(Map<String, dynamic> context) {
    _context = Map<String, dynamic>.from(context);
    return this;
  }

  @override
  Future<List<RecommenderEntity>> send() async {
    assert(
      (_userId != null && _userId!.trim().isNotEmpty) ||
          (_itemId != null && _itemId!.trim().isNotEmpty),
      'Either userId or itemId must be provided',
    );

    final repo = GetIt.instance<RecommenderRepository>();
    // ignore: deprecated_member_use_from_same_package
    return repo.getRecommendations(
      userId: _userId,
      itemId: _itemId,
      limit: _limit,
      filters: _filters,
      context: _context,
    );
  }
}

