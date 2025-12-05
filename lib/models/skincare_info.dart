class SkincareInfo {
  final String id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String howItWorks;
  final List<String> benefits;
  final List<String> usageTips;
  final List<String> worksWellWith;
  final String iconPath; // For future icon implementation
  final String brand; // FODIVO brand

  SkincareInfo({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.howItWorks,
    required this.benefits,
    required this.usageTips,
    required this.worksWellWith,
    required this.iconPath,
    required this.brand,
  });
}

// Sample data for 10 skincare ingredients
class SkincareInfoData {
  static final List<SkincareInfo> skincareIngredients = [
    SkincareInfo(
      id: 'retinol',
      title: 'RETINOL',
      shortDescription: 'Anti-aging ve akne tedavisi',
      longDescription:
          'Retinol, cildin yenilenmesini hızlandıran ve yaşlanma belirtilerini azaltan güçlü bir bileşendir.',
      howItWorks:
          'Retinol genellikle gece uygulanan, düşük konsantrasyondan başlayıp tolerans arttıkça dozu/günlüğü artırılan bir aktiftir. Temiz cilde, ince bir miktar olarak uygulanır; başlangıçta haftada 2–3 gece ile başlanıp cilt alışınca her geceye çıkarılabilir. Göz çevresi çok yakınından kaçınılmalı ve her sabah yüksek SPF içeren güneş koruyucu kullanılmalıdır.',
      benefits: [
        'Hücre yenilenmesini hızlandırır; ince çizgi ve kırışıklık görünümünü azaltır.',
        'Kolajen sentezini destekleyerek cilt sıkılığını artırır.',
        'Akne ve tıkalı gözeneklerin iyileştirilmesine yardımcı olur.',
        'Güneş kaynaklı pigmentasyonda düzelme sağlar (düzenli kullanımda).',
      ],
      usageTips: [
        'Başlangıç: Haftada 2 geceyle başla, cilt rahatça tolere ederse doz/dereceyi artır.',
        'İnce bir tabaka yeterlidir — fazla sürmek irritasyona yol açar.',
        'Retinol + gündüz güneş kremi = zorunlu (AHA/BHA/retinoidler güneşe duyarlılığı artırır).',
        'Aşırı kızarıklık/soyulma olursa uygulamayı azalt veya dermatoloğa danış.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (nemlendirme için)',
        'Peptidler (yenileyici etkiyi tamamlar)',
        'Niacinamide (irritasyonu azaltmaya yardımcı olabilir)',
        'Ceramidler (cilt bariyerini destekler)',
      ],
      iconPath: 'assets/icons/retinol.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'vitamin_c',
      title: 'VİTAMİN C',
      shortDescription: 'Antioksidan ve parlaklık',
      longDescription:
          'Vitamin C, cildi serbest radikallerden koruyan ve parlaklık veren güçlü bir antioksidandır.',
      howItWorks:
          'Vitamin C serumu sabah rutininin erken adımlarından biri olarak (temizlemeden sonra, nemlendirici ve güneş kreminden önce) uygulanır. Stabil formül (oksitlenmeye dayanıklı) seçilmeli; pH ve konsantrasyon ürüne göre değişir (yüksek konsantrasyon daha etkili ama hassasiyete yol açabilir).',
      benefits: [
        'Güçlü antioksidan: serbest radikallere karşı korur ve UV hasarına bağlı oksidatif stresi azaltır.',
        'Melanin baskılayarak cilt tonunu aydınlatır ve koyu lekelerin görünümünü azaltır.',
        'Kolajen sentezini destekleyerek cilt elastikiyetini iyileştirir.',
        'Cilt dokusunu güçlendirir, parlaklık ve eşit ton sağlar.',
      ],
      usageTips: [
        'Sabah kullanımı önerilir — antioksidan koruma için ideal.',
        'Vitamin E + ferulik asit kombinasyonları etkiyi artırır.',
        'Oksitlenmiş ürünleri (kahverengileşme kokusu) kullanma; verim düşer.',
        'Benzoyl peroxide ile eş zamanlı kullanmak irritasyon veya karşı etki oluşturabilir.',
      ],
      worksWellWith: [
        'Vitamin E + Ferulic Acid (sinerjiyle antioksidan etkiyi artırır)',
        'Hyaluronic Acid (nemlendirme, taşıma etkisi)',
        'Niacinamide (bazı formüllerde birlikte uyumludur ama dikkatli ol)',
        'Sunscreen (günlük UV koruma ile birlikte kullanılmalı)',
      ],
      iconPath: 'assets/icons/vitamin_c.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'hyaluronic_acid',
      title: 'HYALURONIC ACID',
      shortDescription: 'Nemlendirme ve dolgunluk',
      longDescription:
          'Hyaluronic Acid, cildin nem seviyesini artıran ve dolgunluk veren doğal bir nemlendiricidir.',
      howItWorks:
          'Hyaluronik asit serumları temiz cilde, tercihen hafif nemli cilde uygulanır (su veya toner sonrası) — böylece molekül çevresinde su bulunur ve etkisi artar. Ardından nemi kilitlemek için üzerine nemlendirici/krema uygulanmalıdır. Sabah ve/veya akşam kullanılabilir.',
      benefits: [
        'Güçlü su tutma kapasitesiyle anlık ve uzun vadeli nemlendirme sağlar.',
        'Cildin dolgunluğunu artırır; ince çizgilerin görünümünü azaltır.',
        'Yara iyileşmesini ve bariyer fonksiyonunu destekler.',
        'Her cilt tipine uygun, tahriş riski düşük bir nemlendiricidir.',
      ],
      usageTips: [
        'Nemli cilde uygula, sonra yağ veya krem ile kilitle.',
        'Tek başına yeterli hidrasyon sağlamıyorsa, bir nemlendirici ile tamamla.',
        'Her cilt tipine uygun; kuru ciltlerde daha sık fayda görülür.',
        'Konsantrasyon çok yüksek olan ürünler yerine iyi formüle edilmiş serumlar tercih et.',
      ],
      worksWellWith: [
        'Vitamin C (parlaklık + nem desteği)',
        'Retinol (nemlendirme ile irritasyonu azaltır)',
        'Peptidler (yenileme + nemlendirme kombinasyonu)',
        'Ceramidler (bariyer onarımına yardımcı olur)',
      ],
      iconPath: 'assets/icons/hyaluronic_acid.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'niacinamide',
      title: 'NİACİNAMİDE',
      shortDescription: 'Gözenek sıkılaştırma',
      longDescription:
          'Niacinamide, gözenekleri sıkılaştıran ve cilt tonunu eşitleyen çok yönlü bir bileşendir.',
      howItWorks:
          'Niacinamide genellikle sabah veya akşam, temizlemeyi takiben ve nemlendiriciden önce uygulanır. Konsantrasyonlar genelde %2–10 aralığında kullanılır; hassasiyeti düşük bir bileşen olduğundan çoğu cilt tipinde güvenlidir. Retinol ile aynı rutinde kullanılabilir (bazı kullanıcılar birlikte uygulamayı tercih eder).',
      benefits: [
        'Cilt bariyerini güçlendirir ve nem kaybını azaltır.',
        'Gözenek görünümünü, cilt dokusunu ve yağ dengesini iyileştirir.',
        'Anti-inflamatuar etkisiyle kızarıklık, akne ve rosacea semptomlarını hafifletebilir.',
        'Pigmentasyon ve hiperpigmentasyonun azalmasına yardımcı olur.',
      ],
      usageTips: [
        '2–10% arası konsantrasyon idealdir; yüksek konsantrasyonlarda patch testi yap.',
        'Sabah uygulayıp akşam retinol kullanmak dengeli bir yaklaşım sağlar.',
        'Niacinamide çoğu içerikle uyumludur; C vitamini ile bazı formüllerde reaksiyon endişesi olsa da günümüzde çoğu ürün stabil kalacak şekilde formüle ediliyor.',
        'Gözenek kontrolü isteniyorsa çinko içeren formüller tercih edilebilir.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (nem desteği)',
        'Peptidler (onarıcı etkiyi tamamlar)',
        'Ceramidler (bariyer + onarım kombinasyonu)',
        'Retinol (irritasyonu azaltmaya yardımcı olabilir)',
      ],
      iconPath: 'assets/icons/niacinamide.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'salicylic_acid',
      title: 'SALICYLIC ACID',
      shortDescription: 'Akne ve gözenek temizleme',
      longDescription:
          'Salicylic Acid, gözenekleri derinlemesine temizleyen ve akne oluşumunu önleyen bir BHA\'dır.',
      howItWorks:
          'Salisilik asit genellikle temizleme sonrası tonik/serum veya spot tedavi olarak uygulanır. Yüz temizleyicilerinde (%0.5–2%) günlük kullanıma uygundur; leave-on (bırakılan) solüsyonlarda daha düşük frekans veya düşük konsantrasyonla başlanmalıdır. Aşırı kuruma veya soyulma olursa kullanım sıklığı azaltılmalıdır. Güneş koruması önemlidir.',
      benefits: [
        'Yağ çözünürlüğü sayesinde gözenek içine nüfuz edip tıkanıklığı çözer; siyah nokta ve beyaz nokta azaltır.',
        'Peeling etkisiyle ölü deri hücrelerini uzaklaştırır; cilt dokusunu düzeltir.',
        'Antiinflamatuar özellikleriyle akne ve sivilce tedavisine yardımcı olur.',
        'Sebum üretimini düzenlemeye destek vererek parlamayı azaltır.',
      ],
      usageTips: [
        'Akne ve gözenek problemleri için haftada 2–5 kez, cilt toleransına göre artır.',
        'İnce bir tabaka uygulandıktan sonra mutlaka nemlendirici kullan.',
        'Yüz temizleyicilerinde (wash-off) günlük kullanım daha toleranslıdır.',
        'Güçlü kimyasal peeling kombinasyonlarından kaçın ya da dermatolog gözetimiyle kullan.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (kuruluğu azaltmak için)',
        'Niacinamide (iltiabı azaltmaya yardımcı)',
        'Azelaic Acid (akne + renk düzensizlikleri için tamamlayıcı)',
        'Benzoyl Peroxide (ölümcül kombinasyon değil ama dikkatle kullan)',
      ],
      iconPath: 'assets/icons/salicylic_acid.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'peptides',
      title: 'PEPTIDES',
      shortDescription: 'Kolajen üretimi',
      longDescription:
          'Peptides, cildin kolajen üretimini artıran ve yaşlanma belirtilerini azaltan amino asit zincirleridir.',
      howItWorks:
          'Peptid içeren serum ve nemlendiriciler sabah veya akşam kullanılabilir; genelde su bazlı formüllerde iyi çözünürler. Peptidler sürekli ve düzenli kullanıldığında daha etkili olur çünkü cilt yapısını zamanla desteklerler. Çok aktif asitlerle (yüksek konsantrasyon AHA/BHA) doğrudan etkileşimleri genelde sorun olmaz fakat formülasyonlara dikkat edilmeli.',
      benefits: [
        'Cilt onarımını destekleyerek kolajen ve elastin üretimini teşvik edebilir.',
        'İnce çizgi ve kırışıklık görünümünü azaltmaya yardımcı olur.',
        'Anti-inflamatuar ve yara iyileştirici etkiler gösterebilir.',
        'Cilt bariyer fonksiyonunu iyileştirmeye katkıda bulunur.',
      ],
      usageTips: [
        'Sabah veya akşam düzenli kullanım önerilir (günlük rutine ekle).',
        'Peptidler genelde diğer aktiflerle uyumludur; retinol ile kombine edilebilir.',
        'Serum formunda konsantrasyonu ve dağılımı kontrol et.',
        'Kısa vadede değil, orta-uzun vadede (4–12 hafta) etkileri gözlenir.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (nemlendirme + taşıma)',
        'Niacinamide (onarıcı etkiyi güçlendirir)',
        'Retinol (yenilenme + stimulasyon kombinasyonu)',
        'Ceramidler (bariyer desteği)',
      ],
      iconPath: 'assets/icons/peptides.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'ceramides',
      title: 'CERAMIDES',
      shortDescription: 'Cilt bariyeri koruma',
      longDescription:
          'Ceramides, cildin doğal bariyerini güçlendiren ve nem kaybını önleyen yağ molekülleridir.',
      howItWorks:
          'Ceramid içeren kremler ve losyonlar genelde rutinin son adımı olarak, temizleme ve serum sonrası uygulanır. Sabah ve akşam kullanılabilir; özellikle nemlendirici görevi görürler ve retinol veya asit gibi aktiflerin yol açtığı hassasiyeti azaltmaya yardımcı olurlar.',
      benefits: [
        'Epidermal bariyeri güçlendirir; su kaybını azaltır ve nemi korur.',
        'Kuru, hassas veya atopik ciltlerde bariyer onarımını destekler.',
        'Enflamasyonu azaltmaya yardımcı olabilir ve dış etkenlere karşı koruma sağlar.',
        'Yaşla birlikte azalan doğal ceramid seviyelerini yerine koyarak daha sağlıklı bir cilt görünümü sağlar.',
      ],
      usageTips: [
        'Sabah ve akşam düzenli olarak kullan; özellikle gece bariyer onarımı için faydalıdır.',
        'Kuru ve hassas ciltlerde önce serumlardan sonra yoğun ceramid kremi uygula.',
        'Aşırı kuruluk/hassasiyet durumunda serbest bırakılan (leave-on) ceramid ürünleri tercih et.',
        'Retinol/asit kombinasyonlarında bariyer desteği için ceramid ekle.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (nemin tutulması için)',
        'Niacinamide (bariyer + reparasyon kombinasyonu)',
        'Peptidler (onarım ve yeniden yapılandırma)',
        'Kolesterol ve yağ asitleri (lipid karışımı, bariyer fonksiyonunu tamamlar)',
      ],
      iconPath: 'assets/icons/ceramides.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'aha',
      title: 'ALPHA HYDROXY ACIDS',
      shortDescription: 'Yüzey peeling',
      longDescription:
          'AHA\'lar, cildin yüzeyini soyan ve daha parlak bir görünüm sağlayan asitlerdir.',
      howItWorks:
          'AHA\'lar tonik, serum veya peeling (wash-off/leave-on) formunda kullanılır. Düşük konsantrasyonlarda günlük kullanıma uygun ürünler vardır; daha güçlü (yüksek % AHA) formüller haftalık \'maske/peel\' şeklinde dermatolog veya kullanım talimatına göre uygulanmalıdır. Güneş fotosensitivitesi artırdıkları için uygulama sonrası güneş kremi şarttır.',
      benefits: [
        'Yüzeysel kimyasal eksfoliasyon ile cilt dokusunu düzeltir ve parlaklık verir.',
        'Pigmentasyon, ince kırışıklık ve güneş hasarı görünümünü azaltmaya yardımcı olur.',
        'Cilt yüzeyindeki ölü hücreleri uzaklaştırarak ürün nüfuzunu artırır.',
        'Düzenli kullanımda kolajen üretimini uyarabilir.',
      ],
      usageTips: [
        'Başlangıçta düşük sıklık ve düşük konsantrasyonla başla (ör. %5–8 Laktik).',
        'Günlük güneş koruması kullan; AHA kullanımı güneşe hassasiyet artışı yapar.',
        'İnce, kuru veya hassas ciltlerde laktik asit (daha nazik) tercih edilebilir.',
        'Aynı gecede birden fazla güçlü eksfoliyan (ör. AHA+BHA+retinol) kullanmaktan kaçın.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (eksfoliasyondan sonra nemlendirme)',
        'Peptidler (yenilenme desteği)',
        'Niacinamide (irritasyonu hafifletebilir)',
        'Sunscreen (zorunlu)',
      ],
      iconPath: 'assets/icons/aha.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'bha',
      title: 'BETA HYDROXY ACIDS',
      shortDescription: 'Derin gözenek temizleme',
      longDescription:
          'BHA\'lar, yağda çözünen asitlerdir ve gözeneklerin derinliklerine nüfuz eder.',
      howItWorks:
          'BHA ürünleri genelde temizleme sonrası leave-on tonik/serum veya temizleyici (wash-off) şeklinde kullanılır. İlk etapta seyrek uygulama (haftada 2–3) ve düşük konsantrasyon önerilir; cilt alıştıkça kullanım arttırılabilir. Nemlendirme ve güneş koruma ile kombinlemeyi unutma.',
      benefits: [
        'Yağda çözünebilir yapısı sayesinde gözenek içi sebumu çözer ve siyah nokta/komedonları azaltır.',
        'Antiinflamatuar özellikleri ile sivilceyi yatıştırmaya yardımcı olur.',
        'Cilt yüzeyini ve gözenek yapısını düzeltir; pürüzsüzleştirir.',
        'Yağlı ve akneye eğilimli cilt tipleri için özellikle uygundur.',
      ],
      usageTips: [
        'Gözenek tıkanıklığı ve siyah nokta problemi varsa BHA rutinine dahil et.',
        'Yüksek konsantrasyonlarda kuruluk yaratabileceğinden nemlendirici ile dengele.',
        'Retinol ve güçlü eksfoliantlarla aynı anda agresif reaksiyon olabilir — sıralamaya dikkat et.',
        'Özellikle yağlı/karma ciltlerde sabah veya akşam kullanılabilir; toleransa göre ayarla.',
      ],
      worksWellWith: [
        'Hyaluronic Acid (nem desteği)',
        'Niacinamide (iltiabı azaltmaya yardımcı)',
        'Azelaic Acid (akne+lekeler için tamamlayıcı)',
        'Ceramidler (bariyer desteği)',
      ],
      iconPath: 'assets/icons/bha.png',
      brand: 'FODIVO',
    ),
    SkincareInfo(
      id: 'centella_asiatica',
      title: 'CENTELLA ASIATICA',
      shortDescription: 'Yara iyileştirme',
      longDescription:
          'Centella Asiatica, cildin iyileşme sürecini hızlandıran ve yatıştırıcı etkili bir bitki özüdür.',
      howItWorks:
          'Centella içeren serum/kremler genelde temiz cilde uygulanır; hassas veya retinol/kimyasal peeling sonrası yatış için ideal destek üründür. Günde 1–2 kez kullanılabilir; özellikle tahriş ve kızarıklık gözlemlendiğinde uygulama rahatlatıcı olur.',
      benefits: [
        'Anti-inflamatuar ve yatıştırıcı özellikleriyle hassas ve kızarık ciltleri sakinleştirir.',
        'Yara iyileşmesini ve doku onarımını destekleyen bileşenler (madecassoside vb.) içerir.',
        'Antioksidan etkilerle cildi çevresel hasarlardan korumaya yardımcı olur.',
        'Nemlendirme ve bariyer onarımına dolaylı katkı sağlar.',
      ],
      usageTips: [
        'Retinol/asit kullanımı sonrası yatıştırıcı olarak ekle (soothing step).',
        'Yara/iz onarımını desteklemek için düzenli kullanım gerekebilir.',
        'Hassas ciltlerde günlük nemlendirici olarak tercih edilebilir.',
        'Formül içindeki aktif konsantrasyon ve madecassoside miktarına dikkat et.',
      ],
      worksWellWith: [
        'Niacinamide (irritasyon azaltma + onarım)',
        'Hyaluronic Acid (nemlendirme)',
        'Ceramidler (bariyer desteği)',
        'Peptidler (yenilenme desteği)',
      ],
      iconPath: 'assets/icons/centella_asiatica.png',
      brand: 'FODIVO',
    ),
  ];
}
