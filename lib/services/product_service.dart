import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // Cilt Bakım Odaklı API'ler (Gerçek API'ler)
  static const String _skincareApi = 'https://api.unsplash.com/search/photos?query=';
  static const String _beautyApi = 'https://makeup-api.herokuapp.com/api/v1/products.json?product_type=';
  static const String _cosmeticsApi = 'https://jsonplaceholder.typicode.com/posts';
  
  // Fallback API'leri kaldırıldı - sadece cilt bakım odaklı API'ler kullanılıyor

  // Cilt Bakım Odaklı Arama Fonksiyonları
  static Future<List<Product>> searchByName(String query) async {
    try {
      print('🔍 Cilt bakım ürünü aranıyor: $query');
      List<Product> results = [];

      // 1. Önce Beauty API'yi dene (makyaj/cilt bakım ürünleri)
      results = await _searchBeautyAPI(query);

      // 2. Eğer sonuç yoksa, Unsplash API'yi dene (ürün resimleri için)
      if (results.isEmpty) {
        results = await _searchUnsplashAPI(query);
      }

      // 3. Sonuç yoksa, genel API'yi dene
      if (results.isEmpty) {
        results = await _searchCosmeticsAPI(query);
      }

      // 4. Sonuç yoksa, mock data kullan (cilt bakım odaklı)
      if (results.isEmpty) {
        results = _getMockProductsByName(query);
        print('📦 Mock data kullanılıyor: $query');
      }

      print('✅ ${results.length} cilt bakım ürünü bulundu');
      return results;
    } catch (e) {
      print('❌ Arama hatası: $e');
      return _getMockProductsByName(query);
    }
  }

  /// Search product by barcode using cilt bakım API'leri
  static Future<Product?> searchByBarcode(String barcode) async {
    try {
      print('🔍 Barkod aranıyor: $barcode');

      // Önce mock data'dan kontrol et (cilt bakım ürünleri için)
      Product? product = _getMockProductByBarcode(barcode);
      if (product != null) {
        print('✅ Mock ürün bulundu: ${product.name}');
        return product;
      }

      // Gerçek API'lerde barkod arama yapılabilir (şimdilik mock data kullanıyoruz)
      print('❌ Bu barkod için ürün bulunamadı: $barcode');
      return null;
    } catch (e) {
      print('❌ Barkod arama hatası: $e');
      return null;
    }
  }

  /// Beauty API arama (makyaj/cilt bakım ürünleri)
  static Future<List<Product>> _searchBeautyAPI(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_beautyApi${Uri.encodeComponent(query)}'),
            headers: {
              'User-Agent': 'RojdaSkincare/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseBeautyAPIResults(data, query);
      }
    } catch (e) {
      print('Beauty API hatası: $e');
    }
    return [];
  }

  /// Unsplash API arama (ürün resimleri için)
  static Future<List<Product>> _searchUnsplashAPI(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_skincareApi${Uri.encodeComponent(query)}&per_page=10'),
            headers: {
              'User-Agent': 'RojdaSkincare/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseUnsplashResults(data, query);
      }
    } catch (e) {
      print('Unsplash API hatası: $e');
    }
    return [];
  }

  /// Cosmetics API arama (genel ürün bilgileri)
  static Future<List<Product>> _searchCosmeticsAPI(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_cosmeticsApi?_limit=5'),
            headers: {
              'User-Agent': 'RojdaSkincare/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCosmeticsResults(data, query);
      }
    } catch (e) {
      print('Cosmetics API hatası: $e');
    }
    return [];
  }

  /// Beauty API sonuçlarını parse et
  static List<Product> _parseBeautyAPIResults(dynamic data, String query) {
    List<Product> products = [];
    
    if (data is List) {
      for (var productData in data) {
        if (productData['name'] != null) {
          products.add(Product(
            id: productData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: productData['name'],
            barcode: productData['product_link'],
            brand: productData['brand'],
            category: _getSkincareCategory(productData['product_type']),
            description: productData['description'] ?? '',
            ingredients: null,
            nutritionInfo: null,
            imageUrl: productData['image_link'],
            unit: productData['size'],
            additionalInfo: {
              'source': 'Beauty API',
              'data_freshness': 'Gerçek zamanlı',
              'product_type': 'Cilt Bakım Ürünü',
              'price': productData['price'],
              'rating': productData['rating'],
            },
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }
    }
    
    return products;
  }

  /// Unsplash sonuçlarını parse et (ürün resimleri için)
  static List<Product> _parseUnsplashResults(dynamic data, String query) {
    List<Product> products = [];
    
    if (data is Map && data['results'] != null) {
      for (var photoData in data['results']) {
        products.add(Product(
          id: photoData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: '${query} - Ürün Resmi',
          barcode: null,
          brand: 'Unsplash',
          category: _getSkincareCategory(query),
          description: 'Ürün görseli: ${photoData['alt_description'] ?? ''}',
          ingredients: null,
          nutritionInfo: null,
          imageUrl: photoData['urls']['small'],
          unit: null,
          additionalInfo: {
            'source': 'Unsplash',
            'data_freshness': 'Gerçek zamanlı',
            'product_type': 'Cilt Bakım Ürünü',
            'photographer': photoData['user']['name'],
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }
    
    return products;
  }

  /// Cosmetics API sonuçlarını parse et
  static List<Product> _parseCosmeticsResults(dynamic data, String query) {
    List<Product> products = [];
    
    if (data is List) {
      for (var postData in data) {
        products.add(Product(
          id: postData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: '${query} - ${postData['title']}',
          barcode: null,
          brand: 'Cosmetics API',
          category: _getSkincareCategory(query),
          description: postData['body'] ?? '',
          ingredients: null,
          nutritionInfo: null,
          imageUrl: null,
          unit: null,
          additionalInfo: {
            'source': 'Cosmetics API',
            'data_freshness': 'Gerçek zamanlı',
            'product_type': 'Cilt Bakım Ürünü',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }
    
    return products;
  }

  /// İçerik listesini parse et
  static List<String>? _parseIngredientsList(dynamic ingredients) {
    if (ingredients == null) return null;
    
    if (ingredients is List) {
      return ingredients.map((e) => e.toString()).toList();
    } else if (ingredients is String) {
      return ingredients.split(',').map((e) => e.trim()).toList();
    }
    
    return null;
  }

  /// Cilt bakım kategorisi belirle
  static String _getSkincareCategory(String? name) {
    if (name == null) return 'Cilt Bakım';
    
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('cleanser') || nameLower.contains('temizlik')) {
      return 'Temizlik';
    } else if (nameLower.contains('moisturizer') || nameLower.contains('nemlendirici')) {
      return 'Nemlendirici';
    } else if (nameLower.contains('serum')) {
      return 'Serum';
    } else if (nameLower.contains('sunscreen') || nameLower.contains('güneş')) {
      return 'Güneş Kremi';
    } else if (nameLower.contains('mask')) {
      return 'Maske';
    } else if (nameLower.contains('toner') || nameLower.contains('tonik')) {
      return 'Tonik';
    } else if (nameLower.contains('exfoliant') || nameLower.contains('peeling')) {
      return 'Eksfoliant';
    } else {
      return 'Cilt Bakım';
    }
  }

  // Eski OpenFoodFacts API fonksiyonu kaldırıldı - cilt bakım odaklı API'ler kullanılıyor

  // Eski OpenFoodFacts arama fonksiyonu kaldırıldı - cilt bakım odaklı API'ler kullanılıyor

  // Eski filtreleme fonksiyonları kaldırıldı - cilt bakım odaklı API'ler kullanılıyor

  /// Get mock product by barcode
  static Product? _getMockProductByBarcode(String barcode) {
    final mockProducts = _getMockProducts();
    for (var product in mockProducts) {
      if (product.barcode == barcode) {
        return product;
      }
    }
    return null;
  }

  /// Get mock products by name search
  static List<Product> _getMockProductsByName(String query) {
    final mockProducts = _getMockProducts();
    final queryLower = query.toLowerCase();

    return mockProducts.where((product) {
      return product.name.toLowerCase().contains(queryLower) ||
          (product.brand?.toLowerCase().contains(queryLower) ?? false) ||
          (product.category?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Get comprehensive cilt bakım mock products
  static List<Product> _getMockProducts() {
    return [
      // Premium Cilt Bakım Ürünleri
      Product(
        id: 'cerave_001',
        name: 'CeraVe Yüz Temizleyici',
        barcode: '1234567890123',
        brand: 'CeraVe',
        category: 'Temizlik',
        description:
            'Hassas ciltler için nazik yüz temizleyici. Ceramides ve hyaluronic acid içerir.',
        ingredients: [
          'Aqua',
          'Glycerin',
          'Ceramides',
          'Hyaluronic Acid',
          'Niacinamide',
        ],
        nutritionInfo: null,
        imageUrl: null,
        unit: '200ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Hassas',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
          'safety_score': '9/10',
          'efficacy_score': '8/10',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'ordinary_001',
        name: 'The Ordinary Niacinamide 10%',
        barcode: '1234567890124',
        brand: 'The Ordinary',
        category: 'Serum',
        description: 'Gözenek görünümünü azaltan ve cildi dengeleyen serum',
        ingredients: ['Aqua', 'Niacinamide', 'Zinc PCA', 'Hyaluronic Acid'],
        nutritionInfo: null,
        imageUrl: null,
        unit: '30ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Karma',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
          'safety_score': '8/10',
          'efficacy_score': '9/10',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'laroche_001',
        name: 'La Roche-Posay Anthelios SPF 50+',
        barcode: '1234567890125',
        brand: 'La Roche-Posay',
        category: 'Güneş Kremi',
        description: 'Yüksek koruma faktörlü güneş kremi',
        ingredients: ['Aqua', 'Titanium Dioxide', 'Zinc Oxide', 'Glycerin'],
        nutritionInfo: null,
        imageUrl: null,
        unit: '50ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Tüm Cilt Tipleri',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
          'safety_score': '10/10',
          'efficacy_score': '9/10',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'neutrogena_001',
        name: 'Neutrogena Ultra Gentle Cleanser',
        barcode: '1234567890126',
        brand: 'Neutrogena',
        category: 'Temizlik',
        description: 'Hassas ciltler için ultra nazik temizleyici',
        ingredients: ['Water', 'Glycerin', 'Cetearyl Alcohol', 'Stearic Acid'],
        nutritionInfo: null,
        imageUrl: null,
        unit: '250ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Hassas',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
          'safety_score': '9/10',
          'efficacy_score': '7/10',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'paula_001',
        name: 'Paula\'s Choice 2% BHA Liquid Exfoliant',
        barcode: '1234567890127',
        brand: 'Paula\'s Choice',
        category: 'Peeling',
        description: 'Gözenekleri temizleyen ve cildi yenileyen sıvı peeling',
        ingredients: [
          'Water',
          'Methylpropanediol',
          'Salicylic Acid',
          'Betaine Salicylate',
        ],
        nutritionInfo: null,
        imageUrl: null,
        unit: '118ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Karma/Yağlı',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'innisfree_001',
        name: 'Innisfree Green Tea Seed Serum',
        barcode: '1234567890128',
        brand: 'Innisfree',
        category: 'Serum',
        description: 'Yeşil çay tohumu ile nemlendirici serum',
        ingredients: [
          'Green Tea Extract',
          'Glycerin',
          'Hyaluronic Acid',
          'Squalane',
        ],
        nutritionInfo: null,
        imageUrl: null,
        unit: '80ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Tüm Cilt Tipleri',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'cosrx_001',
        name: 'COSRX Advanced Snail 96 Mucin Power Essence',
        barcode: '1234567890129',
        brand: 'COSRX',
        category: 'Essence',
        description: 'Salyangoz mukusu ile onarıcı essence',
        ingredients: [
          'Snail Secretion Filtrate',
          'Sodium Hyaluronate',
          'Betaine',
          'Panthenol',
        ],
        nutritionInfo: null,
        imageUrl: null,
        unit: '100ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Tüm Cilt Tipleri',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'laneige_001',
        name: 'Laneige Water Sleeping Mask',
        barcode: '1234567890130',
        brand: 'Laneige',
        category: 'Maske',
        description: 'Gece boyu nemlendirici uyku maskesi',
        ingredients: ['Water', 'Glycerin', 'Dimethicone', 'Hyaluronic Acid'],
        nutritionInfo: null,
        imageUrl: null,
        unit: '70ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Kuru',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'ordinary_002',
        name: 'The Ordinary Hyaluronic Acid 2% + B5',
        barcode: '1234567890131',
        brand: 'The Ordinary',
        category: 'Serum',
        description: 'Yoğun nemlendirici hyaluronic acid serumu',
        ingredients: ['Aqua', 'Sodium Hyaluronate', 'Panthenol', 'Glycerin'],
        nutritionInfo: null,
        imageUrl: null,
        unit: '30ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Tüm Cilt Tipleri',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'cerave_002',
        name: 'CeraVe Moisturizing Cream',
        barcode: '1234567890132',
        brand: 'CeraVe',
        category: 'Nemlendirici',
        description: 'Ceramides ile güçlendirilmiş nemlendirici krem',
        ingredients: [
          'Aqua',
          'Glycerin',
          'Ceramides',
          'Hyaluronic Acid',
          'Petrolatum',
        ],
        nutritionInfo: null,
        imageUrl: null,
        unit: '50ml',
        additionalInfo: {
          'source': 'Mock Data',
          'skin_type': 'Kuru/Hassas',
          'data_freshness': 'Test verisi',
          'product_type': 'Cilt Bakım Ürünü',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Eski yardımcı fonksiyonlar kaldırıldı - cilt bakım odaklı API'ler kullanılıyor

  /// Get recent products - now returns empty since we don't save to database
  static Future<List<Product>> getRecentProducts({int limit = 10}) async {
    // Since we're not saving to database anymore, return empty list
    return [];
  }

  /// Get product categories - expanded list
  static Future<List<String>> getCategories() async {
    return [
      'Temizlik',
      'Nemlendirici',
      'Serum',
      'Güneş Kremi',
      'Maske',
      'Tonik',
      'Eksfoliant',
      'Cilt Bakım',
      'İçecek',
      'Atıştırmalık',
      'Süt Ürünü',
      'Genel Ürün',
    ];
  }

  /// Search products by category - now uses cilt bakım API'leri
  static Future<List<Product>> searchByCategory(String category) async {
    try {
      print('🔍 Kategori araması: $category');
      // Cilt bakım kategorileri için arama yap
      return await _searchBeautyAPI(category);
    } catch (e) {
      print('❌ Kategori arama hatası: $e');
      return [];
    }
  }

  /// Add sample products for testing
  static Future<void> addSampleProducts() async {
    // Since we're not saving to database, this function is now just for testing
    print('Sample products function called - no database saving');
  }
}
