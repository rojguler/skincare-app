import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'add_entry_page.dart';
import 'all_entries_page.dart';
import 'statistics_page.dart' as stats;
import 'profile_page_modern.dart';
import 'habits_page.dart';
import 'product_search_page.dart';
import 'skincare_info_page.dart';
import 'skin_quiz_page.dart';
import '../core/theme.dart';
import '../models/skincare_entry.dart';
import '../services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  // Alışkanlık verileri - habits page'den gelecek
  List<Map<String, dynamic>> _dailyHabits = [];

  // Today's skin note
  String _todaySkinNote = '';
  bool _hasTodayEntry = false;

  // Reminders - görseldeki hatırlatmalar (küçültülmüş)
  List<Map<String, dynamic>> _reminders = [
    {'title': 'Güneş kremi sür', 'time': '09:00', 'completed': true},
    {'title': 'Gece serumu', 'time': '22:00', 'completed': true},
    {'title': 'Su iç', 'time': 'Her saat', 'completed': false},
  ];

  // Daily skincare routines - görseldeki rutinler
  List<Map<String, dynamic>> _dailyRoutines = [
    {
      'title': 'Sabah Rutini',
      'description': 'Temizlik → Tonik → Serum → Nemlendirici → SPF',
      'icon': Icons.wb_sunny_outlined,
      'category': 'AM',
      'steps': ['Temizlik', 'Tonik', 'Serum', 'Nemlendirici', 'SPF'],
    },
    {
      'title': 'Akşam Rutini',
      'description': 'Temizlik → Tonik → Serum → Maske → Gece Kremi',
      'icon': Icons.nightlight_outlined,
      'category': 'PM',
      'steps': ['Temizlik', 'Tonik', 'Serum', 'Maske', 'Gece Kremi'],
    },
  ];

  // Son kayıtlar
  List<SkincareEntry> _recentEntries = [];

  final TextEditingController _newHabitController = TextEditingController();
  final TextEditingController _newReminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadHabits();
    _loadTodaySkinNote();
    _loadReminders();
    _loadRecentEntries();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    _newHabitController.dispose();
    _newReminderController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _loadHabits() {
    try {
      final habitsBox = Hive.box('habits');
      final savedHabits = habitsBox.get('dailyHabits', defaultValue: []);
      final lastHabitsDate = habitsBox.get('lastHabitsDate');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Her gün sıfırlanma kontrolü - yeni bir günse tüm alışkanlıkları sıfırla
      bool shouldResetDaily = lastHabitsDate == null || lastHabitsDate != today;

      if (savedHabits.isNotEmpty) {
        // Habits page'den gelen veriyi kullan
        final List<Map<String, dynamic>> dailyHabits = [];
        for (var habit in savedHabits) {
          if (habit is Map) {
            dailyHabits.add({
              'title': habit['text'] ?? 'Alışkanlık',
              // Yeni günse otomatik olarak false, değilse kaydedilen değeri kullan
              'completed': shouldResetDaily ? false : (habit['completed'] ?? false),
              'description': habit['description'] ?? '',
              'icon': habit['icon'] ?? Icons.check_circle_outlined.codePoint,
              'time': habit['time'] ?? '',
            });
          }
        }
        setState(() {
          _dailyHabits = dailyHabits;
        });

        // Eğer yeni günse, tarihi güncelle ve sıfırlanmış durumu kaydet
        if (shouldResetDaily) {
          habitsBox.put('lastHabitsDate', today);
          _saveDailyHabitsToHabitsPage();
        }
      } else {
        // Default habits if none exist
        final defaultHabits = [
          {
            'title': 'Yüz Yıkama',
            'completed': false,
            'description': 'Sabah ve akşam yüzünü temizle',
            'icon': Icons.cleaning_services_outlined.codePoint,
            'time': 'Sabah & Akşam',
          },
          {
            'title': 'Bol Su İç',
            'completed': false,
            'description': 'Günde en az 8 bardak su iç',
            'icon': Icons.water_drop_outlined.codePoint,
            'time': 'Gün boyu',
          },
          {
            'title': 'Güneş Kremi',
            'completed': false,
            'description': 'Güneşe çıkmadan önce mutlaka sür',
            'icon': Icons.wb_sunny_outlined.codePoint,
            'time': 'Sabah',
          },
          {
            'title': 'Gece Bakımı',
            'completed': false,
            'description': 'Yatmadan önce serum ve nemlendirici',
            'icon': Icons.nightlight_outlined.codePoint,
            'time': 'Akşam',
          },
        ];
        setState(() {
          _dailyHabits = defaultHabits;
        });
        // Tarihi kaydet ve habits page'e de kaydet
        habitsBox.put('lastHabitsDate', today);
        _saveDailyHabitsToHabitsPage();
      }
    } catch (e) {
      // Fallback to default habits
      final defaultHabits = [
        {
          'title': 'Yüz Yıkama',
          'completed': false,
          'description': 'Sabah ve akşam yüzünü temizle',
          'icon': Icons.cleaning_services_outlined.codePoint,
          'time': 'Sabah & Akşam',
        },
        {
          'title': 'Bol Su İç',
          'completed': false,
          'description': 'Günde en az 8 bardak su iç',
          'icon': Icons.water_drop_outlined.codePoint,
          'time': 'Gün boyu',
        },
        {
          'title': 'Güneş Kremi',
          'completed': false,
          'description': 'Güneşe çıkmadan önce mutlaka sür',
          'icon': Icons.wb_sunny_outlined.codePoint,
          'time': 'Sabah',
        },
        {
          'title': 'Gece Bakımı',
          'completed': false,
          'description': 'Yatmadan önce serum ve nemlendirici',
          'icon': Icons.nightlight_outlined.codePoint,
          'time': 'Akşam',
        },
      ];
      setState(() {
        _dailyHabits = defaultHabits;
      });
    }
  }

  void _loadRecentEntries() {
    try {
      final entriesBox = Hive.box('entries');
      final allEntries = entriesBox.values.toList();

      // Son 3 kaydı al
      List<SkincareEntry> recentEntries = [];
      for (final entry in allEntries) {
        if (entry is SkincareEntry) {
          recentEntries.add(entry);
        }
      }

      // Tarihe göre sırala ve son 3'ü al
      recentEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _recentEntries = recentEntries.take(3).toList();
      });
    } catch (e) {}
  }

  void _loadReminders() {
    try {
      final remindersBox = Hive.box('reminders');
      final savedReminders = remindersBox.get(
        'daily_reminders',
        defaultValue: [],
      );
      if (savedReminders.isNotEmpty) {
        setState(() {
          _reminders = List<Map<String, dynamic>>.from(savedReminders);
        });
      }
    } catch (e) {}
  }

  void _loadTodaySkinNote() {
    try {
      final entriesBox = Hive.box('entries');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (final entry in entriesBox.values) {
        if (entry is SkincareEntry) {
          final entryDate = DateFormat('yyyy-MM-dd').format(entry.createdAt);
          if (entryDate == today) {
            setState(() {
              _hasTodayEntry = true;
              _todaySkinNote = entry.notes.isNotEmpty
                  ? entry.notes
                  : 'Bugün cildin harika görünüyor! ✨';
            });
            return;
          }
        }
      }

      setState(() {
        _hasTodayEntry = false;
        _todaySkinNote = '';
      });
    } catch (e) {}
  }

  Future<void> _onRefresh() async {
    _refreshController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _loadHabits();
    _loadTodaySkinNote();
    _loadReminders();
    _loadRecentEntries();
    _refreshController.reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfa her açıldığında habits'leri yeniden yükle
    _loadHabits();
  }

  double _calculateProgress() {
    if (_dailyHabits.isEmpty) return 0.0;

    int completedCount = 0;
    int totalCount = _dailyHabits.length;

    for (final habit in _dailyHabits) {
      if (habit['completed'] == true) {
        completedCount++;
      }
    }

    return totalCount > 0 ? completedCount / totalCount : 0.0;
  }

  void _toggleHabit(int index) {
    setState(() {
      _dailyHabits[index]['completed'] = !_dailyHabits[index]['completed'];
    });
    _saveHabits();
    _hapticFeedback();

    // Habits page'e de güncelleme gönder
    _updateHabitsPage();
  }

  void _updateHabitsPage() {
    try {
      final habitsBox = Hive.box('habits');
      final List<Map<String, dynamic>> habitsPageFormat = [];

      for (int i = 0; i < _dailyHabits.length; i++) {
        final habit = _dailyHabits[i];
        final Map<String, dynamic> habitData = {
          'text': habit['title'],
          'completed': habit['completed'],
          'description': _getDefaultDescription(habit['title']),
          'icon': _getDefaultIcon(habit['title']),
          'time': _getDefaultTime(habit['title']),
        };
        habitsPageFormat.add(habitData);
      }

      habitsBox.put('dailyHabits', habitsPageFormat);
    } catch (e) {}
  }

  void _toggleReminder(int index) {
    setState(() {
      _reminders[index]['completed'] = !_reminders[index]['completed']!;
    });
    _saveReminders();
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
    _saveReminders();
  }

  void _addReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Hatırlatma', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newReminderController,
              decoration: InputDecoration(
                labelText: 'Hatırlatma',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newReminderController.text.isNotEmpty) {
                setState(() {
                  _reminders.add({
                    'title': _newReminderController.text,
                    'time': '09:00',
                    'completed': false,
                  });
                });
                _newReminderController.clear();
                _saveReminders();
                Navigator.pop(context);
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _saveHabits() {
    try {
      final habitsBox = Hive.box('habits');
      // Ana sayfa için eski format
      habitsBox.put('daily_habits', _dailyHabits);

      // Habits page format'ına dönüştür ve kaydet
      _saveDailyHabitsToHabitsPage();

      // Firebase'e senkronize et
      FirebaseService.syncDataToCloud();
    } catch (e) {}
  }

  void _saveDailyHabitsToHabitsPage() {
    try {
      final habitsBox = Hive.box('habits');
      final List<Map<String, dynamic>> habitsPageFormat = [];

      for (int i = 0; i < _dailyHabits.length; i++) {
        final habit = _dailyHabits[i];
        final Map<String, dynamic> habitData = {
          'text': habit['title'],
          'completed': habit['completed'],
          'description': _getDefaultDescription(habit['title']),
          'icon': _getDefaultIcon(habit['title']),
          'time': _getDefaultTime(habit['title']),
        };
        habitsPageFormat.add(habitData);
      }

      habitsBox.put('dailyHabits', habitsPageFormat);
    } catch (e) {}
  }

  String _getDefaultDescription(String title) {
    switch (title) {
      case 'Yüz Yıkama':
        return 'Sabah ve akşam yüzünü temizle';
      case 'Bol Su İç':
        return 'Günde en az 8 bardak su iç';
      case 'Güneş Kremi':
        return 'Güneşe çıkmadan önce mutlaka sür';
      case 'Gece Bakımı':
        return 'Yatmadan önce serum ve nemlendirici';
      default:
        return 'Günlük cilt bakım alışkanlığı';
    }
  }

  int _getDefaultIcon(String title) {
    switch (title) {
      case 'Yüz Yıkama':
        return Icons.cleaning_services_outlined.codePoint;
      case 'Bol Su İç':
        return Icons.water_drop_outlined.codePoint;
      case 'Güneş Kremi':
        return Icons.wb_sunny_outlined.codePoint;
      case 'Gece Bakımı':
        return Icons.nightlight_outlined.codePoint;
      default:
        return Icons.task_alt_outlined.codePoint;
    }
  }

  String _getDefaultTime(String title) {
    switch (title) {
      case 'Yüz Yıkama':
        return 'Sabah & Akşam';
      case 'Bol Su İç':
        return 'Gün boyu';
      case 'Güneş Kremi':
        return 'Sabah';
      case 'Gece Bakımı':
        return 'Akşam';
      default:
        return 'Her gün';
    }
  }

  void _saveReminders() {
    try {
      final remindersBox = Hive.box('reminders');
      remindersBox.put('daily_reminders', _reminders);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final completedCount = _dailyHabits
        .where((h) => h['completed'] == true)
        .length;
    final totalCount = _dailyHabits.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- MODERN HEADER SECTION ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Modern Profile Avatar
                          GestureDetector(
                            onTap: () {
                              _hapticFeedback();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfilePageModern(),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.pink, AppColors.lightPink],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hoş geldin! 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'd MMMM yyyy',
                                    'tr_TR',
                                  ).format(DateTime.now()),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quick Action Buttons
                          Row(
                            children: [
                              _buildQuickActionButton(
                                icon: Icons.notifications_outlined,
                                color: AppColors.yellow,
                                onTap: () {
                                  _hapticFeedback();
                                  // Navigate to notifications
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildQuickActionButton(
                                icon: Icons.bar_chart,
                                color: AppColors.pink,
                                onTap: () {
                                  _hapticFeedback();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => stats.UserStatsPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildQuickActionButton(
                                icon: Icons.health_and_safety,
                                color: AppColors.marron,
                                onTap: () {
                                  _hapticFeedback();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HabitsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- SEARCH BAR SECTION ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.pink.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductSearchPage(initialQuery: value),
                                    ),
                                  );
                                }
                              },
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cilt bakım ürünü ara...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.tune,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- HIZLI İŞLEMLER SECTION ---
                    const SizedBox(height: 16),

                    // Hızlı İşlemler Grid - 2x2 düzen
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.add,
                            title: 'Yeni Kayıt',
                            subtitle: 'Cilt bakım günlüğü',
                            color: AppColors.pink,
                            onTap: () {
                              _hapticFeedback();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEntryPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.search,
                            title: 'Ürün Ara',
                            subtitle: 'Veritabanında ara',
                            color: AppColors.marron,
                            onTap: () {
                              _hapticFeedback();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductSearchPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.list_alt,
                            title: 'Tüm Kayıtlar',
                            subtitle: 'Geçmiş kayıtlar',
                            color: AppColors.marron,
                            onTap: () {
                              _hapticFeedback();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllEntriesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.bar_chart,
                            title: 'İstatistikler',
                            subtitle: 'Detaylı analiz',
                            color: AppColors.pink,
                            onTap: () {
                              _hapticFeedback();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => stats.UserStatsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- SKINCARE BİLGİLERİ SECTION ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            AppColors.nude, // Kullanıcı tercihi: Nude arka plan
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
                      child: GestureDetector(
                        onTap: () {
                          _hapticFeedback();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SkincareInfoPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.yellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: AppColors.textPrimary, // Gri ton
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Skincare Bilgileri',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary, // Gri ton
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cilt bakım bileşenleri hakkında detaylı bilgi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          AppColors.textSecondary, // Açık gri
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary, // Açık gri
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- CILT TIPI QUIZ SECTION - MODERN TASARIM ---
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.pink.withOpacity(0.25),
                            AppColors.pink.withOpacity(0.35),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.pink.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _hapticFeedback();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SkinQuizPage(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            // Background decoration
                            Positioned(
                              top: -10,
                              right: -10,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.pink.withOpacity(0.1),
                                      AppColors.pink.withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // Main content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Modern icon container
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.pink,
                                          AppColors.pink.withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.pink.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Cilt Tipi Testi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '12 soru ile cilt tipinizi keşfedin',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.pink.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '%95 Doğruluk',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.pink,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow icon
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.pink.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.pink,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- RUTIN REHBERI SECTION ---
                    Text(
                      'Rutin Rehberi',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rutin Kartları - Farklı tasarım
                    SizedBox(
                      height:
                          140, // Increased height to accommodate larger cards
                      child: Row(
                        children: [
                          // Sabah Rutini Kartı
                          Expanded(
                            child: _buildRoutineCard(
                              icon: Icons.wb_sunny_outlined,
                              title: 'Sabah Rutini',
                              subtitle: '5 adım',
                              description:
                                  'Temizlik → Tonik → Serum → Nemlendirici → SPF',
                              color: AppColors.yellow,
                              onTap: () {
                                _hapticFeedback();
                                // Navigate to sabah rutini detail
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Akşam Rutini Kartı
                          Expanded(
                            child: _buildRoutineCard(
                              icon: Icons.nightlight_outlined,
                              title: 'Akşam Rutini',
                              subtitle: '5 adım',
                              description:
                                  'Temizlik → Tonik → Serum → Maske → Gece Kremi',
                              color: AppColors.pink,
                              onTap: () {
                                _hapticFeedback();
                                // Navigate to akşam rutini detail
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- GLOWING SKIN LOADING SECTION ---
                    Container(
                      width: double.infinity,
                      height: 120, // Increased height to prevent overflow
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.pink.withValues(alpha: 0.1),
                            AppColors.yellow.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.pink.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Pattern
                          Positioned(
                            top: -10, // Reduced from -20 to prevent overflow
                            right: -10, // Reduced from -20 to prevent overflow
                            child: Container(
                              width: 60, // Reduced from 80 to prevent overflow
                              height: 60, // Reduced from 80 to prevent overflow
                              decoration: BoxDecoration(
                                color: AppColors.pink.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -5, // Reduced from -15 to prevent overflow
                            left: -5, // Reduced from -15 to prevent overflow
                            child: Container(
                              width: 40, // Reduced from 60 to prevent overflow
                              height: 40, // Reduced from 60 to prevent overflow
                              decoration: BoxDecoration(
                                color: AppColors.yellow.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.pink.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.pink.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.pink,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'GLOWING SKIN LOADING',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Cilt bakım rutinin devam ediyor...',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Bar
                                Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.pink.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: (progress * 100).toInt(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.pink,
                                                AppColors.yellow,
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 100 - (progress * 100).toInt(),
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Progress Text
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'LUMI GLO',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toInt()}% Tamamlandı',
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- GÜNLÜK ALIŞKANLIKLAR SECTION ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.pink.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Günlük Alışkanlıklar',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HabitsPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Tümünü Gör',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.pink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...(_dailyHabits.map((habit) {
                            final index = _dailyHabits.indexOf(habit);
                            final isCompleted = habit['completed'] as bool;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCompleted
                                        ? AppColors.pink.withOpacity(0.2)
                                        : AppColors.lightGray.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Icon
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.pink.withOpacity(0.1)
                                            : AppColors.lightGray.withOpacity(
                                                0.2,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          IconData(
                                            habit['icon'],
                                            fontFamily: 'MaterialIcons',
                                          ),
                                          size: 18,
                                          color: isCompleted
                                              ? AppColors.pink
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            habit['title'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isCompleted
                                                  ? AppColors.textSecondary
                                                  : AppColors.textPrimary,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          if (habit['description'] != null &&
                                              habit['description']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              habit['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Toggle switch
                                    GestureDetector(
                                      onTap: () => _toggleHabit(index),
                                      child: Container(
                                        width: 36,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.pink
                                              : AppColors.lightGray,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            AnimatedPositioned(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              left: isCompleted ? 18 : 2,
                                              top: 2,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          AppColors.shadowLight,
                                                      blurRadius: 2,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _hapticFeedback();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEntryPage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: AppColors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 7,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Küçültülmüş yükseklik
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12), // Küçültülmüş padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8), // Küçültülmüş padding
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 18, // Küçültülmüş icon
                        ),
                      ),
                      const SizedBox(width: 10), // Küçültülmüş boşluk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 14, // Küçültülmüş font
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 11, // Küçültülmüş font
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Küçültülmüş boşluk
                  // Steps - Now with better layout
                  Expanded(
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 10, // Küçültülmüş font
                        color: AppColors.textSecondary,
                        height: 1.2, // Küçültülmüş line height
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
