import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _Collection {
  final String title;
  final String query;
  final String image;
  const _Collection(this.title, this.query, this.image);
}

const _collections = [
  _Collection('Top Hambúrgueres', 'hamburguer',
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800'),
  _Collection('Para ir a Dois', 'romantico',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=800'),
  _Collection('Comida Japonesa', 'japones',
      'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=800'),
  _Collection('Opções Saudáveis', 'saudavel',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800'),
];

/// Grade de coleções temáticas, portada de `CollectionsSection.tsx`.
class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key, required this.onSelectQuery});

  final void Function(String query, String title) onSelectQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coleções', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Explore listas temáticas com os melhores restaurantes.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: _collections.map((c) {
              return _CollectionTile(
                collection: c,
                onTap: () => onSelectQuery(c.query, c.title),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection, required this.onTap});
  final _Collection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: collection.image,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: Colors.black12),
            errorWidget: (_, _, _) => Container(color: Colors.black26),
          ),
          Container(color: Colors.black.withValues(alpha: 0.4)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    collection.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
