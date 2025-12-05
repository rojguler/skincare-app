import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_entry_page.dart';
import '../models/skincare_entry.dart';
import '../core/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late AnimationController _animationController;
  late AnimationController _calendarController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _calendarAnimation;

  // View mode toggle
  bool _isWeeklyView = false;

  // Routine repetition
  Map<String, Map<String, dynamic>> _routines = {};

  // Statistics
  int _totalEntries = 0;
  int _currentMonthEntries = 0;
  String _mostUsedProduct = '';
  int _streakDays = 0;
  int _totalRoutines = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _calendarController = AnimationController(
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

    _calendarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _calendarController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _calendarController.forward();
    _loadRoutines();
    _loadStatistics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _loadRoutines() {
    try {
      final routinesBox = Hive.box('routines');
      final savedRoutines = routinesBox.get('user_routines', defaultValue: {});
      if (savedRoutines is Map) {
        setState(() {
          _routines = Map<String, Map<String, dynamic>>.from(savedRoutines);
        });
      }
    } catch (e) {}
  }

  void _loadStatistics() {
    try {
      final entriesBox = Hive.box('entries');
      final allEntries = entriesBox.values.toList();

      // Total entries
      _totalEntries = allEntries
          .where((entry) => entry is SkincareEntry)
          .length;

      // Current month entries
      final now = DateTime.now();
      final currentMonthEntries = allEntries.where((entry) {
        if (entry is SkincareEntry) {
          return entry.createdAt.year == now.year &&
              entry.createdAt.month == now.month;
        }
        return false;
      }).length;
      _currentMonthEntries = currentMonthEntries;

      // Most used product
      final productUsage = <String, int>{};
      for (final entry in allEntries) {
        if (entry is SkincareEntry) {
          for (final product in entry.products) {
            productUsage[product] = (productUsage[product] ?? 0) + 1;
          }
        }
      }

      if (productUsage.isNotEmpty) {
        final mostUsed = productUsage.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        _mostUsedProduct = mostUsed.key;
      }

      // Streak days
      _streakDays = _calculateStreakDays(allEntries);

      // Total routines
      _totalRoutines = _routines.length;

      setState(() {});
    } catch (e) {}
  }

  int _calculateStreakDays(List allEntries) {
    if (allEntries.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    int currentDay = 0;

    while (currentDay < 365) {
      // Check last year
      final checkDate = today.subtract(Duration(days: currentDay));
      final hasEntry = allEntries.any((entry) {
        if (entry is SkincareEntry) {
          final entryDate = DateTime(
            entry.createdAt.year,
            entry.createdAt.month,
            entry.createdAt.day,
          );
          return entryDate.isAtSameMomentAs(checkDate);
        }
        return false;
      });

      if (hasEntry) {
        streak++;
        currentDay++;
      } else {
        break;
      }
    }
    return streak;
  }

  void _showRoutineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Yeni Rutin Ekle',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Rutin ekleme özelliği yakında gelecek!',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(
                color: AppColors.pink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 40, // Daha da küçültülmüş yükseklik
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.pink,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Text(
                  'Takvim',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
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
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: AppColors.white, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddEntryPage()),
                        );
                      },
                      tooltip: 'Yeni Kayıt',
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.pink.withOpacity(0.1),
                          AppColors.yellow.withOpacity(0.05),
                          AppColors.marron.withOpacity(0.03),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Icon(
                            Icons.calendar_today,
                            size: 50,
                            color: AppColors.pink.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left: 30,
                          child: Icon(
                            Icons.event_note,
                            size: 30,
                            color: AppColors.yellow.withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Statistics Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.calendar_today,
                              title: 'Toplam Kayıt',
                              value: '$_totalEntries',
                              color: AppColors.pink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.trending_up,
                              title: 'Bu Ay',
                              value: '$_currentMonthEntries',
                              color: AppColors.marron,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.favorite,
                              title: 'En Çok Kullanılan',
                              value: _mostUsedProduct.isNotEmpty
                                  ? _mostUsedProduct
                                  : '-',
                              color: AppColors.pink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.local_fire_department,
                              title: 'Günlük Seri',
                              value: '$_streakDays gün',
                              color: AppColors.pink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.repeat,
                              title: 'Aktif Rutinler',
                              value: '$_totalRoutines',
                              color: AppColors.marron,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Calendar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _calendarAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_calendarAnimation.value * 0.2),
                      child: Column(
                        children: [
                          // Monthly Progress Chart
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.pink.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.trending_up,
                                        color: AppColors.pink,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Bu Ayın İlerlemesi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$_currentMonthEntries gün',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildMonthlyProgressChart(),
                              ],
                            ),
                          ),

                          // Main Calendar
                          Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TableCalendar<SkincareEntry>(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                _hapticFeedback();
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                weekendTextStyle: GoogleFonts.poppins(
                                  color: AppColors.pink,
                                  fontWeight: FontWeight.w600,
                                ),
                                holidayTextStyle: GoogleFonts.poppins(
                                  color: AppColors.pink,
                                  fontWeight: FontWeight.w600,
                                ),
                                defaultTextStyle: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                selectedTextStyle: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                todayTextStyle: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: AppColors.pink,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: AppColors.marron,
                                  shape: BoxShape.circle,
                                ),
                                markersMaxCount: 3,
                                markerSize: 6,
                                markerMargin: const EdgeInsets.symmetric(
                                  horizontal: 0.3,
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: true,
                                titleCentered: true,
                                formatButtonShowsNext: false,
                                formatButtonDecoration: BoxDecoration(
                                  color: AppColors.pink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                formatButtonTextStyle: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                titleTextStyle: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left,
                                  color: AppColors.pink,
                                  size: 24,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.pink,
                                  size: 24,
                                ),
                              ),
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Positioned(
                                      bottom: 1,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppColors.marron,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddEntryPage()),
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 20,
                          ),
                          label: Text(
                            'Yeni Kayıt',
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showRoutineDialog,
                          icon: Icon(
                            Icons.repeat,
                            color: AppColors.pink,
                            size: 20,
                          ),
                          label: Text(
                            'Rutin Ekle',
                            style: GoogleFonts.poppins(
                              color: AppColors.pink,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: AppColors.pink, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgressChart() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final entriesBox = Hive.box('entries');
    final allEntries = entriesBox.values.toList();

    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                flex: _currentMonthEntries,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.pink, AppColors.pink.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                flex: daysInMonth - _currentMonthEntries,
                child: Container(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Daily dots
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(daysInMonth, (index) {
            final day = index + 1;
            final hasEntry = allEntries.any((entry) {
              if (entry is SkincareEntry) {
                return entry.createdAt.year == now.year &&
                    entry.createdAt.month == now.month &&
                    entry.createdAt.day == day;
              }
              return false;
            });

            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hasEntry
                    ? AppColors.pink
                    : AppColors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Kayıt var',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Kayıt yok',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
