import 'package:flutter/material.dart';

import '../models/place_models.dart';
import 'restaurant_card_widget.dart';

/// Carrossel horizontal de restaurantes com título e subtítulo,
/// portado do `RestaurantCarousel.tsx` do web.
class RestaurantCarousel extends StatelessWidget {
  const RestaurantCarousel({
    super.key,
    required this.title,
    required this.restaurants,
    required this.onTapRestaurant,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<RestaurantCard> restaurants;
  final void Function(RestaurantCard) onTapRestaurant;

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Text(title, style: theme.textTheme.headlineSmall),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        SizedBox(
          height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: restaurants.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final r = restaurants[index];
              return RestaurantCardWidget(
                restaurant: r,
                width: 250,
                onTap: () => onTapRestaurant(r),
              );
            },
          ),
        ),
      ],
    );
  }
}
