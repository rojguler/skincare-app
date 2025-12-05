import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../services/firebase_service.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> with TickerProviderStateMixin {
  String selectedTab = 'daily';
  final List<String> tabs = ['daily', 'weekly', 'monthly'];

  // Confetti controller
  late ConfettiController _confettiController;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, List<Map<String, dynamic>>> habits = {
    'daily': [
      {
        'text': 'Yüz Yıkama',
        'completed': false,
        'description': 'Sabah ve akşam yüzünü temizle',
        'icon': Icons.cleaning_services_outlined.codePoint,
        'time': 'Sabah & Akşam',
      },
      {
        'text': 'Bol Su İç',
        'completed': false,
        'description': 'Günde en az 8 bardak su iç',
        'icon': Icons.water_drop_outlined.codePoint,
        'time': 'Gün boyu',
      },
      {
        'text': 'Güneş Kremi',
        'completed': false,
        'description': 'Güneşe çıkmadan önce mutlaka sür',
        'icon': Icons.wb_sunny_outlined.codePoint,
        'time': 'Sabah',
      },
      {
        'text': 'Gece Bakımı',
        'completed': false,
        'description': 'Yatmadan önce serum ve nemlendirici',
        'icon': Icons.nightlight_outlined.codePoint,
        'time': 'Akşam',
      },
    ],
    'weekly': [
      {
        'text': 'Yüz Maskesi',
        'completed': false,
        'description': 'Haftada 2-3 kez maske yap',
        'icon': Icons.face_outlined.codePoint,
        'time': 'Haftada 2-3 kez',
      },
      {
        'text': 'Tırnak Bakımı',
        'completed': false,
        'description': 'Tırnaklarını kes ve bakım yap',
        'icon': Icons.brush_outlined.codePoint,
        'time': 'Haftada 1 kez',
      },
      {
        'text': 'Saç Bakımı',
        'completed': false,
        'description': 'Saç maskesi veya yağ uygula',
        'icon': Icons.face_retouching_natural_outlined.codePoint,
        'time': 'Haftada 1 kez',
      },
      {
        'text': 'Vücut Peeling',
        'completed': false,
        'description': 'Vücudunu ölü derilerden arındır',
        'icon': Icons.spa_outlined.codePoint,
        'time': 'Haftada 1 kez',
      },
    ],
    'monthly': [
      {
        'text': 'Dermatolog Kontrolü',
        'completed': false,
        'description': 'Cilt sağlığın için düzenli kontrol',
        'icon': Icons.medical_services_outlined.codePoint,
        'time': 'Ayda 1 kez',
      },
      {
        'text': 'Ürün Değerlendirmesi',
        'completed': false,
        'description': 'Kullandığın ürünleri değerlendir',
        'icon': Icons.rate_review_outlined.codePoint,
        'time': 'Ayda 1 kez',
      },
      {
        'text': 'Rutin Güncelleme',
        'completed': false,
        'description': 'Rutinini mevsime göre güncelle',
        'icon': Icons.update_outlined.codePoint,
        'time': 'Ayda 1 kez',
      },
      {
        'text': 'Yeni Ürün Deneme',
        'completed': false,
        'description': 'Yeni bir ürün dene ve test et',
        'icon': Icons.science_outlined.codePoint,
        'time': 'Ayda 1 kez',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _loadHabits();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _resetToDefaultHabits() {
    setState(() {
      habits['daily'] = [
        {
          'text': 'Yüz Yıkama',
          'completed': false,
          'description': 'Sabah ve akşam yüzünü temizle',
          'icon': Icons.cleaning_services_outlined.codePoint,
          'time': 'Sabah & Akşam',
        },
        {
          'text': 'Bol Su İç',
          'completed': false,
          'description': 'Günde en az 8 bardak su iç',
          'icon': Icons.water_drop_outlined.codePoint,
          'time': 'Gün boyu',
        },
        {
          'text': 'Güneş Kremi',
          'completed': false,
          'description': 'Güneşe çıkmadan önce mutlaka sür',
          'icon': Icons.wb_sunny_outlined.codePoint,
          'time': 'Sabah',
        },
        {
          'text': 'Gece Bakımı',
          'completed': false,
          'description': 'Yatmadan önce serum ve nemlendirici',
          'icon': Icons.nightlight_outlined.codePoint,
          'time': 'Akşam',
        },
      ];
    });
  }

  void _loadHabits() {
    try {
      final habitsBox = Hive.box('habits');
      final savedDailyHabits = habitsBox.get('dailyHabits');
      final savedWeeklyHabits = habitsBox.get('weeklyHabits');
      final savedMonthlyHabits = habitsBox.get('monthlyHabits');
      final lastSavedDate = habitsBox.get('lastHabitsDate');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Check if it's a new day - reset daily habits if yes
      bool shouldReset = lastSavedDate == null || lastSavedDate != today;

      // Load daily habits
      if (savedDailyHabits != null &&
          savedDailyHabits is List &&
          !shouldReset) {
        try {
          // Convert dynamic maps to Map<String, dynamic> safely
          final convertedHabits = savedDailyHabits
              .map((habit) {
                if (habit is Map) {
                  return {
                    'text': habit['text'] ?? 'Alışkanlık',
                    'completed': habit['completed'] ?? false,
                    'description': habit['description'] ?? '',
                    'icon': habit['icon'] ?? Icons.spa_outlined.codePoint,
                    'time': habit['time'] ?? 'Günlük',
                  };
                }
                return <String, dynamic>{};
              })
              .where((habit) => habit.isNotEmpty)
              .toList();

          setState(() {
            habits['daily'] = convertedHabits;
          });
        } catch (e) {
          // Fallback to default habits
          _resetToDefaultHabits();
        }
      } else if (shouldReset) {
        // Reset daily habits for new day
        _resetToDefaultHabits();
        // Save current date
        habitsBox.put('lastHabitsDate', today);
        // Sıfırlanmış durumu kaydet
        habitsBox.put('dailyHabits', habits['daily']);
      } else {
        // First time loading - save current date
        habitsBox.put('lastHabitsDate', today);
        _resetToDefaultHabits();
      }

      // Load weekly habits
      if (savedWeeklyHabits != null && savedWeeklyHabits is List) {
        try {
          final convertedWeeklyHabits = savedWeeklyHabits
              .map((habit) {
                if (habit is Map) {
                  return {
                    'text': habit['text'] ?? 'Alışkanlık',
                    'completed': habit['completed'] ?? false,
                    'description': habit['description'] ?? '',
                    'icon': habit['icon'] ?? Icons.spa_outlined.codePoint,
                    'time': habit['time'] ?? 'Haftalık',
                  };
                }
                return <String, dynamic>{};
              })
              .where((habit) => habit.isNotEmpty)
              .toList();

          setState(() {
            habits['weekly'] = convertedWeeklyHabits;
          });
        } catch (e) {}
      }

      // Load monthly habits
      if (savedMonthlyHabits != null && savedMonthlyHabits is List) {
        try {
          final convertedMonthlyHabits = savedMonthlyHabits
              .map((habit) {
                if (habit is Map) {
                  return {
                    'text': habit['text'] ?? 'Alışkanlık',
                    'completed': habit['completed'] ?? false,
                    'description': habit['description'] ?? '',
                    'icon': habit['icon'] ?? Icons.spa_outlined.codePoint,
                    'time': habit['time'] ?? 'Aylık',
                  };
                }
                return <String, dynamic>{};
              })
              .where((habit) => habit.isNotEmpty)
              .toList();

          setState(() {
            habits['monthly'] = convertedMonthlyHabits;
          });
        } catch (e) {}
      }
    } catch (e) {}
  }

  void _saveHabits() {
    try {
      final habitsBox = Hive.box('habits');
      habitsBox.put('dailyHabits', habits['daily']);
      habitsBox.put('weeklyHabits', habits['weekly']);
      habitsBox.put('monthlyHabits', habits['monthly']);

      // Firebase'e senkronize et
      FirebaseService.syncDataToCloud();
    } catch (e) {}
  }

  double _calculateProgress() {
    if (habits[selectedTab]!.isEmpty) return 0.0;

    int completedCount = 0;
    int totalCount = habits[selectedTab]!.length;

    for (final habit in habits[selectedTab]!) {
      if (habit['completed'] == true) {
        completedCount++;
      }
    }

    return totalCount > 0 ? completedCount / totalCount : 0.0;
  }

  int _getCompletedCount() {
    if (habits[selectedTab]!.isEmpty) return 0;

    int completedCount = 0;
    for (final habit in habits[selectedTab]!) {
      if (habit['completed'] == true) {
        completedCount++;
      }
    }

    return completedCount;
  }

  void _toggleHabit(int index) {
    setState(() {
      habits[selectedTab]![index]['completed'] =
          !habits[selectedTab]![index]['completed'];
    });

    _saveHabits();
    _hapticFeedback();

    // Confetti animation if all habits completed
    if (_calculateProgress() == 1.0) {
      _confettiController.play();
    }
  }

  void _deleteHabit(int index) {
    setState(() {
      habits[selectedTab]!.removeAt(index);
    });
    _saveHabits();
    _hapticFeedback();
  }

  void _showAddHabitDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    IconData selectedIcon = Icons.spa_outlined;
    String selectedTime = 'Günlük';

    final List<IconData> icons = [
      Icons.cleaning_services_outlined,
      Icons.water_drop_outlined,
      Icons.wb_sunny_outlined,
      Icons.nightlight_outlined,
      Icons.face_outlined,
      Icons.brush_outlined,
      Icons.face_retouching_natural_outlined,
      Icons.spa_outlined,
      Icons.medical_services_outlined,
      Icons.rate_review_outlined,
      Icons.update_outlined,
      Icons.science_outlined,
    ];
    final List<String> times = ['Günlük', 'Haftalık', 'Aylık'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.white,
          title: Text(
            'Yeni Alışkanlık',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Alışkanlık Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  decoration: InputDecoration(
                    labelText: 'Sıklık',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: times.map((time) {
                    return DropdownMenuItem(value: time, child: Text(time));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'İkon Seç',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
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
                if (nameController.text.isNotEmpty) {
                  final newHabit = {
                    'text': nameController.text,
                    'completed': false,
                    'description': descriptionController.text,
                    'icon': selectedIcon.codePoint,
                    'time': selectedTime,
                  };

                  String targetTab = 'daily';
                  if (selectedTime == 'Haftalık') targetTab = 'weekly';
                  if (selectedTime == 'Aylık') targetTab = 'monthly';

                  setState(() {
                    habits[targetTab]!.add(newHabit);
                  });

                  _saveHabits();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ekle',
                style: GoogleFonts.poppins(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.pink,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Alışkanlıklar',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: AppColors.pink,
            ),
            onPressed: () {
              _showAddHabitDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 24),

                      // Progress Card
                      // Enhanced Progress Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.pink.withOpacity(0.1),
                              AppColors.yellow.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.pink.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.pink,
                                        AppColors.pink.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.pink.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${selectedTab == 'daily'
                                            ? 'Günlük'
                                            : selectedTab == 'weekly'
                                            ? 'Haftalık'
                                            : 'Aylık'} İlerleme',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${(_calculateProgress() * 100).toStringAsFixed(0)}% tamamlandı • ${_getCompletedCount()} / ${habits[selectedTab]!.length} alışkanlık',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Stack(
                              children: [
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 800),
                                  height: 12,
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.8 *
                                      _calculateProgress(),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.pink,
                                        AppColors.yellow,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.pink.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
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

                      // Enhanced Tab Buttons
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.pink.withOpacity(0.2),
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
                        child: Row(
                          children: tabs.map((tab) {
                            final isSelected = selectedTab == tab;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTab = tab;
                                  });
                                  _hapticFeedback();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              AppColors.pink,
                                              AppColors.pink.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.pink.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    tab == 'daily'
                                        ? 'Günlük'
                                        : tab == 'weekly'
                                        ? 'Haftalık'
                                        : 'Aylık',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Habits List
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...habits[selectedTab]!.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final habit = entry.value;
                                final isCompleted = habit['completed'] == true;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
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
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.primary.withOpacity(
                                                  0.1,
                                                )
                                              : AppColors.lightGray.withOpacity(
                                                  0.3,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            IconData(
                                              habit['icon'],
                                              fontFamily: 'MaterialIcons',
                                            ),
                                            size: 24,
                                            color: isCompleted
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              habit['text'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isCompleted
                                                    ? AppColors.textSecondary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              habit['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              habit['time'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Toggle switch
                                      GestureDetector(
                                        onTap: () => _toggleHabit(index),
                                        child: Container(
                                          width: 44,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? AppColors.primary
                                                : AppColors.lightGray,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                left: isCompleted ? 22 : 2,
                                                top: 2,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .shadowLight,
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
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
                                      const SizedBox(width: 12),
                                      // Delete button
                                      GestureDetector(
                                        onTap: () => _deleteHabit(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: AppColors.error,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              // Empty state
                              if (habits[selectedTab]!.isEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
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
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.textSecondary,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Henüz alışkanlık yok',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Yeni alışkanlık eklemek için + butonuna tıkla',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
