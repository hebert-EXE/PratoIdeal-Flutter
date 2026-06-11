import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/place_models.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import 'favorite_button.dart';
import 'ui/ui.dart';

/// Card de restaurante reutilizável (carrosséis e grids), portado do
/// `RestaurantCard.tsx` do web: foto, selo de nota, nome, categoria,
/// cidade/distância e horário.
class RestaurantCardWidget extends StatelessWidget {
  const RestaurantCardWidget({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.width,
  });

  final RestaurantCard restaurant;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      elevated: true,
      radius: AppTheme.radiusLg,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: restaurant.image,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.restaurant,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: RatingBadge(rating: restaurant.rating),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FavoriteButton(
                  placeId: restaurant.id,
                  name: restaurant.name,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                if (restaurant.category != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          size: 14, color: AppColors.info),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          restaurant.category!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${restaurant.city} • ${restaurant.distance}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        restaurant.openingHours.isNotEmpty
                            ? 'Horários nos detalhes'
                            : 'Aberto até ${restaurant.openUntil}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}
