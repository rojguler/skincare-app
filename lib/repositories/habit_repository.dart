import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';

class HabitRepository {
  static const String _habitsKey = 'habits';
  static const String _progressKey = 'habit_progress';
  static const String _lastResetDateKey = 'last_reset_date';

  // Singleton pattern
  static final HabitRepository _instance = HabitRepository._internal();
  factory HabitRepository() => _instance;
  HabitRepository._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get all habits
  Future<List<Habit>> getAllHabits() async {
    final habitsJson = _prefs.getStringList(_habitsKey) ?? [];
    return habitsJson.map((json) => Habit.fromJson(jsonDecode(json))).toList();
  }

  // Get habits by frequency
  Future<List<Habit>> getHabitsByFrequency(String frequency) async {
    final allHabits = await getAllHabits();
    return allHabits.where((habit) => habit.frequency == frequency).toList();
  }

  // Save habit
  Future<void> saveHabit(Habit habit) async {
    final habits = await getAllHabits();
    final existingIndex = habits.indexWhere((h) => h.id == habit.id);

    if (existingIndex >= 0) {
      habits[existingIndex] = habit;
    } else {
      habits.add(habit);
    }

    await _saveHabits(habits);
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    final habits = await getAllHabits();
    habits.removeWhere((habit) => habit.id == habitId);
    await _saveHabits(habits);

    // Also delete related progress
    await deleteHabitProgress(habitId);
  }

  // Save habits list
  Future<void> _saveHabits(List<Habit> habits) async {
    final habitsJson = habits
        .map((habit) => jsonEncode(habit.toJson()))
        .toList();
    await _prefs.setStringList(_habitsKey, habitsJson);
  }

  // Get today's progress for a habit
  Future<HabitProgress?> getTodayProgress(String habitId) async {
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    final progressJson = _prefs.getString('${_progressKey}_$habitId') ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;

    if (progressMap.containsKey(todayKey)) {
      return HabitProgress.fromJson(progressMap[todayKey]);
    }

    return null;
  }

  // Save today's progress for a habit
  Future<void> saveTodayProgress(String habitId, bool completed) async {
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    final progressJson = _prefs.getString('${_progressKey}_$habitId') ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;

    final progress = HabitProgress(
      habitId: habitId,
      date: today,
      completed: completed,
      completedAt: completed ? today : null,
    );

    progressMap[todayKey] = progress.toJson();
    await _prefs.setString('${_progressKey}_$habitId', jsonEncode(progressMap));
  }

  // Delete progress for a habit
  Future<void> deleteHabitProgress(String habitId) async {
    await _prefs.remove('${_progressKey}_$habitId');
  }

  // Get progress for a date range
  Future<List<HabitProgress>> getProgressForDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final progressJson = _prefs.getString('${_progressKey}_$habitId') ?? '{}';
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;

    final List<HabitProgress> progressList = [];

    for (final entry in progressMap.entries) {
      final progress = HabitProgress.fromJson(entry.value);
      if (progress.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          progress.date.isBefore(endDate.add(const Duration(days: 1)))) {
        progressList.add(progress);
      }
    }

    return progressList;
  }

  // Check if we need to reset daily habits
  Future<bool> shouldResetDailyHabits() async {
    final lastResetDate = _prefs.getString(_lastResetDateKey);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastResetDate != today) {
      await _prefs.setString(_lastResetDateKey, today);
      return true;
    }

    return false;
  }

  // Reset all daily habits progress
  Future<void> resetDailyHabitsProgress() async {
    final dailyHabits = await getHabitsByFrequency('daily');

    for (final habit in dailyHabits) {
      await saveTodayProgress(habit.id, false);
    }
  }

  // Get default habits
  List<Habit> getDefaultHabits() {
    return [
      Habit(
        id: 'face_washing',
        text: 'Yüz Yıkama',
        description: 'Sabah ve akşam yüzünü temizle',
        iconCodePoint: 0xe3b3, // Icons.cleaning_services_outlined.codePoint
        time: 'Sabah & Akşam',
        frequency: 'daily',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'drink_water',
        text: 'Bol Su İç',
        description: 'Günde en az 8 bardak su iç',
        iconCodePoint: 0xe1b7, // Icons.water_drop_outlined.codePoint
        time: 'Gün boyu',
        frequency: 'daily',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'sunscreen',
        text: 'Güneş Kremi',
        description: 'Güneşe çıkmadan önce mutlaka sür',
        iconCodePoint: 0xe430, // Icons.wb_sunny_outlined.codePoint
        time: 'Sabah',
        frequency: 'daily',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'night_care',
        text: 'Gece Bakımı',
        description: 'Yatmadan önce serum ve nemlendirici',
        iconCodePoint: 0xe31a, // Icons.nightlight_outlined.codePoint
        time: 'Akşam',
        frequency: 'daily',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'face_mask',
        text: 'Yüz Maskesi',
        description: 'Haftada 2-3 kez maske yap',
        iconCodePoint: 0xe3c5, // Icons.face_outlined.codePoint
        time: 'Haftada 2-3 kez',
        frequency: 'weekly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'nail_care',
        text: 'Tırnak Bakımı',
        description: 'Tırnaklarını kes ve bakım yap',
        iconCodePoint: 0xe3ae, // Icons.brush_outlined.codePoint
        time: 'Haftada 1 kez',
        frequency: 'weekly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'hair_care',
        text: 'Saç Bakımı',
        description: 'Saç maskesi veya yağ uygula',
        iconCodePoint:
            0xe3c4, // Icons.face_retouching_natural_outlined.codePoint
        time: 'Haftada 1 kez',
        frequency: 'weekly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'body_peeling',
        text: 'Vücut Peeling',
        description: 'Vücudunu ölü derilerden arındır',
        iconCodePoint: 0xe3c8, // Icons.spa_outlined.codePoint
        time: 'Haftada 1 kez',
        frequency: 'weekly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'dermatologist',
        text: 'Dermatolog Kontrolü',
        description: 'Cilt sağlığın için düzenli kontrol',
        iconCodePoint: 0xe3f3, // Icons.medical_services_outlined.codePoint
        time: 'Ayda 1 kez',
        frequency: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Habit(
        id: 'product_review',
        text: 'Ürün Değerlendirmesi',
        description: 'Kullandığın ürünleri değerlendir',
        iconCodePoint: 0xe3c6, // Icons.rate_review_outlined.codePoint
        time: 'Ayda 1 kez',
        frequency: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Initialize with default habits if empty
  Future<void> initializeWithDefaults() async {
    final habits = await getAllHabits();
    if (habits.isEmpty) {
      final defaultHabits = getDefaultHabits();
      await _saveHabits(defaultHabits);
    }
  }
}
