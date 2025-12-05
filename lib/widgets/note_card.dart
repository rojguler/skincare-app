import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

// Pastel premium vibe renkler - Görseldeki Renk Paleti
const Color kBackground = Color(0xFFFFFAEB); // Nude pastel arka plan
const Color kAccentYellow = Color(0xFFFEEDAA); // Soft Pastel Yellow
const Color kAccentPink = Color(0xFFFCE4EC); // Sweet Light Pink
const Color kMarron = Color(0xFF8A8651); // Marron premium
const Color kTextDark = Color(0xFF222222); // Koyu gri

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const NoteCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final String date = entry['date'] ?? 'Tarih yok';
    final String note = entry['note'] ?? '';
    final String? photoPath = entry['photoPath'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.nude,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kAccentYellow.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih & Mood (üst kısım)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kMarron,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Not varsa göster
          if (note.isNotEmpty)
            Text(
              note,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: kTextDark.withOpacity(0.85),
              ),
            ),

          // Not ve fotoğraf arasında yumuşak geçiş
          if (note.isNotEmpty && photoPath != null && photoPath.isNotEmpty)
            const SizedBox(height: 16),

          // Fotoğraf varsa göster
          if (photoPath != null && photoPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(photoPath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
