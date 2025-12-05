import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/skincare_info.dart';

class InfoDetailPage extends StatefulWidget {
  final SkincareInfo skincareInfo;

  const InfoDetailPage({super.key, required this.skincareInfo});

  @override
  State<InfoDetailPage> createState() => _InfoDetailPageState();
}

class _InfoDetailPageState extends State<InfoDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _iconController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _iconController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  IconData _getIngredientIcon(String ingredientId) {
    switch (ingredientId) {
      case 'retinol':
        return Icons.auto_awesome;
      case 'vitamin_c':
        return Icons.wb_sunny;
      case 'hyaluronic_acid':
        return Icons.water_drop;
      case 'niacinamide':
        return Icons.brightness_6;
      case 'salicylic_acid':
        return Icons.cleaning_services;
      case 'peptides':
        return Icons.science;
      case 'ceramides':
        return Icons.shield;
      case 'aha':
        return Icons.brush;
      case 'bha':
        return Icons.cleaning_services;
      case 'centella_asiatica':
        return Icons.healing;
      default:
        return Icons.science;
    }
  }

  Color _getIngredientColor(String ingredientId) {
    switch (ingredientId) {
      case 'retinol':
        return AppColors.marron;
      case 'vitamin_c':
        return AppColors.marron;
      case 'hyaluronic_acid':
        return AppColors.pink;
      case 'niacinamide':
        return AppColors.marron;
      case 'salicylic_acid':
        return AppColors.marron;
      case 'peptides':
        return AppColors.pink;
      case 'ceramides':
        return AppColors.marron;
      case 'aha':
        return AppColors.marron;
      case 'bha':
        return AppColors.pink;
      case 'centella_asiatica':
        return AppColors.marron;
      default:
        return AppColors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar with Hero Animation
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
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
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.pink,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getIngredientColor(
                            widget.skincareInfo.id,
                          ).withOpacity(0.1),
                          AppColors.nude.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated Background Pattern
                        Positioned(
                          top: 20,
                          right: 20,
                          child: AnimatedBuilder(
                            animation: _iconAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _iconAnimation.value * 2 * 3.14159,
                                child: Icon(
                                  _getIngredientIcon(widget.skincareInfo.id),
                                  size: 80,
                                  color: _getIngredientColor(
                                    widget.skincareInfo.id,
                                  ).withOpacity(0.1),
                                ),
                              );
                            },
                          ),
                        ),
                        // Title and Icon
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _iconAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.5 + (_iconAnimation.value * 0.5),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getIngredientColor(
                                              widget.skincareInfo.id,
                                            ),
                                            _getIngredientColor(
                                              widget.skincareInfo.id,
                                            ).withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getIngredientColor(
                                              widget.skincareInfo.id,
                                            ).withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getIngredientIcon(
                                          widget.skincareInfo.id,
                                        ),
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.skincareInfo.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.skincareInfo.brand,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Info Detail Card
                      _buildEnhancedDetailCard(),

                      const SizedBox(height: 24),

                      // Enhanced Usage Tips Section
                      _buildEnhancedUsageTips(),

                      const SizedBox(height: 24),

                      // Enhanced Compatible Ingredients
                      _buildEnhancedCompatibleIngredients(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDetailCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.nude, AppColors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Benefits Section with Icons
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getIngredientColor(widget.skincareInfo.id),
                      _getIngredientColor(
                        widget.skincareInfo.id,
                      ).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Faydalar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Benefits List with Icons
          ...widget.skincareInfo.benefits.asMap().entries.map((entry) {
            final index = entry.key;
            final benefit = entry.value;
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _fadeAnimation.value) * 20),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getIngredientColor(
                            widget.skincareInfo.id,
                          ).withOpacity(0.2),
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getIngredientColor(
                                widget.skincareInfo.id,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getBenefitIcon(index),
                              color: _getIngredientColor(
                                widget.skincareInfo.id,
                              ),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              benefit,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          const SizedBox(height: 24),

          // How to Use Section
          Text(
            'Nasıl Kullanılır',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.pink.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              widget.skincareInfo.howItWorks,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedUsageTips() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pink.withOpacity(0.1), AppColors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.pink, AppColors.pink.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Kullanım Önerileri',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...widget.skincareInfo.usageTips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            return _buildAnimatedTip(
              tip,
              _getUsageTipIcon(index),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEnhancedCompatibleIngredients() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.marron.withOpacity(0.1), AppColors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.marron,
                      AppColors.marron.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'İyi Giden Bileşenler',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...widget.skincareInfo.worksWellWith.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return _buildAnimatedCompatibleIngredient(
              ingredient,
              _getCompatibleIngredientIcon(index),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTip(String tip, IconData icon) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 15),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.pink.withOpacity(0.3),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.pink, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCompatibleIngredient(String ingredient, IconData icon) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 15),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.marron.withOpacity(0.3),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.marron.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.marron, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.marron.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.marron,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getBenefitIcon(int index) {
    final icons = [
      Icons.auto_awesome,
      Icons.brightness_6,
      Icons.healing,
      Icons.face,
      Icons.water_drop,
      Icons.shield,
      Icons.brush,
      Icons.science,
    ];
    return icons[index % icons.length];
  }

  IconData _getUsageTipIcon(int index) {
    final icons = [
      Icons.timer,
      Icons.wb_sunny,
      Icons.hearing,
      Icons.science,
      Icons.warning,
      Icons.info,
      Icons.check_circle,
      Icons.help,
    ];
    return icons[index % icons.length];
  }

  IconData _getCompatibleIngredientIcon(int index) {
    final icons = [
      Icons.water_drop,
      Icons.brightness_6,
      Icons.science,
      Icons.shield,
      Icons.auto_awesome,
      Icons.healing,
      Icons.brush,
      Icons.cleaning_services,
    ];
    return icons[index % icons.length];
  }
}
