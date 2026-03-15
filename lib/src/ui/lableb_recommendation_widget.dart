import 'package:flutter/widgets.dart';

import '../di/locator.dart';
import '../domain/entities/recommender_entity.dart';
import '../recommender/recommendations_builder.dart';
import '../sdk_initializer.dart';

class LablebRecommendationWidget extends StatelessWidget {
  final String productId;

  const LablebRecommendationWidget({
    super.key,
    required this.productId,
  });

  Future<List<RecommenderEntity>> _load() async {
    if (!LablebSDK.isEnabled) {
      return const <RecommenderEntity>[];
    }
    try {
      return locator<RecommendationsBuilderStart>()
          .forItem(productId)
          .limit(10)
          .send();
    } catch (_) {
      return const <RecommenderEntity>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecommenderEntity>>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!;

        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final title = item.data['title']?.toString() ?? item.id;
              return Container(
                width: 160,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: items.length,
          ),
        );
      },
    );
  }
}

