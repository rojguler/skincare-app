import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/skincare_entry.dart';
import 'entry_detail_page.dart';
import 'add_entry_page.dart';

class AllEntriesPage extends StatefulWidget {
  const AllEntriesPage({super.key});

  @override
  State<AllEntriesPage> createState() => _AllEntriesPageState();
}

class _AllEntriesPageState extends State<AllEntriesPage>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  List<SkincareEntry> _filteredEntries = [];
  List<SkincareEntry> _allEntries = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
    _loadEntries();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _loadEntries() {
    try {
      final entriesBox = Hive.box('entries');
      final rawEntries = entriesBox.values.toList();
      final entries = <SkincareEntry>[];

      for (final rawEntry in rawEntries) {
        try {
          if (rawEntry is SkincareEntry) {
            entries.add(rawEntry);
          }
        } catch (e) {}
      }

      // Tarihe göre sırala (en yeni önce)
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allEntries = entries;
        _filteredEntries = entries;
      });
    } catch (e) {}
  }

  void _filterEntries(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEntries = _allEntries;
      } else {
        _filteredEntries = _allEntries.where((entry) {
          final notes = entry.notes.toLowerCase();
          final date = DateFormat(
            'd MMMM yyyy',
            'tr_TR',
          ).format(entry.createdAt).toLowerCase();
          final searchLower = query.toLowerCase();

          return notes.contains(searchLower) || date.contains(searchLower);
        }).toList();
      }
    });
  }

  void _deleteEntry(SkincareEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        title: Text(
          'Kayıt Sil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bu kaydı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final entriesBox = Hive.box('entries');
                entriesBox.delete(entry.key);
                _loadEntries();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kayıt başarıyla silindi',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kayıt silinirken hata oluştu',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getEntrySummary(SkincareEntry entry) {
    if (entry.notes.isNotEmpty) {
      return entry.notes.length > 50
          ? '${entry.notes.substring(0, 50)}...'
          : entry.notes;
    }
    return 'Cilt bakım rutini tamamlandı';
  }

  Color _getEntryColor(SkincareEntry entry) {
    // Kayıt tarihine göre renk belirleme
    final now = DateTime.now();
    final difference = now.difference(entry.createdAt).inDays;

    if (difference == 0) {
      return AppColors.primary; // Bugün
    } else if (difference <= 7) {
      return AppColors.primary.withOpacity(0.8); // Bu hafta
    } else if (difference <= 30) {
      return AppColors.primary.withOpacity(0.6); // Bu ay
    } else {
      return AppColors.primary.withOpacity(0.4); // Eski kayıtlar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _hapticFeedback();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Tüm Kayıtlar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _hapticFeedback();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEntryPage()),
              );
            },
            icon: Icon(Icons.add, color: AppColors.primary, size: 24),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Arama çubuğu
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: _filterEntries,
                  decoration: InputDecoration(
                    hintText: 'Kayıtlarda ara...',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _filterEntries('');
                            },
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Kayıt sayısı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${_filteredEntries.length} kayıt bulundu',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_searchQuery.isNotEmpty)
                      Text(
                        '"$_searchQuery" için arama sonuçları',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Kayıtlar listesi
              Expanded(
                child: _filteredEntries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredEntries[index];
                          return _buildEntryCard(entry, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.note_add_outlined,
            color: AppColors.textSecondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Arama sonucu bulunamadı'
                : 'Henüz kayıt yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Farklı anahtar kelimeler deneyin'
                : 'İlk cilt bakım kaydını oluştur',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _hapticFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEntryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'İlk Kayıt Ekle',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(SkincareEntry entry, int index) {
    final entryColor = _getEntryColor(entry);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _hapticFeedback();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EntryDetailPage(entry: entry)),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Tarih göstergesi
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: entryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: entryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d', 'tr_TR').format(entry.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: entryColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'tr_TR').format(entry.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: entryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Kayıt detayları
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'tr_TR',
                        ).format(entry.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getEntrySummary(entry),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(entry.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Aksiyon butonları
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _hapticFeedback();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EntryDetailPage(entry: entry),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteEntry(entry),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
