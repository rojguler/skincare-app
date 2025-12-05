import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/skin_quiz.dart';
import '../core/theme.dart';

class SkinQuizPage extends StatefulWidget {
  const SkinQuizPage({super.key});

  @override
  State<SkinQuizPage> createState() => _SkinQuizPageState();
}

class _SkinQuizPageState extends State<SkinQuizPage> {
  SkinQuiz? quiz;
  QuizState quizState = QuizState();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  // Quiz verilerini manuel olarak oluştur
  Future<void> _loadQuiz() async {
    try {
      // Quiz verilerini manuel olarak oluştur
      final quiz = SkinQuiz(
        title: "Cilt Tipi Belirleme Testi",
        description:
            "Cildinizin tipini belirlemek için aşağıdaki soruları yanıtlayın",
        questions: [
          QuizQuestion(
            id: "q1",
            question: "Gün içinde yüzündeki parlama/yağlanma durumu nasıl?",
            options: [
              QuizOption(
                id: "a",
                text: "Tüm yüzde hızlı parlama/yağlanma",
                scoreMap: {"yagli": 2},
              ),
              QuizOption(
                id: "b",
                text: "Sadece T bölgesinde parlama, yanaklar normal/kuru",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "c",
                text: "Hafif parlama var ama kontrol altında",
                scoreMap: {"normal": 1},
              ),
              QuizOption(
                id: "d",
                text: "Parlama yok, gün içinde kuruluk hissi oluyor",
                scoreMap: {"kuru": 2},
              ),
            ],
          ),
          QuizQuestion(
            id: "q2",
            question: "Yüzünü temizledikten sonra cildin nasıl hissediliyor?",
            options: [
              QuizOption(
                id: "a",
                text: "Kısa sürede tekrar yağlanıyor",
                scoreMap: {"yagli": 2},
              ),
              QuizOption(
                id: "b",
                text: "Gergin/kurumuş hissediyorum",
                scoreMap: {"kuru": 2},
              ),
              QuizOption(
                id: "c",
                text: "T bölgesi yağlı, yanaklar gergin",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "d",
                text: "Dengeli ve rahat",
                scoreMap: {"normal": 1},
              ),
              QuizOption(
                id: "e",
                text: "Yanma/batma oluyor",
                scoreMap: {"hassas": 2},
              ),
            ],
          ),
          QuizQuestion(
            id: "q3",
            question: "Gözenek görünümü en çok hangisine benziyor?",
            options: [
              QuizOption(
                id: "a",
                text: "Geniş ve belirgin",
                scoreMap: {"yagli": 2},
              ),
              QuizOption(
                id: "b",
                text: "T bölgede geniş, yanaklarda küçük",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "c",
                text: "Küçük/neredeyse görünmez",
                scoreMap: {"kuru": 2},
              ),
              QuizOption(
                id: "d",
                text: "Orta boy, çok dikkat çekmiyor",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q4",
            question: "Sivilce/komedon (siyah-beyaz nokta) sıklığı nasıl?",
            options: [
              QuizOption(
                id: "a",
                text: "Sık ve iltihaplı ataklar yaşıyorum",
                scoreMap: {"akneli": 2, "yagli": 1},
              ),
              QuizOption(
                id: "b",
                text: "Ara sıra oluyor",
                scoreMap: {"akneli": 1},
              ),
              QuizOption(id: "c", text: "Nadiren", scoreMap: {"normal": 1}),
              QuizOption(
                id: "d",
                text: "Özellikle T bölgesinde siyah/beyaz noktalar",
                scoreMap: {"akneli": 2, "karma": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q5",
            question:
                "Kızarıklık, yanma veya batma tetikleyen durumlar var mı?",
            options: [
              QuizOption(
                id: "a",
                text: "Parfüm/alkol gibi bazı ürünlerde yanma-batma",
                scoreMap: {"hassas": 2},
              ),
              QuizOption(
                id: "b",
                text: "Sıcak/soğuk/rüzgarda anında kızarma",
                scoreMap: {"hassas": 2},
              ),
              QuizOption(
                id: "c",
                text: "Belirgin tetikleyici yok",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q6",
            question: "Pul pul dökülme/kuruluk yaşıyor musun?",
            options: [
              QuizOption(
                id: "a",
                text: "Sık sık ve belirgin",
                scoreMap: {"kuru": 2},
              ),
              QuizOption(
                id: "b",
                text: "Bazen/mevsimsel",
                scoreMap: {"kuru": 1},
              ),
              QuizOption(id: "c", text: "Hayır", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q7",
            question: "Makyajın gün içinde nasıl davranıyor? (yapıyorsan)",
            options: [
              QuizOption(
                id: "a",
                text: "Hızla akıyor/bozuluyor",
                scoreMap: {"yagli": 2},
              ),
              QuizOption(
                id: "b",
                text: "Kuru bölgelerde parçalanıyor/çizgilere doluyor",
                scoreMap: {"kuru": 2},
              ),
              QuizOption(
                id: "c",
                text: "T bölgesi parlarken yanaklar mat kalıyor",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "d",
                text: "Genelde dengeli",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q8",
            question: "Günün sonunda yüzünün genel durumu en çok hangisi?",
            options: [
              QuizOption(
                id: "a",
                text: "Parlak/yağlı his",
                scoreMap: {"yagli": 2},
              ),
              QuizOption(
                id: "b",
                text: "T bölgesi yağlı, yanaklar kuru",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "c",
                text: "Gergin/kuru his",
                scoreMap: {"kuru": 2},
              ),
              QuizOption(id: "d", text: "Dengeli", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q9",
            question: "Kılcal damar görünürlüğü (şeffaf, kızaran cilt) var mı?",
            options: [
              QuizOption(
                id: "a",
                text: "Evet, kolay kızarma ve kılcal damar görünürlüğü",
                scoreMap: {"hassas": 2},
              ),
              QuizOption(id: "b", text: "Hayır", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q10",
            question:
                "Hormonal dönemlerde (adet/stres) sivilcelenme artıyor mu?",
            options: [
              QuizOption(
                id: "a",
                text: "Evet, belirgin artış oluyor",
                scoreMap: {"akneli": 2},
              ),
              QuizOption(
                id: "b",
                text: "Hayır/emin değilim",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q11",
            question: "Cildinin genel dokusu ve kalınlığı nasıl?",
            options: [
              QuizOption(
                id: "a",
                text: "Daha kalın, parlak görünümlü",
                scoreMap: {"yagli": 1},
              ),
              QuizOption(
                id: "b",
                text: "İnce, hassas görünümlü",
                scoreMap: {"hassas": 1, "kuru": 1},
              ),
              QuizOption(
                id: "c",
                text: "Yumuşak ve pürüzsüz",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q12",
            question:
                "Cheeks vs T-zone: aşağıdakilerden hangisi seni daha iyi anlatır?",
            options: [
              QuizOption(
                id: "a",
                text: "Cheeks kuru/normal, T-zone yağlı",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "b",
                text: "Cheeks yağlı, T-zone normal/kuru",
                scoreMap: {"karma": 2},
              ),
              QuizOption(
                id: "c",
                text: "Her yer benzer dengede",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
        ],
        results: QuizResults(
          rules: [
            QuizRule(
              condition: "yagli >= 8",
              skinType: "Yağlı Cilt",
              description:
                  "Cildiniz yağ üretiminde fazla aktif. Gözenekler geniş ve parlama sık görülür.",
              icon: "💧",
              color: "pink",
            ),
            QuizRule(
              condition: "kuru >= 6",
              skinType: "Kuru Cilt",
              description:
                  "Cildiniz nem eksikliği yaşıyor. Pul pul dökülme ve gerginlik hissi yaygın.",
              icon: "🌵",
              color: "orange",
            ),
            QuizRule(
              condition: "karma >= 6",
              skinType: "Karma Cilt",
              description:
                  "T bölgeniz yağlı, yanaklarınız kuru. Farklı bölgeler için farklı bakım gerekir.",
              icon: "🎭",
              color: "purple",
            ),
            QuizRule(
              condition: "hassas >= 4",
              skinType: "Hassas Cilt",
              description:
                  "Cildiniz çevresel faktörlere karşı hassas. Kızarıklık ve yanma sık görülür.",
              icon: "🌸",
              color: "red",
            ),
            QuizRule(
              condition: "akneli >= 4",
              skinType: "Akneli Cilt",
              description:
                  "Sivilce ve komedonlarla mücadele ediyorsunuz. Özel bakım rutini gerekli.",
              icon: "🔴",
              color: "deepOrange",
            ),
            QuizRule(
              condition: "default",
              skinType: "Normal Cilt",
              description:
                  "Cildiniz dengeli ve sağlıklı. Mevcut rutininizi koruyabilirsiniz.",
              icon: "✨",
              color: "green",
            ),
          ],
        ),
      );

      setState(() {
        this.quiz = quiz;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Quiz yüklenirken hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  // Cevap seçildiğinde çağrılır
  void _selectAnswer(
    String questionId,
    String optionId,
    Map<String, int> scoreMap,
  ) {
    setState(() {
      // Cevabı kaydet
      Map<String, String> newAnswers = Map.from(quizState.answers);
      newAnswers[questionId] = optionId;

      // Skorları güncelle
      Map<String, int> newScores = Map.from(quizState.scores);
      scoreMap.forEach((key, value) {
        newScores[key] = (newScores[key] ?? 0) + value;
      });

      quizState = quizState.copyWith(answers: newAnswers, scores: newScores);
    });
  }

  // Sonraki soruya geç
  void _nextQuestion() {
    if (quizState.currentQuestionIndex < (quiz?.questions.length ?? 0) - 1) {
      setState(() {
        quizState = quizState.copyWith(
          currentQuestionIndex: quizState.currentQuestionIndex + 1,
        );
      });
    } else {
      // Quiz tamamlandı
      setState(() {
        quizState = quizState.copyWith(isCompleted: true);
      });
    }
  }

  // Quiz'i yeniden başlat
  void _restartQuiz() {
    setState(() {
      quizState = QuizState();
    });
  }

  // Cilt tipini hesapla
  QuizRule? _calculateSkinType() {
    if (quiz == null) return null;

    for (QuizRule rule in quiz!.results.rules) {
      if (rule.condition == 'default') continue;

      // Koşul kontrolü (basit string parsing)
      if (rule.condition.contains('>=')) {
        final parts = rule.condition.split('>=');
        final skinType = parts[0].trim();
        final threshold = int.parse(parts[1].trim());

        if ((quizState.scores[skinType] ?? 0) >= threshold) {
          return rule;
        }
      }
    }

    // Default kural
    return quiz!.results.rules.last;
  }

  // Renk getir - tema renklerini kullan
  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'pink':
        return AppColors.pink;
      case 'orange':
        return AppColors.yellow;
      case 'purple':
        return AppColors.marron;
      case 'red':
        return AppColors.pink;
      case 'deeporange':
        return AppColors.marron;
      case 'green':
        return AppColors.yellow;
      default:
        return AppColors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.pink),
              const SizedBox(height: 16),
              Text(
                'Quiz yükleniyor...',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quiz == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Quiz bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          quiz!.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pink,
        elevation: 0,
      ),
      body: quizState.isCompleted
          ? _buildResultScreen()
          : _buildQuestionScreen(),
    );
  }

  // Soru ekranı - Kompakt ve Modern Tasarım
  Widget _buildQuestionScreen() {
    final currentQuestion = quiz!.questions[quizState.currentQuestionIndex];
    final currentAnswer = quizState.answers[currentQuestion.id];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.white, AppColors.pink.withOpacity(0.03)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kompakt ilerleme çubuğu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.pink.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                            gradient: LinearGradient(
                              colors: [
                                AppColors.pink,
                                AppColors.pink.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Soru ${quizState.currentQuestionIndex + 1}/${quiz!.questions.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cilt tipinizi belirlemek için devam edin',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // İlerleme çubuğu
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value:
                            (quizState.currentQuestionIndex + 1) /
                            quiz!.questions.length,
                        backgroundColor: AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.pink,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kompakt soru kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.yellow.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.help_outline,
                            color: AppColors.yellow,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Soru ${quizState.currentQuestionIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.yellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQuestion.question,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kompakt seçenekler
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    final isSelected = currentAnswer == option.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(
                          currentQuestion.id,
                          option.id,
                          option.scoreMap,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.pink,
                                      AppColors.pink.withOpacity(0.8),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pink
                                  : AppColors.lightGray.withOpacity(0.5),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.pink.withOpacity(0.2)
                                    : AppColors.shadowLight.withOpacity(0.5),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.lightGray.withOpacity(0.3),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.pink
                                        : AppColors.textSecondary.withOpacity(
                                            0.3,
                                          ),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 12,
                                        color: AppColors.pink,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Kompakt ileri butonu
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: currentAnswer != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentAnswer != null
                        ? AppColors.pink
                        : AppColors.lightGray,
                    foregroundColor: AppColors.white,
                    elevation: currentAnswer != null ? 6 : 0,
                    shadowColor: AppColors.pink.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quizState.currentQuestionIndex ==
                                quiz!.questions.length - 1
                            ? 'Sonucu Gör'
                            : 'Devam Et',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        quizState.currentQuestionIndex ==
                                quiz!.questions.length - 1
                            ? Icons.emoji_events
                            : Icons.arrow_forward_ios,
                        size: 16,
                      ),
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

  // Sonuç ekranı - Geliştirilmiş tasarım
  Widget _buildResultScreen() {
    final result = _calculateSkinType();
    if (result == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            _getColorFromString(result.color).withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Başarı mesajı - Kompakt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.pink.withOpacity(0.1),
                      AppColors.yellow.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.pink.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.pink,
                            AppColors.pink.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tebrikler! 🎉',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cilt tipiniz başarıyla belirlendi',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sonuç kartı - Scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // İkon ve başlık - Ultra Kompakt
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getColorFromString(
                                  result.color,
                                ).withOpacity(0.2),
                                _getColorFromString(
                                  result.color,
                                ).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                result.icon,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.skinType,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Açıklama - Ultra Kompakt
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            result.description,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Skor detayları - Ultra Kompakt
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.white,
                                AppColors.yellow.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.lightGray.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.analytics,
                                      color: AppColors.yellow,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Skor Detayları',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...quizState.scores.entries.map(
                                (entry) => Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.lightGray.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getSkinTypeName(entry.key),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getColorFromString(
                                            result.color,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          entry.value.toString(),
                                          style: GoogleFonts.poppins(
                                            color: _getColorFromString(
                                              result.color,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
              const SizedBox(height: 16),

              // Kompakt tekrar başlat butonu
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Quiz\'i Tekrar Başlat',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: AppColors.white,
                    elevation: 6,
                    shadowColor: AppColors.pink.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cilt tipi adını getir
  String _getSkinTypeName(String key) {
    switch (key) {
      case 'yagli':
        return 'Yağlı';
      case 'kuru':
        return 'Kuru';
      case 'karma':
        return 'Karma';
      case 'hassas':
        return 'Hassas';
      case 'akneli':
        return 'Akneli';
      case 'normal':
        return 'Normal';
      default:
        return key;
    }
  }
}
