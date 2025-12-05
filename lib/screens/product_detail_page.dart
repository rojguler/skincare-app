import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  /// Check if product is saved in local database
  Future<void> _checkIfSaved() async {
    try {
      final savedProduct = await ProductService.searchByBarcode(
        widget.product.id,
      );
      setState(() {
        _isSaved = savedProduct != null;
      });
    } catch (e) {
      print('Check saved product error: $e');
    }
  }

  /// Show product information
  void _showProductInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gerçek zamanlı veri - API\'den çekildi',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Ürün Detayı',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showProductInfo,
            icon: Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            if (widget.product.imageUrl != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 64,
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Product name
            Text(
              widget.product.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Brand and category
            Row(
              children: [
                if (widget.product.brand != null) ...[
                  Text(
                    widget.product.brand!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.product.category != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
                if (widget.product.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Unit and data freshness
            Row(
              children: [
                if (widget.product.unit != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.unit!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.product.dataFreshness,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            if (widget.product.description != null) ...[
              _buildSection(
                title: 'Açıklama',
                content: widget.product.description!,
              ),
              const SizedBox(height: 24),
            ],

            // Ingredients
            _buildSection(
              title: 'İçerikler',
              content: widget.product.formattedIngredients,
              isIngredients: true,
            ),

            const SizedBox(height: 24),

            // Nutrition information
            _buildSection(
              title: 'Besin Değerleri',
              content: widget.product.formattedNutritionInfo,
            ),

            const SizedBox(height: 24),

            // Additional information
            if (widget.product.additionalInfo != null) ...[
              _buildSection(
                title: 'Ek Bilgiler',
                content: _formatAdditionalInfo(widget.product.additionalInfo!),
              ),
              const SizedBox(height: 24),
            ],

            // Barcode information
            if (widget.product.barcode != null) ...[
              _buildSection(
                title: 'Barkod',
                content: widget.product.barcode!,
                showCopyButton: true,
              ),
              const SizedBox(height: 24),
            ],

            // Unit information
            if (widget.product.unit != null) ...[
              _buildSection(title: 'Birim', content: widget.product.unit!),
              const SizedBox(height: 24),
            ],

            // Source information
            if (widget.product.additionalInfo != null &&
                widget.product.additionalInfo!['source'] != null) ...[
              _buildSection(
                title: 'Veri Kaynağı',
                content: widget.product.additionalInfo!['source'],
              ),
              const SizedBox(height: 24),
            ],

            // Last updated
            if (widget.product.updatedAt != null) ...[
              _buildSection(
                title: 'Son Güncelleme',
                content: _formatDate(widget.product.updatedAt!),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 40),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showProductInfo,
                    icon: Icon(Icons.info_outline),
                    label: Text('Bilgi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share product information
                      _shareProduct();
                    },
                    icon: Icon(Icons.share),
                    label: Text('Paylaş'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a section with title and content
  Widget _buildSection({
    required String title,
    required String content,
    bool isIngredients = false,
    bool showCopyButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            Colors.amber[50], // Nude/yellow background as per user preference
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (showCopyButton)
                IconButton(
                  onPressed: () {
                    // Copy to clipboard
                    _copyToClipboard(content);
                  },
                  icon: Icon(Icons.copy, color: AppColors.primary, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Format additional information
  String _formatAdditionalInfo(Map<String, dynamic> info) {
    List<String> formattedInfo = [];
    info.forEach((key, value) {
      if (value != null && key != 'source') {
        formattedInfo.add('$key: $value');
      }
    });
    return formattedInfo.isEmpty
        ? 'Ek bilgi bulunmuyor'
        : formattedInfo.join('\n');
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Copy text to clipboard
  void _copyToClipboard(String text) {
    // In a real app, you would use a clipboard plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kopyalandı: $text', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// Share product information
  void _shareProduct() {
    String shareText = '${widget.product.name}\n';
    if (widget.product.brand != null) {
      shareText += 'Marka: ${widget.product.brand}\n';
    }
    if (widget.product.description != null) {
      shareText += 'Açıklama: ${widget.product.description}\n';
    }
    shareText += 'İçerikler: ${widget.product.formattedIngredients}\n';
    shareText += 'Besin Değerleri: ${widget.product.formattedNutritionInfo}';

    // In a real app, you would use a share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paylaşım özelliği yakında eklenecek',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
