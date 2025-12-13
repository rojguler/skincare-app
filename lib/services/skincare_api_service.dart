import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firestore_service.dart';
import '../models/product.dart' as p;

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
      'category': 'Cleanser',
      'description': 'Foaming facial cleanser for oily and combination skin',
      'imageUrl': 'https://via.placeholder.com/300x300?text=CeraVe+Cleanser',
      'price': 89.90,
      'currency': 'TL',
      'ingredients': ['Ceramides', 'Hyaluronic Acid', 'Niacinamide'],
      'skinTypes': ['Oily', 'Combination'],
      'benefits': ['Pore Cleansing', 'Moisture Balance', 'Skin Barrier'],
      'rating': 4.5,
      'reviewCount': 1250,
      'barcode': '1234567890123',
      'size': '236ml',
      'texture': 'Foaming',
      'scent': 'Fragrance-Free',
    },
    {
      'id': '2',
      'name': 'The Ordinary Niacinamide 10% + Zinc 1%',
      'brand': 'The Ordinary',
      'category': 'Serum',
      'description': 'Serum to minimize pores and control oil production',
      'imageUrl': 'https://via.placeholder.com/300x300?text=The+Ordinary+Niacinamide',
      'price': 45.00,
      'currency': 'TL',
      'ingredients': ['Niacinamide', 'Zinc PCA'],
      'skinTypes': ['Oily', 'Combination', 'Sensitive'],
      'benefits': ['Pore Minimizing', 'Oil Control', 'Skin Balancing'],
      'rating': 4.3,
      'reviewCount': 890,
      'barcode': '1234567890124',
      'size': '30ml',
      'texture': 'Liquid',
      'scent': 'Fragrance-Free',
    },
    {
      'id': '3',
      'name': 'La Roche-Posay Toleriane Double Repair Moisturizer',
      'brand': 'La Roche-Posay',
      'category': 'Moisturizer',
      'description': 'Repairing moisturizer cream for sensitive skin',
      'imageUrl': 'https://via.placeholder.com/300x300?text=La+Roche-Posay+Moisturizer',
      'price': 129.90,
      'currency': 'TL',
      'ingredients': ['Ceramides', 'Niacinamide', 'Thermal Water'],
      'skinTypes': ['Sensitive', 'Dry', 'Normal'],
      'benefits': ['Skin Repair', 'Moisturizing', 'Barrier Strengthening'],
      'rating': 4.7,
      'reviewCount': 2100,
      'barcode': '1234567890125',
      'size': '75ml',
      'texture': 'Cream',
      'scent': 'Fragrance-Free',
    },
    {
      'id': '4',
      'name': 'Paula\'s Choice 2% BHA Liquid Exfoliant',
      'brand': 'Paula\'s Choice',
      'category': 'Exfoliant',
      'description': 'BHA exfoliant for blackheads and pores',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Paula+Choice+BHA',
      'price': 199.00,
      'currency': 'TL',
      'ingredients': ['Salicylic Acid', 'Green Tea Extract'],
      'skinTypes': ['Oily', 'Combination', 'Sensitive'],
      'benefits': ['Blackhead Cleansing', 'Pore Opening', 'Skin Renewal'],
      'rating': 4.6,
      'reviewCount': 3200,
      'barcode': '1234567890126',
      'size': '118ml',
      'texture': 'Liquid',
      'scent': 'Fragrance-Free',
    },
    {
      'id': '5',
      'name': 'Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 50+',
      'brand': 'Neutrogena',
      'category': 'Sunscreen',
      'description': 'Oil-free, fast-absorbing sunscreen cream',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Neutrogena+Sunscreen',
      'price': 79.90,
      'currency': 'TL',
      'ingredients': ['Zinc Oxide', 'Titanium Dioxide'],
      'skinTypes': ['All Skin Types'],
      'benefits': ['UV Protection', 'Oil-Free Formula', 'Fast Absorption'],
      'rating': 4.4,
      'reviewCount': 1800,
      'barcode': '1234567890127',
      'size': '88ml',
      'texture': 'Cream',
      'scent': 'Fragrance-Free',
    },
    {
      'id': '6',
      'name': 'The Inkey List Retinol Serum',
      'brand': 'The Inkey List',
      'category': 'Anti-Aging',
      'description': 'Anti-wrinkle retinol serum',
      'imageUrl': 'https://via.placeholder.com/300x300?text=Inkey+List+Retinol',
      'price': 89.00,
      'currency': 'TL',
      'ingredients': ['Retinol', 'Squalane'],
      'skinTypes': ['Normal', 'Dry', 'Combination'],
      'benefits': ['Wrinkle Reduction', 'Skin Renewal', 'Anti-Aging'],
      'rating': 4.2,
      'reviewCount': 950,
      'barcode': '1234567890128',
      'size': '30ml',
      'texture': 'Serum',
      'scent': 'Fragrance-Free',
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
      print('🔍 Searching via Firestore...');
      // Firestore üzerinden arama yap
      final products = await FirestoreService().searchProducts(query ?? '');
      
      // Client-side filtreleme (FirestoreService basit arama yapıyor)
      final filtered = products.where((product) {
        if (category != null && product.category != category) return false;
        if (brand != null && product.brand?.toLowerCase() != brand.toLowerCase()) return false;
        // Fiyat filtresi eklenebilir
        return true;
      }).toList();

      if (filtered.isNotEmpty) {
        print('✅ Firestore returned ${filtered.length} products');
        return filtered.map(_mapToSkincareProduct).toList();
      }

      print('⚠️ Firestore returned empty, trying fallback mock data');
      return _getMockProducts(query, category, skinType, brand, minPrice, maxPrice);

    } catch (e) {
      print('❌ Firestore search error: $e');
      return _getMockProducts(query, category, skinType, brand, minPrice, maxPrice);
    }
  }

  // Helper to map Product model to local SkincareProduct
  static SkincareProduct _mapToSkincareProduct(p.Product product) {
    return SkincareProduct(
      id: product.id,
      name: product.name,
      brand: product.brand ?? '',
      category: product.category ?? '',
      description: product.description ?? '',
      imageUrl: product.imageUrl ?? '',
      price: product.price?.toDouble() ?? 0.0,
      currency: product.currency ?? 'TL',
      ingredients: product.ingredients ?? [],
      skinTypes: product.skinTypes ?? [],
      benefits: product.benefits ?? [],
      rating: product.rating?.toDouble() ?? 0.0,
      reviewCount: product.reviewCount ?? 0,
      barcode: product.barcode ?? '',
      size: product.size ?? '',
      texture: product.texture ?? '',
      scent: product.scent ?? '',
    );
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
      // Firestore'dan arama yap (SearchProducts içinde ID ile arama yok ama tümünü çekip bulabiliriz ya da getProducts kullanabiliriz) (Şimdilik ID servisi yok, search kullanalım)
      // Ancak FirestoreService'de getProducts var.
      
      // Aslında FirestoreService getProductById yok, ama ekleyebiliriz ya da getProducts().firstWhere kullanabiliriz.
      // FirestoreService'e getProductById eklemedim (doc ID ile çekmek için). 
      // Şimdilik getAll yapıp filtreleyelim (küçük veri, sorun yok)
      
      final products = await FirestoreService().getProducts();
      final product = products.firstWhere((p) => p.id == id, orElse: () => p.Product(id: '', name: ''));
      
      if (product.id.isNotEmpty) {
         return _mapToSkincareProduct(product);
      }
      
      return null; 
      
      // Note: Daha verimli olması için FirestoreService'e getProductById eklemek lazım ama şimdilik yeterli.
    } catch (e) {
      print('Product detail error: $e');
       // Fallback
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
      final product = await FirestoreService().getProductByBarcode(barcode);
      if (product != null) {
        return _mapToSkincareProduct(product);
      }

      // Fallback
      final mockProduct = _mockProducts.firstWhere(
          (p) => p['barcode'] == barcode,
          orElse: () => {},
        );
      if (mockProduct.isEmpty) return null;
      return SkincareProduct.fromJson(mockProduct);
    } catch (e) {
      print('Barcode search error: $e');
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        print('API error: ${response.statusCode}');
        // Fallback olarak mock data kullan
        return ['Cleanser', 'Serum', 'Moisturizer', 'Exfoliant', 'Sunscreen', 'Anti-Aging', 'Toner', 'Mask'];
      }
    } catch (e) {
        print('Category list error: $e');
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((brand) => brand.toString()).toList();
      } else {
        print('API error: ${response.statusCode}');
        // Fallback olarak mock data kullan
        return ['CeraVe', 'The Ordinary', 'La Roche-Posay', 'Paula\'s Choice', 'Neutrogena', 'The Inkey List', 'Olay', 'Nivea'];
      }
    } catch (e) {
        print('Brand list error: $e');
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
      print('Recommended products error: $e');
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
        print('❌ SkincareAPI connection error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ SkincareAPI connection error: $e');
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
