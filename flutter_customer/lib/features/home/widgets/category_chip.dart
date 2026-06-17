// category_chip.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(category.color);
    return GestureDetector(
      onTap: () => context.push('/search?category_id=${category.id}'),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
                child:
                    Text(category.icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF2980B9);
    }
  }
}
