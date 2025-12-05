import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async'; // Debouncing için eklendi
import '../core/theme.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/skincare_api_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProductSearchPage extends StatefulWidget {
  final String? initialQuery;
  
  const ProductSearchPage({super.key, this.initialQuery});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isSearching = false;
  List<Product> _searchResults = [];
  List<Product> _recentProducts = [];
  String? _errorMessage;

  // Search mode: 'text' or 'barcode'
  String _searchMode = 'text';

  // Scanner controller
  MobileScannerController? _scannerController;

  // Debouncing için timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchByName(widget.initialQuery!);
    }
    _loadRecentProducts();
    _setupScanner();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scannerController?.dispose();
    _debounceTimer?.cancel(); // Timer'ı temizle
    super.dispose();
  }

  /// Setup barcode scanner
  void _setupScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  /// Load recent products
  Future<void> _loadRecentProducts() async {
    if (!mounted) return; // Widget dispose edilmişse çık

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await ProductService.getRecentProducts(limit: 10);
      if (mounted) {
        // Widget hala aktif mi kontrol et
        setState(() {
          _recentProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Son ürünler yüklenirken hata oluştu: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Search products by name with debouncing
  Future<void> _searchByName(String query) async {
    // Önceki timer'ı iptal et
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    // 300ms debouncing (daha hızlı yanıt için)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      setState(() {
        _isSearching = true;
        _errorMessage = null;
      });

      try {
        // Arama yapılıyor: $query
        
        // Yeni cilt bakım API'sini kullan
        final skincareResults = await SkincareApiService.searchProducts(
          query: query.trim(),
          limit: 20,
        );
        
        // SkincareProduct'ları Product'a dönüştür
        final results = skincareResults.map((skincareProduct) {
          return Product(
            id: skincareProduct.id,
            name: skincareProduct.name,
            brand: skincareProduct.brand,
            category: skincareProduct.category,
            description: skincareProduct.description,
            imageUrl: skincareProduct.imageUrl,
            price: skincareProduct.price,
            currency: skincareProduct.currency,
            ingredients: skincareProduct.ingredients,
            benefits: skincareProduct.benefits,
            rating: skincareProduct.rating,
            reviewCount: skincareProduct.reviewCount,
            barcode: skincareProduct.barcode,
            size: skincareProduct.size,
            texture: skincareProduct.texture,
            scent: skincareProduct.scent,
            skinTypes: skincareProduct.skinTypes,
          );
        }).toList();
        
        // ${results.length} sonuç bulundu

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;

            // Eğer sonuç yoksa kullanıcıya bilgi ver
            if (results.isEmpty && query.trim().isNotEmpty) {
              _errorMessage =
                  '"$query" için ürün bulunamadı. Farklı anahtar kelimeler deneyin.';
            }
          });
        }
      } catch (e) {
        // Arama hatası: $e
        if (mounted) {
          setState(() {
            _errorMessage = 'Arama sırasında hata oluştu: $e';
            _isSearching = false;
          });
        }
      }
    });
  }

  /// Search product by barcode
  Future<void> _searchByBarcode(String barcode) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Yeni cilt bakım API'sini kullan
      final skincareProduct = await SkincareApiService.getProductByBarcode(barcode);
      
      Product? product;
      if (skincareProduct != null) {
        // SkincareProduct'ı Product'a dönüştür
        product = Product(
          id: skincareProduct.id,
          name: skincareProduct.name,
          brand: skincareProduct.brand,
          category: skincareProduct.category,
          description: skincareProduct.description,
          imageUrl: skincareProduct.imageUrl,
          price: skincareProduct.price,
          currency: skincareProduct.currency,
          ingredients: skincareProduct.ingredients,
          benefits: skincareProduct.benefits,
          rating: skincareProduct.rating,
          reviewCount: skincareProduct.reviewCount,
          barcode: skincareProduct.barcode,
          size: skincareProduct.size,
          texture: skincareProduct.texture,
          scent: skincareProduct.scent,
          skinTypes: skincareProduct.skinTypes,
        );
      }

      if (product != null && mounted) {
        // Navigate to product detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product!),
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Bu barkod ile ürün bulunamadı: $barcode';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Barkod tarama sırasında hata oluştu: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle barcode detection
  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _searchByBarcode(barcode.rawValue!);
        Navigator.pop(context); // Close scanner
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppColors.pink, size: 20),
          ),
        ),
        title: Text(
          'Ürün Arama',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _searchMode = _searchMode == 'text' ? 'barcode' : 'text';
              });
            },
            icon: Icon(
              _searchMode == 'text' ? Icons.qr_code_scanner : Icons.search,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () async {
              await ProductService.addSampleProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Örnek ürünler eklendi',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadRecentProducts();
            },
            icon: Icon(Icons.add, color: AppColors.primary, size: 24),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, AppColors.yellow.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Search Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.pink.withOpacity(0.1),
                    AppColors.yellow.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.pink.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ürün Arama',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Ürün adı ile arama yapın veya barkod tarayın',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Enhanced Mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.yellow.withOpacity(0.1),
                          AppColors.pink.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.yellow.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.pink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _searchMode == 'text'
                                ? Icons.search
                                : Icons.qr_code_scanner,
                            color: AppColors.pink,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _searchMode == 'text' ? 'Ürün Ara' : 'Barkod Tarama',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced Search input
                  if (_searchMode == 'text')
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.white,
                            AppColors.marron.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.marron.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Ürün adı ile arama yapın...',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.search,
                              color: AppColors.pink,
                              size: 20,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.all(8),
                                  child: IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.pink,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _searchByName(value);
                          } else {
                            setState(() {
                              _searchResults = [];
                            });
                          }
                        },
                      ),
                    ),

                  // Enhanced Barcode scanner button
                  if (_searchMode == 'barcode')
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.marron.withOpacity(0.1),
                            AppColors.yellow.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.marron.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.marron,
                                  AppColors.marron.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.marron.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Barkod Tarayıcısını Aç',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ürünün barkodunu tarayarak bilgilerini görün',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _openBarcodeScanner(),
                            icon: Icon(Icons.camera_alt),
                            label: Text('Taramayı Başlat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.marron,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.marron.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator
            if (_isLoading || _isSearching)
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      _isSearching ? 'Ürün aranıyor...' : 'Yükleniyor...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_isSearching) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Gerçek zamanlı veriler kontrol ediliyor',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Search results
            if (_searchResults.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Arama Sonuçları (${_searchResults.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (_searchResults.isNotEmpty)
                            Text(
                              'Gerçek zamanlı veri',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Welcome message for skincare search
            if (_searchResults.isEmpty && !_isSearching && !_isLoading)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ürün Arama',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face,
                                size: 64,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ürün Ara',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ürün adını yazın veya barkod tarayın',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.yellow.withOpacity(0.1),
                                      AppColors.pink.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.yellow.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.yellow.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.trending_up,
                                            color: AppColors.yellow,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Son Aramalar:',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Open barcode scanner
  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BarcodeScannerPage(onBarcodeDetected: _onBarcodeDetected),
      ),
    );
  }
}

/// Barcode scanner page
class BarcodeScannerPage extends StatefulWidget {
  final Function(BarcodeCapture) onBarcodeDetected;

  const BarcodeScannerPage({super.key, required this.onBarcodeDetected});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        ),
        title: Text(
          'Barkod Tarayıcı',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _scannerController?.toggleTorch();
            },
            icon: const Icon(Icons.flash_on, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: widget.onBarcodeDetected,
          ),
          // Scanner overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.primary, width: 2),
                      bottom: BorderSide(color: AppColors.primary, width: 2),
                      left: BorderSide(color: AppColors.primary, width: 2),
                      right: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Barkodu tarama alanına yerleştirin',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
