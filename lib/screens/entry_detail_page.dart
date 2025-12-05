import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/skincare_entry.dart';

class EntryDetailPage extends StatelessWidget {
  final SkincareEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = entry.date;
    final note = entry.notes;
    final productsList = entry.products;
    final imagePaths = entry.imagePaths;

    return Scaffold(
      backgroundColor: AppColors.white, // Changed from nude to white
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0, // Removed elevation
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.pink, size: 24),
            const SizedBox(width: 8),
            Text(
              'Kayıt Detayı',
              style: GoogleFonts.poppins(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.pink),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.pink.withOpacity(0.1),
                    AppColors.yellow.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.pink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.pink,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cilt Bakım Kaydı',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMMM yyyy').format(date),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (imagePaths.isNotEmpty && File(imagePaths.first).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.pink.withOpacity(0.2),
                    ), // Changed from yellow
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withOpacity(
                          0.1,
                        ), // Changed from darkGray
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.file(
                    File(imagePaths.first),
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (imagePaths.isNotEmpty && File(imagePaths.first).existsSync())
              const SizedBox(height: 28),

            _buildLabel(
              'Tarih',
              icon: Icons.calendar_today_rounded,
              color: AppColors.pink,
            ), // Changed from yellow
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            if (productsList.isNotEmpty) ...[
              _buildLabel(
                'Kullanılan Ürünler',
                icon: Icons.category_rounded,
                color: AppColors.pink,
              ), // Changed from yellow
              ...productsList
                  .map(
                    (prod) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pink.withOpacity(
                          0.1,
                        ), // Changed from yellow
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.pink.withOpacity(0.2),
                        ), // Changed from yellow
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.pink,
                            size: 20,
                          ), // Changed from yellow
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prod,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 24),
            ],

            if (note.isNotEmpty) ...[
              _buildLabel(
                'Notlar',
                icon: Icons.note_rounded,
                color: AppColors.pink,
              ), // Changed from yellow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.pink.withOpacity(0.2),
                  ), // Changed from yellow
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withOpacity(
                        0.05,
                      ), // Changed from darkGray
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  note,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF333333),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    String label, {
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
