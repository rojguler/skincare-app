import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/custom_button.dart';
import '../../core/theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? error;
  final String? title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    this.error,
    this.title,
    this.subtitle,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Hata',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? error ?? 'Bilinmeyen hata',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Tekrar Dene',
                onPressed: onRetry ?? () {},
                icon: Icons.refresh_rounded,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
