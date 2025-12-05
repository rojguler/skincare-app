import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../models/skincare_entry.dart';
import '../models/smart_tip.dart';

class UserStatsPage extends StatefulWidget {
  const UserStatsPage({Key? key}) : super(key: key);

  @override
  State<UserStatsPage> createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage>
    with TickerProviderStateMixin {
  List<SkincareEntry> entries = [];
  Map<String, int> productUsage = {};
  Map<String, int> skinConditionData = {};
  Map<String, int> dailyEntries = {};
  Map<String, int> skinTypeData = {};
  Map<String, double> productEffectiveness = {};
  Map<String, int> weeklyActivity = {};
  Map<String, int> monthlyActivity = {};

  // Akıllı öneriler için değişkenler
  List<SmartTip> smartTips = [];
  String userSkinType = 'Karma';
  List<String> userSkinProblems = [];

  late AnimationController _animationController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _chartController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _loadData() async {
    try {
      final entriesBox = Hive.box('entries');
      final rawEntries = entriesBox.values.toList();
      entries = <SkincareEntry>[];

      for (final rawEntry in rawEntries) {
        try {
          if (rawEntry is SkincareEntry) {
            entries.add(rawEntry);
          }
        } catch (e) {}
      }

      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _analyzeData();
      
      // Kullanıcı profil bilgilerini yükle
      await _loadUserProfile();
      
      // Akıllı önerileri oluştur
      _generateSmartTips();
      
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userSkinType = prefs.getString('skin_type') ?? 'Karma';
      userSkinProblems = prefs.getStringList('skin_problems') ?? [];
    } catch (e) {
      // Hata durumunda varsayılan değerler
      userSkinType = 'Karma';
      userSkinProblems = [];
    }
  }

  void _generateSmartTips() {
    // Günlük seri hesapla
    int dailyStreak = _calculateDailyStreak();
    
    // Haftalık kullanım hesapla
    int weeklyUsage = _calculateWeeklyUsage();
    
    // En çok kullanılan ürün
    String mostUsedProduct = _getMostUsedProduct();
    
    // Yeni ürün kontrolü (son 7 gün içinde eklenen)
    bool hasNewProduct = _hasNewProduct();
    
    // Toplam gün sayısı
    int totalDays = entries.length;
    
    smartTips = SmartTipService.getSmartTips(
      dailyStreak: dailyStreak,
      weeklyUsage: weeklyUsage,
      mostUsedProduct: mostUsedProduct,
      skinType: userSkinType,
      skinProblems: userSkinProblems,
      hasNewProduct: hasNewProduct,
      totalDays: totalDays,
    );
  }

  int _calculateDailyStreak() {
    if (entries.isEmpty) return 0;
    
    DateTime today = DateTime.now();
    int streak = 0;
    
    // Bugünden geriye doğru kontrol et
    for (int i = 0; i < 30; i++) {
      DateTime checkDate = today.subtract(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      
      bool hasEntry = entries.any((entry) => 
        DateFormat('yyyy-MM-dd').format(entry.createdAt) == dateStr);
      
      if (hasEntry) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _calculateWeeklyUsage() {
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    int weeklyCount = 0;
    for (int i = 0; i < 7; i++) {
      DateTime checkDate = weekStart.add(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      
      bool hasEntry = entries.any((entry) => 
        DateFormat('yyyy-MM-dd').format(entry.createdAt) == dateStr);
      
      if (hasEntry) weeklyCount++;
    }
    
    return weeklyCount;
  }

  String _getMostUsedProduct() {
    if (productUsage.isEmpty) return '';
    
    String mostUsed = '';
    int maxCount = 0;
    
    productUsage.forEach((product, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = product;
      }
    });
    
    return mostUsed;
  }

  bool _hasNewProduct() {
    if (entries.isEmpty) return false;
    
    DateTime weekAgo = DateTime.now().subtract(Duration(days: 7));
    
    // Son 7 gün içinde eklenen ürün var mı kontrol et
    return entries.any((entry) => entry.createdAt.isAfter(weekAgo));
  }

  void _analyzeData() {
    productUsage.clear();
    skinConditionData.clear();
    dailyEntries.clear();
    skinTypeData.clear();
    productEffectiveness.clear();
    weeklyActivity.clear();
    monthlyActivity.clear();

    // Ürün kullanım analizi
    for (final entry in entries) {
      for (final product in entry.products) {
        productUsage[product] = (productUsage[product] ?? 0) + 1;
      }

      // Cilt tipi analizi
      skinTypeData[entry.skinType] = (skinTypeData[entry.skinType] ?? 0) + 1;

      // Günlük aktivite analizi
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      dailyEntries[dateKey] = (dailyEntries[dateKey] ?? 0) + 1;

      // Haftalık aktivite analizi
      final weekKey = DateFormat('yyyy-ww').format(entry.createdAt);
      weeklyActivity[weekKey] = (weeklyActivity[weekKey] ?? 0) + 1;

      // Aylık aktivite analizi
      final monthKey = DateFormat('yyyy-MM').format(entry.createdAt);
      monthlyActivity[monthKey] = (monthlyActivity[monthKey] ?? 0) + 1;
    }

    // Ürün etkinliği analizi (basit hesaplama)
    _calculateProductEffectiveness();
  }

  void _calculateProductEffectiveness() {
    // Basit etkinlik hesaplama: düzenli kullanım = yüksek etkinlik
    for (final product in productUsage.keys) {
      final usageCount = productUsage[product]!;
      final totalDays = entries.length;
      final effectiveness = usageCount / totalDays;
      productEffectiveness[product] = effectiveness;
    }
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];

    if (entries.isEmpty) {
      recommendations.add(
        'Henüz kayıt yok. İlk kaydını oluştur ve istatistiklerini gör!',
      );
      return recommendations;
    }

    // Akıllı önerileri kullan
    for (final tip in smartTips) {
      recommendations.add(tip.tip);
    }

    // Eğer akıllı öneri yoksa varsayılan öneriler
    if (recommendations.isEmpty) {
      // En çok kullanılan ürün analizi
      if (productUsage.isNotEmpty) {
        final mostUsedProduct = productUsage.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );

        if (mostUsedProduct.value >= 5) {
          recommendations.add(
            '${mostUsedProduct.key} ürününü ${mostUsedProduct.value} kez kullanmışsın. Bu ürün rutininin vazgeçilmezi!',
          );
        }
      }

      // Aktivite önerisi
      final averageEntriesPerWeek = weeklyActivity.values.isEmpty
          ? 0
          : weeklyActivity.values.reduce((a, b) => a + b) / weeklyActivity.length;

      if (averageEntriesPerWeek < 3) {
        recommendations.add(
          'Haftada ortalama ${averageEntriesPerWeek.toStringAsFixed(1)} kayıt yapıyorsun. Daha düzenli olmak için hatırlatıcılar kurabilirsin!',
        );
      } else {
        recommendations.add(
          'Harika! Haftada ortalama ${averageEntriesPerWeek.toStringAsFixed(1)} kayıt yapıyorsun. Bu düzenli rutin cildini güzelleştiriyor!',
        );
      }
    }

    return recommendations;
  }

  // Gün adını getir
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
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
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 100,
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Text(
                  'İstatistikler',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
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
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _hapticFeedback();
                        _loadData();
                      },
                      tooltip: 'Yenile',
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.pink.withOpacity(0.1),
                          AppColors.yellow.withOpacity(0.05),
                          AppColors.marron.withOpacity(0.03),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Icon(
                            Icons.bar_chart,
                            size: 50,
                            color: AppColors.pink.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left: 30,
                          child: Icon(
                            Icons.trending_up,
                            size: 30,
                            color: AppColors.yellow.withOpacity(0.15),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Toplam Kayıt',
                              value: entries.length.toString(),
                              icon: Icons.note,
                              color: AppColors.pink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Kullanılan Ürün',
                              value: productUsage.length.toString(),
                              icon: Icons.local_pharmacy,
                              color: AppColors.marron,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'En Aktif Gün',
                              value: dailyEntries.isNotEmpty
                                  ? dailyEntries.entries
                                        .reduce(
                                          (a, b) => a.value > b.value ? a : b,
                                        )
                                        .value
                                        .toString()
                                  : '0',
                              icon: Icons.trending_up,
                              color: AppColors
                                  .marron, // Kullanılan Ürün kutusunun rengi
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Ortalama/Hafta',
                              value: weeklyActivity.isNotEmpty
                                  ? (weeklyActivity.values.reduce(
                                              (a, b) => a + b,
                                            ) /
                                            weeklyActivity.length)
                                        .toStringAsFixed(1)
                                  : '0',
                              icon: Icons.calendar_today,
                              color: AppColors.pink,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Recommendations Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.pink.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb,
                                    color: AppColors.pink,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Akıllı Öneriler',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._getRecommendations()
                                .map(
                                  (recommendation) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.pink,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            recommendation,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enhanced Skin Type Chart
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.marron.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.face,
                                    color: AppColors.marron,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Cilt Tipi Analizi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: _chartAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 + (_chartAnimation.value * 0.2),
                                  child: Container(
                                    height: 200,
                                    child: skinTypeData.isNotEmpty
                                        ? PieChart(
                                            PieChartData(
                                              sections: skinTypeData.entries.map((
                                                entry,
                                              ) {
                                                final color = _getSkinTypeColor(
                                                  entry.key,
                                                );
                                                return PieChartSectionData(
                                                  value: entry.value.toDouble(),
                                                  title:
                                                      '${entry.key}\n${entry.value}',
                                                  color: color,
                                                  radius: 60,
                                                  titleStyle:
                                                      GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors.white,
                                                      ),
                                                );
                                              }).toList(),
                                              centerSpaceRadius: 40,
                                              sectionsSpace: 2,
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.face,
                                                  size: 48,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Henüz cilt tipi verisi yok',
                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),

                            // Color legend for skin types
                            if (skinTypeData.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _buildColorLegend('Kuru', AppColors.yellow),
                                  _buildColorLegend('Yağlı', AppColors.pink),
                                  _buildColorLegend('Hassas', AppColors.marron),
                                  _buildColorLegend(
                                    'Karma',
                                    AppColors.yellow.withOpacity(0.8),
                                  ),
                                  _buildColorLegend(
                                    'Normal',
                                    AppColors.pink.withOpacity(0.8),
                                  ),
                                  _buildColorLegend(
                                    'Akneli',
                                    AppColors.marron.withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enhanced Product Effectiveness
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ürün Etkinliği',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            productEffectiveness.isNotEmpty
                                ? Column(
                                    children:
                                        (productEffectiveness.entries.toList()
                                              ..sort(
                                                (a, b) =>
                                                    b.value.compareTo(a.value),
                                              ))
                                            .take(5)
                                            .map(
                                              (entry) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _getEffectivenessColor(
                                                              entry.value,
                                                            ).withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        _getProductIcon(
                                                          entry.key,
                                                        ),
                                                        color:
                                                            _getEffectivenessColor(
                                                              entry.value,
                                                            ),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        entry.key,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .lightGray
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                        child: FractionallySizedBox(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          widthFactor:
                                                              entry.value,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  _getEffectivenessColor(
                                                                    entry.value,
                                                                  ),
                                                                  _getEffectivenessColor(
                                                                    entry.value,
                                                                  ).withOpacity(
                                                                    0.7,
                                                                  ),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${(entry.value * 100).toInt()}%',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            _getEffectivenessColor(
                                                              entry.value,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  )
                                : Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.local_pharmacy,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Henüz ürün kullanım verisi yok',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Haftalık Aktivite Grafiği
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.pink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: AppColors.pink,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Haftalık Aktivite',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Haftalık aktivite grafiği
                            Container(
                              height: 150,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(7, (index) {
                                  final day = DateTime.now().subtract(
                                    Duration(days: 6 - index),
                                  );
                                  final dayEntries = entries.where((entry) {
                                    final entryDate = entry.date;
                                    return entryDate.year == day.year &&
                                        entryDate.month == day.month &&
                                        entryDate.day == day.day;
                                  }).length;

                                  final maxEntries = entries.isNotEmpty
                                      ? entries
                                            .map((e) {
                                              final entryDate = e.date;
                                              final weekAgo = DateTime.now()
                                                  .subtract(
                                                    const Duration(days: 7),
                                                  );
                                              if (entryDate.isAfter(weekAgo)) {
                                                return entries.where((entry) {
                                                  final entryDate2 = entry.date;
                                                  return entryDate2.year ==
                                                          entryDate.year &&
                                                      entryDate2.month ==
                                                          entryDate.month &&
                                                      entryDate2.day ==
                                                          entryDate.day;
                                                }).length;
                                              }
                                              return 0;
                                            })
                                            .reduce((a, b) => a > b ? a : b)
                                      : 1;

                                  final height = maxEntries > 0
                                      ? (dayEntries / maxEntries) * 100.0
                                      : 0.0;
                                  final isToday = day.day == DateTime.now().day;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Grafik çubuğu
                                      Container(
                                        width: 35,
                                        height: height,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: isToday
                                                ? [
                                                    AppColors.pink,
                                                    AppColors.pink.withOpacity(
                                                      0.7,
                                                    ),
                                                  ]
                                                : [
                                                    AppColors.pink.withOpacity(
                                                      0.6,
                                                    ),
                                                    AppColors.pink.withOpacity(
                                                      0.3,
                                                    ),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.pink.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            dayEntries.toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Gün adı
                                      Text(
                                        _getDayName(day.weekday),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: isToday
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isToday
                                              ? AppColors.pink
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Gün numarası
                                      Text(
                                        day.day.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: isToday
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isToday
                                              ? AppColors.pink
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Grafik açıklaması
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.pink.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Düşük Aktivite',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.pink,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Yüksek Aktivite',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gelişmiş En Çok Kullanılan Ürünler
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.marron.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.local_pharmacy,
                                    color: AppColors.marron,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'En Çok Kullanılan Ürünler',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            productUsage.isNotEmpty
                                ? Column(
                                    children:
                                        (productUsage.entries.toList()..sort(
                                              (a, b) =>
                                                  b.value.compareTo(a.value),
                                            ))
                                            .take(3)
                                            .map(
                                              (entry) => Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      AppColors.white,
                                                      AppColors.pink
                                                          .withOpacity(0.05),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.lightGray
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors.pink
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            AppColors.yellow
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        _getProductIcon(
                                                          entry.key,
                                                        ),
                                                        color: AppColors.pink,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            entry.key,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${entry.value} kez kullanıldı',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            AppColors.pink,
                                                            AppColors.pink
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${((entry.value / entries.length) * 100).toInt()}%',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .white,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  )
                                : Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.local_pharmacy,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Henüz ürün kullanım verisi yok',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),

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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16), // Küçültülmüş padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
          Container(
            padding: const EdgeInsets.all(10), // Küçültülmüş padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20, // Küçültülmüş icon
            ),
          ),
          const SizedBox(height: 10), // Küçültülmüş boşluk
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20, // Küçültülmüş font
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11, // Küçültülmüş font
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSkinTypeColor(String skinType) {
    switch (skinType) {
      case 'Kuru':
        return AppColors.yellow;
      case 'Yağlı':
        return AppColors.pink;
      case 'Hassas':
        return AppColors.marron;
      case 'Karma':
        return AppColors.yellow.withOpacity(0.8);
      case 'Normal':
        return AppColors.pink.withOpacity(0.8);
      case 'Akneli':
        return AppColors.marron.withOpacity(0.8);
      default:
        return AppColors.pink;
    }
  }

  Color _getEffectivenessColor(double effectiveness) {
    if (effectiveness >= 0.7) return AppColors.yellow; // Tema rengi
    if (effectiveness >= 0.4) return AppColors.pink; // Tema rengi
    return AppColors.marron; // Tema rengi
  }

  Widget _buildColorLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  IconData _getProductIcon(String product) {
    switch (product) {
      case 'Serum':
        return Icons.water_drop;
      case 'Tonik':
        return Icons.waves;
      case 'Güneş Kremi':
        return Icons.wb_sunny;
      case 'Nemlendirici':
        return Icons.spa;
      case 'Maske':
        return Icons.face;
      case 'Peeling':
        return Icons.auto_fix_high;
      default:
        return Icons.local_pharmacy;
    }
  }
}
