import 'package:json_annotation/json_annotation.dart';

part 'habit.g.dart';

@JsonSerializable()
class Habit {
  final String id;
  final String text;
  final String description;
  final int iconCodePoint;
  final String time;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.text,
    required this.description,
    required this.iconCodePoint,
    required this.time,
    required this.frequency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);

  Habit copyWith({
    String? id,
    String? text,
    String? description,
    int? iconCodePoint,
    String? time,
    String? frequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      text: text ?? this.text,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class HabitProgress {
  final String habitId;
  final DateTime date;
  final bool completed;
  final DateTime? completedAt;

  HabitProgress({
    required this.habitId,
    required this.date,
    required this.completed,
    this.completedAt,
  });

  factory HabitProgress.fromJson(Map<String, dynamic> json) =>
      _$HabitProgressFromJson(json);
  Map<String, dynamic> toJson() => _$HabitProgressToJson(this);

  HabitProgress copyWith({
    String? habitId,
    DateTime? date,
    bool? completed,
    DateTime? completedAt,
  }) {
    return HabitProgress(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
