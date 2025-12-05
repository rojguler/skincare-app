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
      condition: "Günlük seri 1-3 gün",
      tip: "Yeni başlıyorsun! Hedef 5 gün, etkisini göreceksin.",
    ),
    SmartTip(
      condition: "Günlük seri 4-6 gün",
      tip: "Disiplin artıyor! Haftalık hedefini tamamla.",
    ),
    SmartTip(
      condition: "Günlük seri 7+ gün",
      tip: "Harika! Rutinin oturuyor, cildin değişimi hissediyor.",
    ),
    SmartTip(
      condition: "Günlük seri 30+ gün",
      tip: "1 aydır düzenlisin! Cildin seni ödüllendiriyor.",
    ),
    SmartTip(
      condition: "Hiç ürün kullanılmamış",
      tip: "Henüz ürün eklemedin! Favori bir nemlendirici veya serum seç.",
    ),
    SmartTip(
      condition: "Uzun süredir ürün eklenmedi",
      tip: "Bir süredir ara vermişsin, şimdi yeni ürün ekle ve etkisini izle.",
    ),
    SmartTip(
      condition: "Yeni ürün eklendi",
      tip: "Yeni ürün, yeni dönem! 1-2 hafta sabırlı ol, etkisini izle.",
    ),
    SmartTip(
      condition: "En çok kullanılan ürün: Nemlendirici",
      tip: "Rutinin nem dengesi iyi! Arada peeling de ekle.",
    ),
    SmartTip(
      condition: "En çok kullanılan ürün: Serum",
      tip: "Serumlarla ışıltını artır! C vitamini sabah rutiniyle birleşince harika olur.",
    ),
    SmartTip(
      condition: "En çok kullanılan ürün: Temizleyici",
      tip: "Temizlik iyi ama aşırıya kaçma, cildin kuruyabilir.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve en çok kullanılan ürün: Retinol",
      tip: "Süper! Retinol etkisini artırmak için gece rutinine sadık kal.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve en çok kullanılan ürün: Niacinamide",
      tip: "Harika! Gözenekleri dengelemeye devam et, leke karşıtı SPF ekle.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve cilt tipi: Kuru",
      tip: "Cildin nemli kalıyor ama ekstra nem maskesi ile güçlendir.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve cilt tipi: Yağlı",
      tip: "Sebum dengesi iyi! Hafif nemlendirici ve BHA kullanabilirsin.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve cilt tipi: Karma",
      tip: "Dengeyi koru! Bölgelere göre nemlendirici ve serum kullan.",
    ),
    SmartTip(
      condition: "Haftada 5+ gün bakım ve cilt tipi: Hassas",
      tip: "Cildin hassas, nazik ürünler ve Centella Asiatica ile yatıştır.",
    ),
    SmartTip(
      condition: "Seri 1+ ay ve nem düşük",
      tip: "Uzun süredir bakım yapıyorsun ama nemi artır! Hyaluronic Acid ekle.",
    ),
    SmartTip(
      condition: "Seri 1+ ay ve leke sorunu var",
      tip: "C vitamini sabah rutiniyle lekeleri azaltmaya yardımcı olur.",
    ),
    SmartTip(
      condition: "Seri 1+ ay ve akne problemi var",
      tip: "BHA ve Salicylic Acid ile gözenekleri temizle, cildi dengele.",
    ),
    SmartTip(
      condition: "Seri 1+ ay ve kırışıklık fark edilmiş",
      tip: "Peptidler ve Retinol ile kırışıklık görünümünü azalt.",
    ),
    SmartTip(
      condition: "Uzun süre aktif ürün karışımı fazla",
      tip: "Fazla aktif ürün birleştirme! Tahrişi önlemek için azalt.",
    ),
    SmartTip(
      condition: "Yeni ürün ve cilt tipi kuru",
      tip: "Yeni ürünü ekledin, ekstra nemlendirici ile destekle.",
    ),
    SmartTip(
      condition: "Yeni ürün ve cilt tipi yağlı",
      tip: "Yeni ürün, sebumu dengelemek için hafif formüller seç.",
    ),
    SmartTip(
      condition: "Yeni ürün ve cilt tipi hassas",
      tip: "Yeni ürünü test etmeden tüm yüzüne uygulama, yavaş başla.",
    ),
    SmartTip(
      condition: "Haftada 7+ gün rutin ve SPF eksik",
      tip: "Disiplin harika! Şimdi SPF ekle, koruma olmazsa etkisi azalır.",
    ),
    SmartTip(
      condition: "Haftada 7+ gün rutin ve cilt parlaklığı düşük",
      tip: "C vitamini ve nem desteği ile ışıltını artır!",
    ),
    SmartTip(
      condition: "Haftada 7+ gün rutin ve gözenek görünümü fazla",
      tip: "Niacinamide ve düzenli temizleme ile gözenekleri sıkılaştır.",
    ),
    SmartTip(
      condition: "Haftada 7+ gün rutin ve cilt tahrişi var",
      tip: "Tahriş olmuş cildini yatıştır, ürünleri azalt ve Centella Asiatica ekle.",
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
    if (mostUsedProduct.toLowerCase().contains('nemlendirici')) {
      matchingTips.add(_tips[7]);
    } else if (mostUsedProduct.toLowerCase().contains('serum')) {
      matchingTips.add(_tips[8]);
    } else if (mostUsedProduct.toLowerCase().contains('temizleyici')) {
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
      if (skinType.toLowerCase().contains('kuru')) {
        matchingTips.add(_tips[12]);
      } else if (skinType.toLowerCase().contains('yağlı')) {
        matchingTips.add(_tips[13]);
      } else if (skinType.toLowerCase().contains('karma')) {
        matchingTips.add(_tips[14]);
      } else if (skinType.toLowerCase().contains('hassas')) {
        matchingTips.add(_tips[15]);
      }
    }

    // Uzun süreli kullanım ve sorunlar
    if (totalDays >= 30) {
      if (skinProblems.any((problem) => problem.toLowerCase().contains('kuruluk'))) {
        matchingTips.add(_tips[16]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('leke'))) {
        matchingTips.add(_tips[17]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('akne'))) {
        matchingTips.add(_tips[18]);
      }
      if (skinProblems.any((problem) => problem.toLowerCase().contains('kırışık'))) {
        matchingTips.add(_tips[19]);
      }
    }

    // Yeni ürün ve cilt tipi kombinasyonu
    if (hasNewProduct) {
      if (skinType.toLowerCase().contains('kuru')) {
        matchingTips.add(_tips[21]);
      } else if (skinType.toLowerCase().contains('yağlı')) {
        matchingTips.add(_tips[22]);
      } else if (skinType.toLowerCase().contains('hassas')) {
        matchingTips.add(_tips[23]);
      }
    }

    // Haftalık 7+ gün rutin kontrolleri
    if (weeklyUsage >= 7) {
      // SPF eksik kontrolü (basit bir kontrol)
      if (!mostUsedProduct.toLowerCase().contains('spf') && 
          !mostUsedProduct.toLowerCase().contains('güneş')) {
        matchingTips.add(_tips[24]);
      }
      
      // Cilt parlaklığı düşük (basit bir kontrol)
      if (skinProblems.any((problem) => problem.toLowerCase().contains('mat'))) {
        matchingTips.add(_tips[25]);
      }
      
      // Gözenek görünümü fazla
      if (skinProblems.any((problem) => problem.toLowerCase().contains('gözenek'))) {
        matchingTips.add(_tips[26]);
      }
      
      // Cilt tahrişi
      if (skinProblems.any((problem) => problem.toLowerCase().contains('tahriş'))) {
        matchingTips.add(_tips[27]);
      }
    }

    // En fazla 1 öneri döndür
    return matchingTips.take(1).toList();
  }
}
