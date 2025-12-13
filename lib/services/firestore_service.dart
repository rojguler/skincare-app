import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  /// Tüm ürünleri getir
  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // ID'yi doc.id'den alabiliriz veya data içinden
        data['id'] = doc.id; 
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching products: $e');
      return [];
    }
  }

  /// İsim, marka veya kategoriye göre ürün ara
  Future<List<Product>> searchProducts(String query) async {
    try {
      final queryLower = query.toLowerCase();
      
      // Firestore'da tam metin arama yok, bu yüzden tümünü çekip filtreleyeceğiz
      // Veya basit startsWith araması yapabiliriz ama kapsamlı arama için client-side filtreleme daha iyi (küçük veri setleri için)
      final allProducts = await getProducts();
      
      return allProducts.where((product) {
        final nameMatch = product.name.toLowerCase().contains(queryLower);
        final brandMatch = product.brand?.toLowerCase().contains(queryLower) ?? false;
        final categoryMatch = product.category?.toLowerCase().contains(queryLower) ?? false;
        final descMatch = product.description?.toLowerCase().contains(queryLower) ?? false;
        
        return nameMatch || brandMatch || categoryMatch || descMatch;
      }).toList();
    } catch (e) {
      print('❌ Error searching products: $e');
      return [];
    }
  }

  /// Barkoda göre ürün getir
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Error finding product by barcode: $e');
      return null;
    }
  }

  /// Initial verileri yükle (Sadece veritabanı boşsa çalışır veya force=true ise)
  Future<void> seedInitialData({bool force = false}) async {
    try {
      // Check if Firestore database exists
      try {
        final snapshot = await _firestore.collection(_collection).limit(1).get();
        
        // Eğer veritabanı boş değilse ve zorlama yoksa çık
        if (snapshot.docs.isNotEmpty && !force) {
          print('ℹ️ Firestore already has data, skipping seed.');
          return;
        }
      } catch (e) {
        // Firestore database doesn't exist or not accessible
        if (e.toString().contains('NOT_FOUND') || e.toString().contains('does not exist')) {
          print('⚠️ Firestore database not found. Please create it in Firebase Console.');
          print('   Visit: https://console.cloud.google.com/datastore/setup?project=cilt-bakim-takip');
          return;
        }
        rethrow;
      }

      print('🌱 Seeding initial data to Firestore...');
      var batch = _firestore.batch();
      
      // 1. Manuel seçilmiş kaliteli ürünleri ekle
      List<Product> allProductsToSeed = [..._initialProducts];

      // 2. Otomatik olarak yüzlerce ürün üret (500 adet!)
      print('🚀 Generating massive dataset...');
      final generatedProducts = _generateMassiveMockData(count: 500);
      allProductsToSeed.addAll(generatedProducts);

      print('📦 Total products to seed: ${allProductsToSeed.length}');

      // Firestore batch limit is 500.
      // batch is already created at line 85
      int count = 0;
      int totalSaved = 0;

      for (var product in allProductsToSeed) {
        final docRef = _firestore.collection(_collection).doc(); 
        batch.set(docRef, product.toJson());
        count++;

        if (count >= 400) {
           try {
             await batch.commit();
             totalSaved += count;
             print('Saved chunk of $count products (Total: $totalSaved)...');
           } catch (e) {
             if (e.toString().contains('NOT_FOUND') || e.toString().contains('does not exist')) {
               print('⚠️ Firestore database not found. Skipping seed.');
               return;
             }
             print('❌ Error committing batch: $e');
             return;
           }
           batch = _firestore.batch(); // Re-create batch (Fix)
           count = 0;
        }
      }

      if (count > 0) {
        try {
          await batch.commit();
          totalSaved += count;
        } catch (e) {
          if (e.toString().contains('NOT_FOUND') || e.toString().contains('does not exist')) {
            print('⚠️ Firestore database not found. Skipping seed.');
            return;
          }
          print('❌ Error committing final batch: $e');
          return;
        }
      }

      print('✅ Seeding completed! Added $totalSaved products.');
    } catch (e) {
      if (e.toString().contains('NOT_FOUND') || e.toString().contains('does not exist')) {
        print('⚠️ Firestore database not found. App will work with local storage only.');
        print('   To enable Firestore, visit: https://console.cloud.google.com/datastore/setup?project=cilt-bakim-takip');
      } else {
        print('❌ Error during seeding: $e');
      }
    }
  }

  /// Algoritmik olarak çok sayıda mantıklı ürün verisi üretir
  List<Product> _generateMassiveMockData({int count = 100}) {
    final List<Product> products = [];
    final rand = DateTime.now().millisecondsSinceEpoch;
    
    final brands = [
      'Neutrogena', 'Olay', 'Nivea', 'Garnier', 'L\'Oreal', 'Aveeno', 'Cetaphil', 'Eucerin', 
      'Sebamed', 'Bioderma', 'Avene', 'La Mer', 'Sisley', 'Clarins', 'Shiseido', 
      'Missha', 'Etude House', 'Innisfree', 'TonyMoly', 'Holika Holika', 'Nature Republic',
      'Simple', 'Bioré', 'Clean & Clear', 'Acne.org', 'Proactiv', 'Murad', 'Dermalogica',
      'Drunk Elephant', 'Tatcha', 'Sunday Riley', 'Fresh', 'Kiehl\'s', 'Vichy', 'Caudalie', 
      'SkinCeuticals', 'Estée Lauder', 'Clinique', 'Laneige', 'Glow Recipe', 'Supergoop!',
      'Dr. Jart+', 'Mario Badescu', 'First Aid Beauty', 'Elemis', 'SK-II', 'Augustinus Bader'
    ];
    
    // --- HYBRID IMAGE SEEDING STRATEGY ---
    // A curated list of ~30 High-Quality Real Product Images to rotate through.
    // This ensures every product looks authentic (no random cats/low-res placeholders).
    final List<String> realHighQualityImages = [
      // Cleansers / Bottles
      'https://images-na.ssl-images-amazon.com/images/P/B01N69KO1S.01._SCLZZZZZZZ_.jpg', // CeraVe Foaming
      'https://cdn.dummyjson.com/product-images/skin-care/attitude-super-leaves-hand-soap/1.webp', // Attitude Pump Bottle
      'https://cdn.dummyjson.com/product-images/skin-care/olay-ultra-moisture-shea-butter-body-wash/1.webp', // Olay Bottle
      'https://images-na.ssl-images-amazon.com/images/P/B002CA6IJE.01._SCLZZZZZZZ_.jpg', // Bioderma
      'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp', // CK Bottle (Looks like toner)
      
      // Serums / Droppers / Small Bottles
      'https://images-na.ssl-images-amazon.com/images/P/B01M3MQ91K.01._SCLZZZZZZZ_.jpg', // Ordinary Niacinamide
      'https://static-assets.glossier.com/production/spree/images/attachments/000/000/726/portrait_normal/PST_Carousel_02-compressor.jpg', // Glossier Skin Tint
      'https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/1.webp', // Chanel Black Bottle
      'https://images-na.ssl-images-amazon.com/images/P/B07C5SS6YD.01._SCLZZZZZZZ_.jpg', // Paula's Choice
      'https://images-na.ssl-images-amazon.com/images/P/B00PBX3L7K.01._SCLZZZZZZZ_.jpg', // Cosrx Snail
      'https://images-na.ssl-images-amazon.com/images/P/B085CD7Y5V.01._SCLZZZZZZZ_.jpg', // Anua Toner
      
      // Creams / Jars / Tubes
      'https://images-na.ssl-images-amazon.com/images/P/B01N9SPQHQ.01._SCLZZZZZZZ_.jpg', // La Roche Double Repair
      'https://cdn.dummyjson.com/product-images/beauty/powder-canister/1.webp', // Powder Jar (Looks like cream)
      'https://static-assets.glossier.com/production/spree/images/attachments/000/001/631/portrait_normal/SC_Carousel_1_copy_2.jpg', // Glossier Pot
      'https://cdn.dummyjson.com/product-images/skin-care/vaseline-men-body-and-face-lotion/1.webp', // Vaseline Tube
      'https://images-na.ssl-images-amazon.com/images/P/B00142DXV6.01._SCLZZZZZZZ_.jpg', // Neutrogena Tube
      'https://images-na.ssl-images-amazon.com/images/P/B09JGJ2F2Q.01._SCLZZZZZZZ_.jpg', // Beauty of Joseon Tube
      'https://images-na.ssl-images-amazon.com/images/P/B08D3L4BQP.01._SCLZZZZZZZ_.jpg', // Isntree Sun Gel
      'https://static-assets.glossier.com/production/spree/images/attachments/000/001/241/portrait_normal/CP_PDP_02.jpg', // Cloud Paint Tube
      
      // Other high quality assets
      'https://cdn.dummyjson.com/product-images/fragrances/dior-j\'adore/1.webp', // Dior Bottle
      'https://cdn.dummyjson.com/product-images/fragrances/gucci-bloom-eau-de/1.webp', // Gucci Bottle
    ];
    
    final categories = ['Cleanser', 'Moisturizer', 'Serum', 'Toner', 'Sunscreen', 'Mask', 'Exfoliant', 'Eye Cream'];
    
    final adjectives = ['Hydrating', 'Soothing', 'Brightening', 'Clarifying', 'Anti-Aging', 'Gentle', 'Deep', 'Intense', 'Daily', 'Night'];
    
    final ingredientsList = ['Hyaluronic Acid', 'Vitamin C', 'Retinol', 'Salicylic Acid', 'Niacinamide', 'Aloe Vera', 'Centella', 'Snail Mucin', 'Tea Tree', 'Ceramides'];

    for (int i = 0; i < count; i++) {
        final brand = brands[i % brands.length];
        final category = categories[(i + 3) % categories.length];
        final adj = adjectives[(i * 7) % adjectives.length];
        final mainIngredient = ingredientsList[(i * 5) % ingredientsList.length];
        
        final name = '$brand $adj $category with $mainIngredient';
        
        // Hybrid Strategy: Pick a random HIGH QUALITY image from our curated pool
        // This ensures the app looks professional with real photos, even if they repeat.
        // We use the product index 'i' to deterministically pick an image so it's stable.
        final imageUrl = realHighQualityImages[i % realHighQualityImages.length];

        products.add(Product(
          id: 'gen_$i', // Deterministic ID to allow overwriting/updating
          name: name,
          brand: brand,
          category: category,
          description: 'A $adj $category formulated with high quality $mainIngredient for best results.',
          imageUrl: imageUrl,
          price: (50 + (i % 20) * 15).toDouble(),
          currency: 'TL',
          ingredients: [mainIngredient, 'Water', 'Glycerin'],
          skinTypes: ['All Skin Types'],
          benefits: [adj, 'Moisturizing'],
          rating: 4.0 + (i % 10) / 10,
          reviewCount: (i * 15) + 50,
          barcode: '869${(1000000000 + i).toString()}',
          size: '${(i % 5 + 1) * 50}ml',
          texture: i % 2 == 0 ? 'Cream' : 'Gel',
          scent: 'Fragrance-Free',
          updatedAt: DateTime.now(),
        ));
    }
    
    return products;
  }

  // Zenginleştirilmiş Başlangıç Verisi
  final List<Product> _initialProducts = [
    // --- Mevcut Mock Veriler ---
    Product(
      id: '1',
      name: 'CeraVe Foaming Facial Cleanser',
      brand: 'CeraVe',
      category: 'Cleanser',
      description: 'Foaming facial cleanser for oily and combination skin. Contains ceramides and hyaluronic acid.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01N69KO1S.01._SCLZZZZZZZ_.jpg',
      price: 89.90,
      currency: 'TL',
      ingredients: ['Ceramides', 'Hyaluronic Acid', 'Niacinamide'],
      skinTypes: ['Oily', 'Combination'],
      benefits: ['Pore Cleansing', 'Moisture Balance', 'Skin Barrier'],
      rating: 4.5,
      reviewCount: 1250,
      barcode: '1234567890123',
      size: '236ml',
      texture: 'Foaming',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'The Ordinary Niacinamide 10% + Zinc 1%',
      brand: 'The Ordinary',
      category: 'Serum',
      description: 'High-strength vitamin and mineral blemish formula.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01M3MQ91K.01._SCLZZZZZZZ_.jpg',
      price: 45.00,
      currency: 'TL',
      ingredients: ['Niacinamide', 'Zinc PCA'],
      skinTypes: ['Oily', 'Combination', 'Sensitive'],
      benefits: ['Pore Minimizing', 'Oil Control', 'Skin Balancing'],
      rating: 4.3,
      reviewCount: 890,
      barcode: '1234567890124',
      size: '30ml',
      texture: 'Liquid',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'La Roche-Posay Toleriane Double Repair Moisturizer',
      brand: 'La Roche-Posay',
      category: 'Moisturizer',
      description: 'Oil-free face moisturizer for sensitive skin. Works in two ways: checks moisture & helps restore skin barrier.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01N9SPQHQ.01._SCLZZZZZZZ_.jpg',
      price: 129.90,
      currency: 'TL',
      ingredients: ['Ceramides', 'Niacinamide', 'Thermal Water'],
      skinTypes: ['Sensitive', 'Dry', 'Normal'],
      benefits: ['Skin Repair', 'Moisturizing', 'Barrier Strengthening'],
      rating: 4.7,
      reviewCount: 2100,
      barcode: '1234567890125',
      size: '75ml',
      texture: 'Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '4',
      name: 'Paula\'s Choice 2% BHA Liquid Exfoliant',
      brand: 'Paula\'s Choice',
      category: 'Exfoliant',
      description: 'Daily leave-on exfoliant with salicylic acid to sweep away dead skin cells & unclog pores.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B07C5SS6YD.01._SCLZZZZZZZ_.jpg',
      price: 199.00,
      currency: 'TL',
      ingredients: ['Salicylic Acid', 'Green Tea Extract'],
      skinTypes: ['Oily', 'Combination', 'Sensitive'],
      benefits: ['Blackhead Cleansing', 'Pore Opening', 'Skin Renewal'],
      rating: 4.6,
      reviewCount: 3200,
      barcode: '1234567890126',
      size: '118ml',
      texture: 'Liquid',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 50+',
      brand: 'Neutrogena',
      category: 'Sunscreen',
      description: 'Fast-absorbing, non-oily sunscreen that feels clean on skin.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B00142DXV6.01._SCLZZZZZZZ_.jpg',
      price: 79.90,
      currency: 'TL',
      ingredients: ['Zinc Oxide', 'Titanium Dioxide'],
      skinTypes: ['All Skin Types'],
      benefits: ['UV Protection', 'Oil-Free Formula', 'Fast Absorption'],
      rating: 4.4,
      reviewCount: 1800,
      barcode: '1234567890127',
      size: '88ml',
      texture: 'Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),

    // --- YENİ EKLENEN ÜRÜNLER (KORE & POPÜLER) ---
    Product(
      id: '6',
      name: 'Bioderma Sensibio H2O Micellar Water',
      brand: 'Bioderma',
      category: 'Cleanser',
      description: 'Dermatological micellar water for sensitive skin. Cleanses, removes makeup and soothes.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B002CA6IJE.01._SCLZZZZZZZ_.jpg',
      price: 150.00,
      currency: 'TL',
      ingredients: ['Water', 'PEG-6 Caprylic/Capric Glycerides', 'Fructooligosaccharides'],
      skinTypes: ['Sensitive', 'All Skin Types'],
      benefits: ['Makeup Removal', 'Soothing', 'No Rinse'],
      rating: 4.8,
      reviewCount: 5400,
      barcode: '3401345935571',
      size: '500ml',
      texture: 'Water',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '7',
      name: 'Cosrx Advanced Snail 96 Mucin Power Essence',
      brand: 'Cosrx',
      category: 'Essence',
      description: 'Light-weight essence which absorbs into skin fast to give skin a natural glow from the inside.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B00PBX3L7K.01._SCLZZZZZZZ_.jpg',
      price: 220.00,
      currency: 'TL',
      ingredients: ['Snail Secretion Filtrate', 'Sodium Hyaluronate'],
      skinTypes: ['All Skin Types', 'Dry', 'Dull'],
      benefits: ['Hydration', 'Repair', 'Glow'],
      rating: 4.6,
      reviewCount: 3100,
      barcode: '8809419530097',
      size: '100ml',
      texture: 'Gel-like',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '8',
      name: 'Isntree Hyaluronic Acid Watery Sun Gel SPF50+',
      brand: 'Isntree',
      category: 'Sunscreen',
      description: 'Moisturizing chemical sunscreen that leaves no white cast.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B08D3L4BQP.01._SCLZZZZZZZ_.jpg',
      price: 280.00,
      currency: 'TL',
      ingredients: ['8 types of Hyaluronic Acid', 'Centella Asiatica'],
      skinTypes: ['Dry', 'Combination', 'Sensitive'],
      benefits: ['UV Protection', 'Moisturizing', 'No White Cast'],
      rating: 4.7,
      reviewCount: 1500,
      barcode: '8809686383437',
      size: '50ml',
      texture: 'Lotion',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '9',
      name: 'Beauty of Joseon Relief Sun: Rice + Probiotics',
      brand: 'Beauty of Joseon',
      category: 'Sunscreen',
      description: 'Organic sunscreen equipped with calming and brightening ingredients.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B09JGJ2F2Q.01._SCLZZZZZZZ_.jpg',
      price: 290.00,
      currency: 'TL',
      ingredients: ['Rice Extract', 'Grain Ferment Extracts'],
      skinTypes: ['Sensitive', 'All Skin Types'],
      benefits: ['UV Protection', 'Calming', 'Brightening'],
      rating: 4.8,
      reviewCount: 4200,
      barcode: '8809738312674',
      size: '50ml',
      texture: 'Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '10',
      name: 'Anua Heartleaf 77% Soothing Toner',
      brand: 'Anua',
      category: 'Toner',
      description: 'Highly moisturizing toner infused with 77% heartleaf extract to soothe sensitive skin.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B085CD7Y5V.01._SCLZZZZZZZ_.jpg',
      price: 210.00,
      currency: 'TL',
      ingredients: ['Heartleaf Extract', 'Centella Asiatica'],
      skinTypes: ['Sensitive', 'Acne-Prone'],
      benefits: ['Soothing', 'Redness Reduction', 'Hydration'],
      rating: 4.5,
      reviewCount: 2000,
      barcode: '8809640730482',
      size: '250ml',
      texture: 'Water',
      scent: 'Herbal',
      updatedAt: DateTime.now(),
    ),

    // --- GENİŞLETİLMİŞ LİSTE (PREMIUM & POPÜLER) ---
    Product(
      id: '11',
      name: 'Kiehl\'s Ultra Facial Cream',
      brand: 'Kiehl\'s',
      category: 'Moisturizer',
      description: 'The #1 daily facial cream for 24-hour hydration and softer, smoother skin.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01N9SPQHQ.01._SCLZZZZZZZ_.jpg', // Reusing valid La Roche image
      price: 850.00,
      currency: 'TL',
      ingredients: ['Glacial Glycoprotein', 'Squalane'],
      skinTypes: ['All Skin Types'],
      benefits: ['24-Hour Hydration', 'Barrier Repair', 'Softening'],
      rating: 4.8,
      reviewCount: 8500,
      barcode: '3605970360756',
      size: '50ml',
      texture: 'Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '12',
      name: 'Vichy Minéral 89 Shim',
      brand: 'Vichy',
      category: 'Serum',
      description: 'Hyaluronic acid booster that strengthens skin barrier against daily aggressors.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01M3MQ91K.01._SCLZZZZZZZ_.jpg', // Reusing Ordinary image
      price: 550.00,
      currency: 'TL',
      ingredients: ['Vichy Volcanic Water', 'Hyaluronic Acid'],
      skinTypes: ['All Skin Types'],
      benefits: ['Hydration', 'Plumping', 'Strengthening'],
      rating: 4.7,
      reviewCount: 4200,
      barcode: '3337875543248',
      size: '50ml',
      texture: 'Gel',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '13',
      name: 'Caudalie Vinoperfect Radiance Serum',
      brand: 'Caudalie',
      category: 'Serum',
      description: 'Cult favorite brightening serum that reduces dark spots and enhances glow.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B00PBX3L7K.01._SCLZZZZZZZ_.jpg', // Reusing Cosrx image
      price: 1200.00,
      currency: 'TL',
      ingredients: ['Viniferine', 'Olive Squalane'],
      skinTypes: ['All Skin Types'],
      benefits: ['Dark Spot Correction', 'Brightening', 'Even Skin Tone'],
      rating: 4.6,
      reviewCount: 3100,
      barcode: '3522930001077',
      size: '30ml',
      texture: 'Milky Serum',
      scent: 'Green Notes',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '14',
      name: 'SkinCeuticals C E Ferulic',
      brand: 'SkinCeuticals',
      category: 'Serum',
      description: 'A patented daytime vitamin C serum that delivers advanced environmental protection.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/000/726/portrait_normal/PST_Carousel_02-compressor.jpg',
      price: 3500.00,
      currency: 'TL',
      ingredients: ['15% Vitamin C', '1% Vitamin E', '0.5% Ferulic Acid'],
      skinTypes: ['Normal', 'Dry', 'Sensitive'],
      benefits: ['Anti-Aging', 'Environmental Protection', 'Brightening'],
      rating: 4.9,
      reviewCount: 5000,
      barcode: '635494263008',
      size: '30ml',
      texture: 'Liquid',
      scent: 'Distinctive',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '15',
      name: 'La Roche-Posay Effaclar Duo+',
      brand: 'La Roche-Posay',
      category: 'Moisturizer',
      description: 'Dual action acne treatment that reduces pimples and prevents recurrence.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/skin-care/vaseline-men-body-and-face-lotion/1.webp',
      price: 450.00,
      currency: 'TL',
      ingredients: ['Niacinamide', 'LHA', 'Salicylic Acid', 'Procerad'],
      skinTypes: ['Oily', 'Acne-Prone'],
      benefits: ['Anti-Blemish', 'Anti-Marks', 'Matte Finish'],
      rating: 4.5,
      reviewCount: 6700,
      barcode: '3337875598071',
      size: '40ml',
      texture: 'Gel-Cream',
      scent: 'Fresh',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '16',
      name: 'Estée Lauder Advanced Night Repair',
      brand: 'Estée Lauder',
      category: 'Serum',
      description: 'Deep-penetrating serum that reduces the look of multiple signs of aging.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/1.webp',
      price: 2800.00,
      currency: 'TL',
      ingredients: ['Bifida Ferment Lysate', 'Hyaluronic Acid'],
      skinTypes: ['All Skin Types'],
      benefits: ['Anti-Aging', 'Radiance', 'Hydration'],
      rating: 4.8,
      reviewCount: 15000,
      barcode: '887167485488',
      size: '50ml',
      texture: 'Serum',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '17',
      name: 'Drunk Elephant Protini Polypeptide Cream',
      brand: 'Drunk Elephant',
      category: 'Moisturizer',
      description: 'Protein moisturizer that improves the appearance of skin\'s tone, texture, and firmness.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/001/631/portrait_normal/SC_Carousel_1_copy_2.jpg',
      price: 1800.00,
      currency: 'TL',
      ingredients: ['Signal Peptides', 'Pygmy Waterlily'],
      skinTypes: ['Normal', 'Dry', 'Original', 'Combination'],
      benefits: ['Firming', 'Strengthening', 'Restoring'],
      rating: 4.4,
      reviewCount: 4100,
      barcode: '856556004652',
      size: '50ml',
      texture: 'Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '18',
      name: 'Laneige Lip Sleeping Mask Berry',
      brand: 'Laneige',
      category: 'Mask',
      description: 'A leave-on lip mask that soothes and moisturizes for smoother, more supple lips.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/001/631/portrait_normal/SC_Carousel_1_copy_2.jpg',
      price: 490.00,
      currency: 'TL',
      ingredients: ['Berry Fruit Complex', 'Vitamin C', 'Coconut Oil'],
      skinTypes: ['All Skin Types'],
      benefits: ['Hydration', 'Softening', 'Antioxidant'],
      rating: 4.7,
      reviewCount: 9500,
      barcode: '8809608300262',
      size: '20g',
      texture: 'Balm',
      scent: 'Berry',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '19',
      name: 'Glow Recipe Watermelon Glow Niacinamide Dew Drops',
      brand: 'Glow Recipe',
      category: 'Serum',
      description: 'Highlighting skincare serum for an instant dewy glow over time.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/000/726/portrait_normal/PST_Carousel_02-compressor.jpg',
      price: 950.00,
      currency: 'TL',
      ingredients: ['Niacinamide', 'Watermelon', 'Hyaluronic Acid'],
      skinTypes: ['All Skin Types'],
      benefits: ['Glow', 'Brightening', 'Hydration'],
      rating: 4.6,
      reviewCount: 3800,
      barcode: '810052960686',
      size: '40ml',
      texture: 'Gel',
      scent: 'Watermelon',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '20',
      name: 'Supergoop! Unseen Sunscreen SPF 40',
      brand: 'Supergoop!',
      category: 'Sunscreen',
      description: 'The original, totally invisible, weightless, scentless sunscreen.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/001/241/portrait_normal/CP_PDP_02.jpg',
      price: 1100.00,
      currency: 'TL',
      ingredients: ['Avobenzone', 'Homosalate', 'Meadowfoam Seed'],
      skinTypes: ['All Skin Types'],
      benefits: ['Invisible Protection', 'Makeup Primer', 'Blue Light Protection'],
      rating: 4.6,
      reviewCount: 5200,
      barcode: '816218022736',
      size: '50ml',
      texture: 'Gel',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '21',
      name: 'Clinique Take The Day Off Cleansing Balm',
      brand: 'Clinique',
      category: 'Cleanser',
      description: 'Lightweight makeup remover that quickly dissolves tenacious eye and face makeups.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/powder-canister/1.webp',
      price: 890.00,
      currency: 'TL',
      ingredients: ['Safflower Seed Oil'],
      skinTypes: ['All Skin Types'],
      benefits: ['Makeup Removal', 'Non-drying', 'Ophthalmologist Tested'],
      rating: 4.8,
      reviewCount: 7800,
      barcode: '020714215552',
      size: '125ml',
      texture: 'Balm-to-Oil',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '22',
      name: 'Tatcha The Water Cream',
      brand: 'Tatcha',
      category: 'Moisturizer',
      description: 'Oil-free anti-aging water cream that releases a burst of skin-improving nutrients.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/001/631/portrait_normal/SC_Carousel_1_copy_2.jpg',
      price: 1900.00,
      currency: 'TL',
      ingredients: ['Japanese Wild Rose', 'Japanese Leopard Lily'],
      skinTypes: ['Oily', 'Combination', 'Normal'],
      benefits: ['Pore Minimizing', 'Oil Control', 'Hydration'],
      rating: 4.5,
      reviewCount: 3500,
      barcode: '653341147754',
      size: '50ml',
      texture: 'Water Cream',
      scent: 'Fresh',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '23',
      name: 'Fresh Soy Face Cleanser',
      brand: 'Fresh',
      category: 'Cleanser',
      description: 'pH-balanced face wash with soy proteins that deeply cleanses pores.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/skin-care/attitude-super-leaves-hand-soap/1.webp',
      price: 950.00,
      currency: 'TL',
      ingredients: ['Soy Proteins', 'Cucumber Extract', 'Rosewater'],
      skinTypes: ['All Skin Types'],
      benefits: ['Gentle Cleansing', 'Soothing', 'Makeup Removal'],
      rating: 4.6,
      reviewCount: 6500,
      barcode: '809280103756',
      size: '150ml',
      texture: 'Gel',
      scent: 'Cucumber & Rose',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '24',
      name: 'Sunday Riley Good Genes All-In-One Lactic Acid Treatment',
      brand: 'Sunday Riley',
      category: 'Exfoliant',
      description: 'Lactic acid treatment that exfoliates pore-clogging dead skin cells.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp',
      price: 2400.00,
      currency: 'TL',
      ingredients: ['Purified Lactic Acid', 'Licorice', 'Lemongrass'],
      skinTypes: ['Normal', 'Dry', 'Combination', 'Oily'],
      benefits: ['Exfoliation', 'Radiance', 'Plumping'],
      rating: 4.5,
      reviewCount: 4800,
      barcode: '817494010191',
      size: '30ml',
      texture: 'Serum',
      scent: 'Citrus',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '25',
      name: 'Dr. Jart+ Cicapair Tiger Grass Color Correcting Treatment',
      brand: 'Dr. Jart+',
      category: 'Treatment',
      description: 'Green-to-beige color correcting treatment that corrects redness and protects skin.',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/P/B01N9SPQHQ.01._SCLZZZZZZZ_.jpg',
      price: 1300.00,
      currency: 'TL',
      ingredients: ['Centella Asiatica Complex', 'Minerals'],
      skinTypes: ['Sensitive', 'Redness-Prone'],
      benefits: ['Redness Neutralization', 'Soothing', 'SPF 30'],
      rating: 4.3,
      reviewCount: 3900,
      barcode: '8809535805244',
      size: '50ml',
      texture: 'Cream',
      scent: 'Herbal',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '26',
      name: 'Mario Badescu Drying Lotion',
      brand: 'Mario Badescu',
      category: 'Treatment',
      description: 'Legendary on-the-spot solution for surface blemishes.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/000/726/portrait_normal/PST_Carousel_02-compressor.jpg',
      price: 450.00,
      currency: 'TL',
      ingredients: ['Salicylic Acid', 'Sulfur', 'Zinc Oxide', 'Calamine'],
      skinTypes: ['All Skin Types'],
      benefits: ['Acne Spot Treatment', 'Fast Acting'],
      rating: 4.4,
      reviewCount: 5600,
      barcode: '785364130088',
      size: '29ml',
      texture: 'Bi-phase Liquid',
      scent: 'Medicinal',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '27',
      name: 'First Aid Beauty Ultra Repair Cream',
      brand: 'First Aid Beauty',
      category: 'Moisturizer',
      description: 'Fast-absorbing, rich moisturizer that provides instant and long-term hydration for dry, distressed skin.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/beauty/powder-canister/1.webp',
      price: 850.00,
      currency: 'TL',
      ingredients: ['Colloidal Oatmeal', 'Shea Butter'],
      skinTypes: ['Dry', 'Sensitive', 'Eczema-Prone'],
      benefits: ['Intense Hydration', 'Soothing', 'Barrier Repair'],
      rating: 4.8,
      reviewCount: 9200,
      barcode: '851614002816',
      size: '170g',
      texture: 'Whipped Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '28',
      name: 'Elemis Pro-Collagen Cleansing Balm',
      brand: 'Elemis',
      category: 'Cleanser',
      description: 'Nourishing cleansing balm that melts away makeup, daily pollutants and impurities.',
      imageUrl: 'https://static-assets.glossier.com/production/spree/images/attachments/000/001/631/portrait_normal/SC_Carousel_1_copy_2.jpg',
      price: 1600.00,
      currency: 'TL',
      ingredients: ['Padina Pavonica', 'Elderberry Oil', 'Starflower Oil'],
      skinTypes: ['Normal', 'Dry', 'Anti-Aging'],
      benefits: ['Deep Cleansing', 'Softening', 'Nourishing'],
      rating: 4.8,
      reviewCount: 4500,
      barcode: '641628001701',
      size: '100g',
      texture: 'Balm',
      scent: 'Spa-like',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '29',
      name: 'SK-II Facial Treatment Essence',
      brand: 'SK-II',
      category: 'Essence',
      description: 'Powerful treatment essence dubbed "Miracle Water" that improves skin texture and clarity.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/1.webp',
      price: 4500.00,
      currency: 'TL',
      ingredients: ['Pitera™ (Galactomyces Ferment Filtrate)'],
      skinTypes: ['All Skin Types'],
      benefits: ['Crystal Clear Skin', 'Texture Improvement', 'Radiance'],
      rating: 4.7,
      reviewCount: 3800,
      barcode: '4979006067571',
      size: '160ml',
      texture: 'Water',
      scent: 'Fermented',
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '30',
      name: 'Augustinus Bader The Rich Cream',
      brand: 'Augustinus Bader',
      category: 'Moisturizer',
      description: 'Luxurious super hydrator that stimulates skin\'s natural processes of rejuvenation.',
      imageUrl: 'https://cdn.dummyjson.com/product-images/fragrances/dior-j\'adore/1.webp',
      price: 8500.00,
      currency: 'TL',
      ingredients: ['TFC8®', 'Evening Primrose Oil', 'Squalan'],
      skinTypes: ['Normal', 'Dry', 'Mature'],
      benefits: ['Cell Renewal', 'Deep Hydration', 'Firming'],
      rating: 4.6,
      reviewCount: 1200,
      barcode: '5060552902302',
      size: '50ml',
      texture: 'Rich Cream',
      scent: 'Fragrance-Free',
      updatedAt: DateTime.now(),
    ),
  ];
}
