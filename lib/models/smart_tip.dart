class SmartTip {
  final String condition;
  final String tip;

  SmartTip({
    required this.condition,
    required this.tip,
  });

  factory SmartTip.fromJson(Map<String, dynamic> json) {
    return SmartTip(
      condition: json['condition'] ?? '',
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'tip': tip,
    };
  }
}

class SmartTipService {
  static final List<SmartTip> _tips = [
    SmartTip(
      condition: "Daily streak 1-3 days",
      tip: "Just getting started! Aim for 5 days, you'll see the effect.",
    ),
    SmartTip(
      condition: "Daily streak 4-6 days",
      tip: "Discipline is increasing! Complete your weekly goal.",
    ),
    SmartTip(
      condition: "Daily streak 7+ days",
      tip: "Great! Your routine is settling, your skin feels the change.",
    ),
    SmartTip(
      condition: "Daily streak 30+ days",
      tip: "Consistent for 1 month! Your skin is rewarding you.",
    ),
    SmartTip(
      condition: "No products used",
      tip: "You haven't added products yet! Choose a favorite moisturizer or serum.",
    ),
    SmartTip(
      condition: "No products added for a while",
      tip: "You took a break, now add a new product and watch the effect.",
    ),
    SmartTip(
      condition: "New product added",
      tip: "New product, new era! Be patient for 1-2 weeks, watch the effect.",
    ),
    SmartTip(
      condition: "Most used product: Moisturizer",
      tip: "Moisture balance is good! Add peeling occasionally.",
    ),
    SmartTip(
      condition: "Most used product: Serum",
      tip: "Boost your glow with serums! Vitamin C is great with morning routine.",
    ),
    SmartTip(
      condition: "Most used product: Cleanser",
      tip: "Cleansing is good but don't overdo it, your skin might dry out.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & most used product: Retinol",
      tip: "Super! Stick to night routine to boost Retinol effect.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & most used product: Niacinamide",
      tip: "Great! Keep balancing pores, add anti-spot SPF.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & skin type: Dry",
      tip: "Your skin stays hydrated but boost with extra moisture mask.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & skin type: Oily",
      tip: "Sebum balance is good! You can use light moisturizer and BHA.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & skin type: Combination",
      tip: "Keep the balance! Use regional moisturizer and serum.",
    ),
    SmartTip(
      condition: "Weekly 5+ days care & skin type: Sensitive",
      tip: "Sensitive skin, soothe with gentle products and Centella Asiatica.",
    ),
    SmartTip(
      condition: "Streak 1+ month & low moisture",
      tip: "You've been caring for a long time but boost moisture! Add Hyaluronic Acid.",
    ),
    SmartTip(
      condition: "Streak 1+ month & spots issue",
      tip: "Vitamin C helps reduce spots with morning routine.",
    ),
    SmartTip(
      condition: "Streak 1+ month & acne problem",
      tip: "Clean pores with BHA and Salicylic Acid, balance the skin.",
    ),
    SmartTip(
      condition: "Streak 1+ month & wrinkles noticed",
      tip: "Reduce wrinkle appearance with Peptides and Retinol.",
    ),
    SmartTip(
      condition: "Long time active product mix high",
      tip: "Don't mix too many actives! Reduce to prevent irritation.",
    ),
    SmartTip(
      condition: "New product & skin type dry",
      tip: "Added new product, support with extra moisturizer.",
    ),
    SmartTip(
      condition: "New product & skin type oily",
      tip: "New product, choose light formulas to balance sebum.",
    ),
    SmartTip(
      condition: "New product & skin type sensitive",
      tip: "Don't apply new product to whole face without test, start slow.",
    ),
    SmartTip(
      condition: "Weekly 7+ days routine & missing SPF",
      tip: "Discipline is great! Now add SPF, effect reduces without protection.",
    ),
    SmartTip(
      condition: "Weekly 7+ days routine & low skin glow",
      tip: "Boost your glow with Vitamin C and moisture support!",
    ),
    SmartTip(
      condition: "Weekly 7+ days routine & high pore appearance",
      tip: "Tighten pores with Niacinamide and regular cleansing.",
    ),
    SmartTip(
      condition: "Weekly 7+ days routine & skin irritation",
      tip: "Soothe irritated skin, reduce products and add Centella Asiatica.",
    ),
  ];

  static List<SmartTip> getSmartTips({
    required int dailyStreak,
    required int weeklyUsage,
    required String mostUsedProduct,
    required String skinType,
    required List<String> skinProblems,
    required bool hasNewProduct,
    required int totalDays,
  }) {
    List<SmartTip> matchingTips = [];

    // Günlük seri kontrolü
    if (dailyStreak >= 1 && dailyStreak <= 3) {
      matchingTips.add(_tips[0]);
    } else if (dailyStreak >= 4 && dailyStreak <= 6) {
      matchingTips.add(_tips[1]);
    } else if (dailyStreak >= 7 && dailyStreak < 30) {
      matchingTips.add(_tips[2]);
    } else if (dailyStreak >= 30) {
      matchingTips.add(_tips[3]);
    }

    // Ürün kullanımı kontrolü
    if (mostUsedProduct.isEmpty) {
      matchingTips.add(_tips[4]);
    } else if (hasNewProduct) {
      matchingTips.add(_tips[6]);
    }

    // En çok kullanılan ürün kontrolü
    if (mostUsedProduct.toLowerCase().contains('moisturizer')) {
      matchingTips.add(_tips[7]);
    } else if (mostUsedProduct.toLowerCase().contains('serum')) {
      matchingTips.add(_tips[8]);
    } else if (mostUsedProduct.toLowerCase().contains('cleanser') || mostUsedProduct.toLowerCase().contains('wash')) {
      matchingTips.add(_tips[9]);
    }

    // Haftalık kullanım ve ürün kombinasyonu
    if (weeklyUsage >= 5) {
      if (mostUsedProduct.toLowerCase().contains('retinol')) {
        matchingTips.add(_tips[10]);
      } else if (mostUsedProduct.toLowerCase().contains('niacinamide')) {
        matchingTips.add(_tips[11]);
      }

      // Cilt tipi kontrolü
      if (skinType.toLowerCase().contains('dry')) {
        matchingTips.add(_tips[12]);
      } else if (skinType.toLowerCase().contains('oily')) {
        matchingTips.add(_tips[13]);
      } else if (skinType.toLowerCase().contains('combination')) {
        matchingTips.add(_tips[14]);
      } else if (skinType.toLowerCase().contains('sensitive')) {
        matchingTips.add(_tips[15]);
      }
    }

    // Uzun süreli kullanım ve sorunlar
    if (totalDays >= 30) {
      if (skinProblems.any((problem) => problem.toLowerCase().contains('dryness'))) {
        matchingTips.add(_tips[16]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('blemish'))) {
        matchingTips.add(_tips[17]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('acne'))) {
        matchingTips.add(_tips[18]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('wrinkle'))) {
        matchingTips.add(_tips[19]);
      }
    }

    // Yeni ürün ve cilt tipi kombinasyonu
    if (hasNewProduct) {
      if (skinType.toLowerCase().contains('dry')) {
        matchingTips.add(_tips[21]);
      } else if (skinType.toLowerCase().contains('oily')) {
        matchingTips.add(_tips[22]);
      } else if (skinType.toLowerCase().contains('sensitive')) {
        matchingTips.add(_tips[23]);
      }
    }

    // Haftalık 7+ gün rutin kontrolleri
    if (weeklyUsage >= 7) {
      // SPF eksik kontrolü (basit bir kontrol)
      if (!mostUsedProduct.toLowerCase().contains('spf') && 
          !mostUsedProduct.toLowerCase().contains('sun')) {
        matchingTips.add(_tips[24]);
      }
      
      // Cilt parlaklığı düşük (basit bir kontrol)
      if (skinProblems.any((problem) => problem.toLowerCase().contains('dull'))) {
        matchingTips.add(_tips[25]);
      }
      
      // Gözenek görünümü fazla
      if (skinProblems.any((problem) => problem.toLowerCase().contains('pore'))) {
        matchingTips.add(_tips[26]);
      }
      
      // Cilt tahrişi
      if (skinProblems.any((problem) => problem.toLowerCase().contains('irritat'))) {
        matchingTips.add(_tips[27]);
      }
    }

    // En fazla 1 öneri döndür
    return matchingTips.take(1).toList();
  }
}
