// provider_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/home_provider.dart';

class ProviderCard extends StatelessWidget {
  final Provider provider;
  final VoidCallback onTap;
  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          // الشعار
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EAF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: provider.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: provider.logoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.store, color: Color(0xFF2980B9), size: 32),
          ),

          const SizedBox(width: 12),

          // المعلومات
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                    child: Text(provider.businessName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (provider.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                  if (provider.isFeatured) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'مميز',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(provider.categoryName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(provider.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  if (provider.distanceMeters != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, color: Colors.grey, size: 13),
                    Text(provider.distanceText,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ]),
              ])),

          // أزرار سريعة
          if (provider.phone != null)
            IconButton(
              icon: const Icon(Icons.phone_in_talk, color: Colors.green),
              onPressed: () {}, // url_launcher would go here
            ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ]),
      ),
    );
  }
}

// featured_banner.dart
class FeaturedBanner extends StatelessWidget {
  final Provider provider;
  const FeaturedBanner({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C5E), Color(0xFF2980B9)],
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1A3C5E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // الشعار
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: provider.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: provider.logoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.store, color: Colors.white, size: 28),
          ),

          const SizedBox(height: 10),
          Text(provider.businessName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),

          const SizedBox(height: 4),
          Text(provider.categoryName,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),

          const Spacer(),
          Row(children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(provider.ratingAvg.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ]),
        ]),
      ),
    );
  }
}
