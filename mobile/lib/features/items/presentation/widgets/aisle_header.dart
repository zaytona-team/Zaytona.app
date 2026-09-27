import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// Aisle section header: category star, label, accent rule, count. Shared
/// by [ListDetailPage] and [BuyingViewPage].
class AisleHeader extends StatelessWidget {
  final CategoryId category;
  final int count;
  final String locale;

  const AisleHeader({
    super.key,
    required this.category,
    required this.count,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: ZaytonaSpacing.space2, bottom: ZaytonaSpacing.space3),
      child: Row(
        children: [
          Image.asset(category.assetPath, width: 26, height: 26),
          const SizedBox(width: ZaytonaSpacing.space3),
          Text(category.label(locale), style: ZaytonaType.cardTitle),
          const SizedBox(width: ZaytonaSpacing.space3),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(ZaytonaRadius.pill),
              ),
            ),
          ),
          const SizedBox(width: ZaytonaSpacing.space3),
          Text('$count', style: ZaytonaType.meta),
        ],
      ),
    );
  }
}
