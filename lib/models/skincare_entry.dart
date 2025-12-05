import 'package:hive/hive.dart';

part 'skincare_entry.g.dart';

@HiveType(typeId: 0)
class SkincareEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<String> products;

  @HiveField(3)
  String notes;

  @HiveField(4)
  List<String> imagePaths;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String skinType;

  SkincareEntry({
    required this.id,
    required this.date,
    required this.products,
    required this.notes,
    required this.imagePaths,
    required this.createdAt,
    required this.skinType,
  });
}
