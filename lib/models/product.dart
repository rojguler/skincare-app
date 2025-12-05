import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String? barcode;
  final String? brand;
  final String? category;
  final String? description;
  final List<String>? ingredients;
  final Map<String, dynamic>? nutritionInfo;
  final String? imageUrl;
  final String? unit;
  final double? price;
  final String? currency;
  final List<String>? benefits;
  final double? rating;
  final int? reviewCount;
  final String? size;
  final String? texture;
  final String? scent;
  final List<String>? skinTypes;
  final Map<String, dynamic>? additionalInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.barcode,
    this.brand,
    this.category,
    this.description,
    this.ingredients,
    this.nutritionInfo,
    this.imageUrl,
    this.unit,
    this.price,
    this.currency,
    this.benefits,
    this.rating,
    this.reviewCount,
    this.size,
    this.texture,
    this.scent,
    this.skinTypes,
    this.additionalInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Helper method to get formatted ingredients
  String get formattedIngredients {
    if (ingredients == null || ingredients!.isEmpty) {
      return 'İçerik bilgisi mevcut değil';
    }
    return ingredients!.join(', ');
  }

  // Helper method to get formatted nutrition info
  String get formattedNutritionInfo {
    if (nutritionInfo == null || nutritionInfo!.isEmpty) {
      return 'Besin değeri bilgisi mevcut değil';
    }

    List<String> nutritionStrings = [];
    nutritionInfo!.forEach((key, value) {
      if (value != null) {
        nutritionStrings.add('$key: $value');
      }
    });

    return nutritionStrings.isEmpty
        ? 'Besin değeri bilgisi mevcut değil'
        : nutritionStrings.join(', ');
  }

  // Helper method to get formatted unit
  String get formattedUnit {
    if (unit == null) return 'Birim bilgisi mevcut değil';
    return unit!;
  }

  // Helper method to check if product has complete information
  bool get hasCompleteInfo {
    return name.isNotEmpty &&
        (description != null && description!.isNotEmpty) &&
        (ingredients != null && ingredients!.isNotEmpty);
  }

  // Helper method to get data freshness
  String get dataFreshness {
    if (updatedAt == null) return 'Veri güncelliği bilinmiyor';

    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays == 0) {
      return 'Bugün güncellendi';
    } else if (difference.inDays == 1) {
      return 'Dün güncellendi';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce güncellendi';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} hafta önce güncellendi';
    } else {
      return '${(difference.inDays / 30).round()} ay önce güncellendi';
    }
  }
}
