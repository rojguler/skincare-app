import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/skincare_info.dart';

class InfoCard extends StatelessWidget {
  final SkincareInfo skincareInfo;
  final VoidCallback? onTap;

  const InfoCard({super.key, required this.skincareInfo, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Kullanıcı tercihi: Nude veya sarı arka plan
          color: AppColors.nude,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık - Kullanıcı tercihi: Gri ton metin
            Text(
              skincareInfo.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Gri ton
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Kısa açıklama - Kullanıcı tercihi: Gri ton metin
            Text(
              skincareInfo.shortDescription,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary, // Açık gri
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // FODIVO markası - Kullanıcı tercihi: Gri ton metin
            Text(
              skincareInfo.brand,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary, // Açık gri
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Detay sayfası için büyük bilgi kartı
class InfoDetailCard extends StatelessWidget {
  final SkincareInfo skincareInfo;

  const InfoDetailCard({super.key, required this.skincareInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Kullanıcı tercihi: Nude arka plan
        color: AppColors.nude,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            skincareInfo.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary, // Gri ton
            ),
          ),
          const SizedBox(height: 20),

          // Faydalar bölümü
          const Text(
            'Faydalar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // Gri ton
            ),
          ),
          const SizedBox(height: 12),

          // Faydalar listesi
          ...skincareInfo.benefits
              .map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.textSecondary, // Açık gri
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary, // Açık gri
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const SizedBox(height: 20),

          // Nasıl çalışır bölümü
          const Text(
            'Nasıl Çalışır',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary, // Gri ton
            ),
          ),
          const SizedBox(height: 12),

          Text(
            skincareInfo.howItWorks,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary, // Açık gri
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // FODIVO markası
          Center(
            child: Text(
              skincareInfo.brand,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, // Açık gri
              ),
            ),
          ),
        ],
      ),
    );
  }
}
