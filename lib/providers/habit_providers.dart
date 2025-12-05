import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';

part 'habit_providers.g.dart';

// Repository provider
@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepository();
}

// Daily habits provider
@riverpod
class DailyHabits extends _$DailyHabits {
  @override
  Future<List<HabitWithProgress>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.initialize();

    // Check if we need to reset daily habits
    if (await repository.shouldResetDailyHabits()) {
      await repository.resetDailyHabitsProgress();
    }

    final habits = await repository.getHabitsByFrequency('daily');
    final habitsWithProgress = <HabitWithProgress>[];

    for (final habit in habits) {
      final progress = await repository.getTodayProgress(habit.id);
      habitsWithProgress.add(
        HabitWithProgress(
          habit: habit,
          isCompleted: progress?.completed ?? false,
          completedAt: progress?.completedAt,
        ),
      );
    }

    return habitsWithProgress;
  }

  Future<void> toggleHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    final currentState = await future;

    final habitIndex = currentState.indexWhere((h) => h.habit.id == habitId);
    if (habitIndex == -1) return;

    final currentHabit = currentState[habitIndex];
    final newCompleted = !currentHabit.isCompleted;

    await repository.saveTodayProgress(habitId, newCompleted);

    // Invalidate to refresh the state
    ref.invalidateSelf();
  }

  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(habitId);
    ref.invalidateSelf();
  }
}

// Weekly habits provider
@riverpod
class WeeklyHabits extends _$WeeklyHabits {
  @override
  Future<List<HabitWithProgress>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.initialize();

    final habits = await repository.getHabitsByFrequency('weekly');
    final habitsWithProgress = <HabitWithProgress>[];

    for (final habit in habits) {
      final progress = await repository.getTodayProgress(habit.id);
      habitsWithProgress.add(
        HabitWithProgress(
          habit: habit,
          isCompleted: progress?.completed ?? false,
          completedAt: progress?.completedAt,
        ),
      );
    }

    return habitsWithProgress;
  }

  Future<void> toggleHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    final currentState = await future;

    final habitIndex = currentState.indexWhere((h) => h.habit.id == habitId);
    if (habitIndex == -1) return;

    final currentHabit = currentState[habitIndex];
    final newCompleted = !currentHabit.isCompleted;

    await repository.saveTodayProgress(habitId, newCompleted);
    ref.invalidateSelf();
  }

  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(habitId);
    ref.invalidateSelf();
  }
}

// Monthly habits provider
@riverpod
class MonthlyHabits extends _$MonthlyHabits {
  @override
  Future<List<HabitWithProgress>> build() async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.initialize();

    final habits = await repository.getHabitsByFrequency('monthly');
    final habitsWithProgress = <HabitWithProgress>[];

    for (final habit in habits) {
      final progress = await repository.getTodayProgress(habit.id);
      habitsWithProgress.add(
        HabitWithProgress(
          habit: habit,
          isCompleted: progress?.completed ?? false,
          completedAt: progress?.completedAt,
        ),
      );
    }

    return habitsWithProgress;
  }

  Future<void> toggleHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    final currentState = await future;

    final habitIndex = currentState.indexWhere((h) => h.habit.id == habitId);
    if (habitIndex == -1) return;

    final currentHabit = currentState[habitIndex];
    final newCompleted = !currentHabit.isCompleted;

    await repository.saveTodayProgress(habitId, newCompleted);
    ref.invalidateSelf();
  }

  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(habitId);
    ref.invalidateSelf();
  }
}

// Daily progress provider (for home page)
@riverpod
class DailyProgress extends _$DailyProgress {
  @override
  Future<double> build() async {
    final dailyHabits = await ref.watch(dailyHabitsProvider.future);

    if (dailyHabits.isEmpty) return 0.0;

    final completedCount = dailyHabits.where((h) => h.isCompleted).length;
    return completedCount / dailyHabits.length;
  }
}

// Weekly progress provider
@riverpod
class WeeklyProgress extends _$WeeklyProgress {
  @override
  Future<double> build() async {
    final weeklyHabits = await ref.watch(weeklyHabitsProvider.future);

    if (weeklyHabits.isEmpty) return 0.0;

    final completedCount = weeklyHabits.where((h) => h.isCompleted).length;
    return completedCount / weeklyHabits.length;
  }
}

// Monthly progress provider
@riverpod
class MonthlyProgress extends _$MonthlyProgress {
  @override
  Future<double> build() async {
    final monthlyHabits = await ref.watch(monthlyHabitsProvider.future);

    if (monthlyHabits.isEmpty) return 0.0;

    final completedCount = monthlyHabits.where((h) => h.isCompleted).length;
    return completedCount / monthlyHabits.length;
  }
}

// Combined progress provider (for home page)
@riverpod
class CombinedProgress extends _$CombinedProgress {
  @override
  Future<Map<String, double>> build() async {
    final dailyProgress = await ref.watch(dailyProgressProvider.future);
    final weeklyProgress = await ref.watch(weeklyProgressProvider.future);
    final monthlyProgress = await ref.watch(monthlyProgressProvider.future);

    return {
      'daily': dailyProgress,
      'weekly': weeklyProgress,
      'monthly': monthlyProgress,
    };
  }
}

// Helper class to combine habit with its progress
class HabitWithProgress {
  final Habit habit;
  final bool isCompleted;
  final DateTime? completedAt;

  HabitWithProgress({
    required this.habit,
    required this.isCompleted,
    this.completedAt,
  });
}

// Initialize provider
@riverpod
Future<void> initializeHabits(InitializeHabitsRef ref) async {
  final repository = ref.read(habitRepositoryProvider);
  await repository.initialize();
  await repository.initializeWithDefaults();
}
