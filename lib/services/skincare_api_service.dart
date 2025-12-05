import 'dart:convert';
import 'package:http/http.dart' as http;

class SkincareProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final List<String> ingredients;
  final List<String> skinTypes;
  final List<String> benefits;
  final double rating;
  final int reviewCount;
  final String barcode;
  final String size;
  final String texture;
  final String scent;

  SkincareProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.ingredients,
    required this.skinTypes,
    required this.benefits,
    required this.rating,
    required this.reviewCount,
    required this.barcode,
    required this.size,
    required this.texture,
    required this.scent,
  });

  factory SkincareProduct.fromJson(Map<String, dynamic> json) {
    return SkincareProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TL',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      skinTypes: List<String>.from(json['skinTypes'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      barcode: json['barcode'] ?? '',
      size: json['size'] ?? '',
      texture: json['texture'] ?? '',
      scent: json['scent'] ?? '',
    );
  }
}

class SkincareApiService {
  // SkincareAPI entegrasyonu
  static const String _baseUrl = 'https://skincare-api.herokuapp.com';
  static const String _apiKey = ''; // API key gerekmiyor

  // Mock cilt bakım ürünleri veritabanı
  static final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': '1',
      'name': 'CeraVe Foaming Facial Cleanser',
      'brand': 'CeraVe',
      'category': 'Temizleyici',
      'description': 'Yağlı ve karma ciltler için köpüklü yüz temizleyici',
      'imageUrl': 'https://via.placeholder.com/300x300?text=CeraVe+Cleanser',
      'price': 89.90,
      'currency': 'TL',
      'ingredients': ['Ceramides', 'Hyaluronic Acid', 'Niacinamide'],
      'skinTypes': ['Yağlı', 'Karma'],
      'benefits': ['Gözenek Temizliği', 'Nem Dengesi', 'Cilt Bariyeri'],
      'rating': 4.5,
      'reviewCount': 1250,
      'barcode': '1234567890123',
      'size': '236ml',
      'texture': 'Köpüklü',
      'scent': 'Kokusuz',
    },
    {
      'id': '2',
      'name': 'The Ordinary Niacinamide 10% + Zinc 1%',
      'brand': 'The Ordinary',
      'category': 'Serum',
      'description': 'Gözenekleri küçültmek ve yağ üretimini kontrol etmek için serum',
      'imageUrl': 'https://via.placeholder.com/300x300?text=The+Ordinary+Niacinamide',
      'price': 45.00,
      'currency': 'TL',
      'ingredients': ['Niacinamide', 'Zinc PCA'],
      'skinTypes': ['Yağlı', 'Karma', 'Hassas'],
      'benefits': ['Gözenek Küçültme', 'Yağ Kontrolü', 'Cilt Dengeleme'],
      'rating': 4.3,
      'reviewCount': 890,
      'barcode': '1234567890124',
      'size': '30ml',
      'texture': 'Sıvı',
      'scent': 'Kokusuz',
    },
    {
      'id': '3',
      'name': 'La Roche-Posay Toleriane Double Repair Moisturizer',
      'brand': 'La Roche-Posay',
      'category': 'Nemlendirici',
      'description': 'Hassas ciltler için onarıcı nemlendirici krem',
      'imageUrl': 'https://via.placeholder.com/300x300?text=La+Roche-Posay+Moisturizer',
      'price': 129.90,
      'currency': 'TL',
      'ingredients': ['Ceramides', 'Niacinamide', 'Thermal Water'],
      'skinTypes': ['Hassas', 'Kuru', 'Normal'],
      'benefits': ['Cilt Onarımı', 'Nemlendirme', 'Bariyer Güçlendirme'],
      'rating': 4.7,
      'reviewCount': 2100,
      'barcode': '1234567890125',
      'size': '75ml',
      'texture': 'Krem',
      'scent': 'Kokusuz',
    },
    {
      'id': '4',
      'name': 'Paula\'s Choice 2% BHA Liquid Exfoliant',
      'brand': 'Paula\'s Choice',
      'category': 'Eksfoliyant',
      'description': 'Siyah nokta ve gözenekler için BHA eksfoliyant',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Paula+Choice+BHA',
      'price': 199.00,
      'currency': 'TL',
      'ingredients': ['Salicylic Acid', 'Green Tea Extract'],
      'skinTypes': ['Yağlı', 'Karma', 'Hassas'],
      'benefits': ['Siyah Nokta Temizliği', 'Gözenek Açma', 'Cilt Yenileme'],
      'rating': 4.6,
      'reviewCount': 3200,
      'barcode': '1234567890126',
      'size': '118ml',
      'texture': 'Sıvı',
      'scent': 'Kokusuz',
    },
    {
      'id': '5',
      'name': 'Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 50+',
      'brand': 'Neutrogena',
      'category': 'Güneş Kremi',
      'description': 'Yağsız, hızlı emilen güneş koruyucu krem',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Neutrogena+Sunscreen',
      'price': 79.90,
      'currency': 'TL',
      'ingredients': ['Zinc Oxide', 'Titanium Dioxide'],
      'skinTypes': ['Tüm Cilt Tipleri'],
      'benefits': ['UV Koruması', 'Yağsız Formül', 'Hızlı Emilim'],
      'rating': 4.4,
      'reviewCount': 1800,
      'barcode': '1234567890127',
      'size': '88ml',
      'texture': 'Krem',
      'scent': 'Kokusuz',
    },
    {
      'id': '6',
      'name': 'The Inkey List Retinol Serum',
      'brand': 'The Inkey List',
      'category': 'Anti-Aging',
      'description': 'Kırışıklık karşıtı retinol serum',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Inkey+List+Retinol',
      'price': 89.00,
      'currency': 'TL',
      'ingredients': ['Retinol', 'Squalane'],
      'skinTypes': ['Normal', 'Kuru', 'Karma'],
      'benefits': ['Kırışıklık Azaltma', 'Cilt Yenileme', 'Anti-Aging'],
      'rating': 4.2,
      'reviewCount': 950,
      'barcode': '1234567890128',
      'size': '30ml',
      'texture': 'Serum',
      'scent': 'Kokusuz',
    },
  ];

  // Ürün arama
  static Future<List<SkincareProduct>> searchProducts({
    String? query,
    String? category,
    String? skinType,
    String? brand,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      // Gerçek API çağrısı
      final response = await http.get(
        Uri.parse('$_baseUrl/products?${_buildQueryParams({
          'q': query,
          'category': category,
          'skinType': skinType,
          'brand': brand,
          'minPrice': minPrice?.toString(),
          'maxPrice': maxPrice?.toString(),
          'limit': limit.toString(),
        })}'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SkincareProduct.fromJson(json)).toList();
      } else {
        print('API hatası: ${response.statusCode}');
        // Fallback olarak mock data kullan
        return _getMockProducts(query, category, skinType, brand, minPrice, maxPrice);
      }
    } catch (e) {
      print('Ürün arama hatası: $e');
      // Fallback olarak mock data kullan
      return _getMockProducts(query, category, skinType, brand, minPrice, maxPrice);
    }
  }

  // Mock data fallback metodu
  static List<SkincareProduct> _getMockProducts(
    String? query,
    String? category,
    String? skinType,
    String? brand,
    double? minPrice,
    double? maxPrice,
  ) {
    List<Map<String, dynamic>> filteredProducts = _mockProducts.where((product) {
      if (query != null && query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        if (!product['name'].toLowerCase().contains(searchQuery) &&
            !product['brand'].toLowerCase().contains(searchQuery) &&
            !product['description'].toLowerCase().contains(searchQuery)) {
          return false;
        }
      }

      if (category != null && product['category'] != category) {
        return false;
      }

      if (skinType != null && !product['skinTypes'].contains(skinType)) {
        return false;
      }

      if (brand != null && product['brand'].toLowerCase() != brand.toLowerCase()) {
        return false;
      }

      if (minPrice != null && product['price'] < minPrice) {
        return false;
      }

      if (maxPrice != null && product['price'] > maxPrice) {
        return false;
      }

      return true;
    }).toList();

    return filteredProducts.map((json) => SkincareProduct.fromJson(json)).toList();
  }

  // Ürün detayı getir
  static Future<SkincareProduct?> getProductById(String id) async {
    try {
      // Gerçek API çağrısı
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SkincareProduct.fromJson(data);
      } else {
        print('API hatası: ${response.statusCode}');
        // Fallback olarak mock data kullan
        final product = _mockProducts.firstWhere(
          (p) => p['id'] == id,
          orElse: () => {},
        );
        if (product.isEmpty) return null;
        return SkincareProduct.fromJson(product);
      }
    } catch (e) {
      print('Ürün detay hatası: $e');
      // Fallback olarak mock data kullan
      final product = _mockProducts.firstWhere(
        (p) => p['id'] == id,
        orElse: () => {},
      );
      if (product.isEmpty) return null;
      return SkincareProduct.fromJson(product);
    }
  }

  // Barkod ile ürün arama
  static Future<SkincareProduct?> getProductByBarcode(String barcode) async {
    try {
      // Gerçek API çağrısı
      final response = await http.get(
        Uri.parse('$_baseUrl/products/barcode/$barcode'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return SkincareProduct.fromJson(data);
      } else {
        print('API hatası: ${response.statusCode}');
        // Fallback olarak mock data kullan
        final product = _mockProducts.firstWhere(
          (p) => p['barcode'] == barcode,
          orElse: () => {},
        );
        if (product.isEmpty) return null;
        return SkincareProduct.fromJson(product);
      }
    } catch (e) {
      print('Barkod arama hatası: $e');
      // Fallback olarak mock data kullan
      final product = _mockProducts.firstWhere(
        (p) => p['barcode'] == barcode,
        orElse: () => {},
      );
      if (product.isEmpty) return null;
      return SkincareProduct.fromJson(product);
    }
  }

  // Kategorileri getir
  static Future<List<String>> getCategories() async {
    try {
      // Gerçek API çağrısı
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        print('API hatası: ${response.statusCode}');
        // Fallback olarak mock data kullan
        return ['Temizleyici', 'Serum', 'Nemlendirici', 'Eksfoliyant', 'Güneş Kremi', 'Anti-Aging', 'Tonik', 'Maske'];
      }
    } catch (e) {
      print('Kategori listesi hatası: $e');
      // Fallback olarak mock data kullan
      return ['Temizleyici', 'Serum', 'Nemlendirici', 'Eksfoliyant', 'Güneş Kremi', 'Anti-Aging', 'Tonik', 'Maske'];
    }
  }

  // Markaları getir
  static Future<List<String>> getBrands() async {
    try {
      // Gerçek API çağrısı
      final response = await http.get(
        Uri.parse('$_baseUrl/brands'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((brand) => brand.toString()).toList();
      } else {
        print('API hatası: ${response.statusCode}');
        // Fallback olarak mock data kullan
        return ['CeraVe', 'The Ordinary', 'La Roche-Posay', 'Paula\'s Choice', 'Neutrogena', 'The Inkey List', 'Olay', 'Nivea'];
      }
    } catch (e) {
      print('Marka listesi hatası: $e');
      // Fallback olarak mock data kullan
      return ['CeraVe', 'The Ordinary', 'La Roche-Posay', 'Paula\'s Choice', 'Neutrogena', 'The Inkey List', 'Olay', 'Nivea'];
    }
  }

  // Önerilen ürünler (cilt tipine göre)
  static Future<List<SkincareProduct>> getRecommendedProducts(String skinType) async {
    try {
      return await searchProducts(
        skinType: skinType,
        limit: 10,
      );
    } catch (e) {
      print('Önerilen ürünler hatası: $e');
      return [];
    }
  }

  // API bağlantısını test et
  static Future<bool> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products?limit=1'),
        headers: {'accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        print('✅ SkincareAPI bağlantısı başarılı!');
        return true;
      } else {
        print('❌ SkincareAPI bağlantı hatası: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ SkincareAPI bağlantı hatası: $e');
      return false;
    }
  }

  // Query parametrelerini oluştur
  static String _buildQueryParams(Map<String, String?> params) {
    final filteredParams = params.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value!)}')
        .join('&');
    
    return filteredParams;
  }
}
