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
        title: "Skin Type Quiz",
        description:
            "Answer the questions below to determine your skin type",
        questions: [
          QuizQuestion(
            id: "q1",
            question: "How does your face feel/look during the day?",
            options: [
              QuizOption(
                id: "a",
                text: "Shiny/oily all over the face",
                scoreMap: {"oily": 2},
              ),
              QuizOption(
                id: "b",
                text: "Shiny only in T-zone, cheeks are normal/dry",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "c",
                text: "Slight shine but controlled",
                scoreMap: {"normal": 1},
              ),
              QuizOption(
                id: "d",
                text: "No shine, feels dry during the day",
                scoreMap: {"dry": 2},
              ),
            ],
          ),
          QuizQuestion(
            id: "q2",
            question: "How does your skin feel after cleansing?",
            options: [
              QuizOption(
                id: "a",
                text: "Gets oily again quickly",
                scoreMap: {"oily": 2},
              ),
              QuizOption(
                id: "b",
                text: "Details tight/dry",
                scoreMap: {"dry": 2},
              ),
              QuizOption(
                id: "c",
                text: "T-zone oily, cheeks tight",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "d",
                text: "Balanced and comfortable",
                scoreMap: {"normal": 1},
              ),
              QuizOption(
                id: "e",
                text: "Burning/stinging sensation",
                scoreMap: {"sensitive": 2},
              ),
            ],
          ),
          QuizQuestion(
            id: "q3",
            question: "Which describes your pores best?",
            options: [
              QuizOption(
                id: "a",
                text: "Large and visible",
                scoreMap: {"oily": 2},
              ),
              QuizOption(
                id: "b",
                text: "Large in T-zone, small on cheeks",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "c",
                text: "Small/barely visible",
                scoreMap: {"dry": 2},
              ),
              QuizOption(
                id: "d",
                text: "Medium size, not very noticeable",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q4",
            question: "How frequent are acne/comedones (black/whiteheads)?",
            options: [
              QuizOption(
                id: "a",
                text: "Frequent and inflamed breakouts",
                scoreMap: {"acne_prone": 2, "oily": 1},
              ),
              QuizOption(
                id: "b",
                text: "Occasional breakouts",
                scoreMap: {"acne_prone": 1},
              ),
              QuizOption(id: "c", text: "Rarely", scoreMap: {"normal": 1}),
              QuizOption(
                id: "d",
                text: "Black/whiteheads especially in T-zone",
                scoreMap: {"acne_prone": 2, "combination": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q5",
            question:
                "Any conditions triggering redness, burning or stinging?",
            options: [
              QuizOption(
                id: "a",
                text: "Burning-stinging with some products like perfume/alcohol",
                scoreMap: {"sensitive": 2},
              ),
              QuizOption(
                id: "b",
                text: "Instant redness in hot/cold/wind",
                scoreMap: {"sensitive": 2},
              ),
              QuizOption(
                id: "c",
                text: "No obvious triggers",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q6",
            question: "Do you experience flakiness/dryness?",
            options: [
              QuizOption(
                id: "a",
                text: "Frequent and significant",
                scoreMap: {"dry": 2},
              ),
              QuizOption(
                id: "b",
                text: "Sometimes/seasonal",
                scoreMap: {"dry": 1},
              ),
              QuizOption(id: "c", text: "No", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q7",
            question: "How does your makeup behavior during the day? (if applicable)",
            options: [
              QuizOption(
                id: "a",
                text: "Slides off/fades quickly",
                scoreMap: {"oily": 2},
              ),
              QuizOption(
                id: "b",
                text: "Cracks/settles into lines in dry areas",
                scoreMap: {"dry": 2},
              ),
              QuizOption(
                id: "c",
                text: "T-zone shines while cheeks stay matte",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "d",
                text: "Generally balanced",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q8",
            question: "Which describes your skin status best at the end of the day?",
            options: [
              QuizOption(
                id: "a",
                text: "Shiny/oily feeling",
                scoreMap: {"oily": 2},
              ),
              QuizOption(
                id: "b",
                text: "T-zone oily, cheeks dry",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "c",
                text: "Tight/dry feeling",
                scoreMap: {"dry": 2},
              ),
              QuizOption(id: "d", text: "Balanced", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q9",
            question: "Are there visible capillaries (transparent, reddening skin)?",
            options: [
              QuizOption(
                id: "a",
                text: "Yes, easily reddens and visible capillaries",
                scoreMap: {"sensitive": 2},
              ),
              QuizOption(id: "b", text: "No", scoreMap: {"normal": 1}),
            ],
          ),
          QuizQuestion(
            id: "q10",
            question:
                "Does acne increase during hormonal periods (period/stress)?",
            options: [
              QuizOption(
                id: "a",
                text: "Yes, significant increase",
                scoreMap: {"acne_prone": 2},
              ),
              QuizOption(
                id: "b",
                text: "No/not sure",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q11",
            question: "How is your skin's general texture and thickness?",
            options: [
              QuizOption(
                id: "a",
                text: "Thicker, shiny look",
                scoreMap: {"oily": 1},
              ),
              QuizOption(
                id: "b",
                text: "Thin, sensitive look",
                scoreMap: {"sensitive": 1, "dry": 1},
              ),
              QuizOption(
                id: "c",
                text: "Soft and smooth",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
          QuizQuestion(
            id: "q12",
            question:
                "Cheeks vs T-zone: which one describes you better?",
            options: [
              QuizOption(
                id: "a",
                text: "Cheeks dry/normal, T-zone oily",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "b",
                text: "Cheeks oily, T-zone normal/dry",
                scoreMap: {"combination": 2},
              ),
              QuizOption(
                id: "c",
                text: "Everywhere balanced similarly",
                scoreMap: {"normal": 1},
              ),
            ],
          ),
        ],
        results: QuizResults(
          rules: [
            QuizRule(
              condition: "oily >= 8",
              skinType: "Oily Skin",
              description:
                  "Your skin is overactive in oil production. Large pores and shine are common.",
              icon: "💧",
              color: "pink",
            ),
            QuizRule(
              condition: "dry >= 6",
              skinType: "Dry Skin",
              description:
                  "Your skin lacks moisture. Flakiness and tightness are common.",
              icon: "🌵",
              color: "orange",
            ),
            QuizRule(
              condition: "combination >= 6",
              skinType: "Combination Skin",
              description:
                  "Your T-zone is oily, cheeks are dry. Different areas need different care.",
              icon: "🎭",
              color: "purple",
            ),
            QuizRule(
              condition: "sensitive >= 4",
              skinType: "Sensitive Skin",
              description:
                  "Your skin is sensitive to environmental factors. Redness and stinging are common.",
              icon: "🌸",
              color: "red",
            ),
            QuizRule(
              condition: "acne_prone >= 4",
              skinType: "Acne-Prone Skin",
              description:
                  "You struggle with acne and comedones. A special care routine is necessary.",
              icon: "🔴",
              color: "deepOrange",
            ),
            QuizRule(
              condition: "default",
              skinType: "Normal Skin",
              description:
                  "Your skin is balanced and healthy. You can maintain your current routine.",
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
        error = 'Error loading quiz: $e';
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
                'Loading quiz...',
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
                  child: const Text('Try Again'),
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
        body: const Center(child: Text('Quiz not found')),
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
                                'Question ${quizState.currentQuestionIndex + 1}/${quiz!.questions.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Continue to determine your skin type',
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
                          'Question ${quizState.currentQuestionIndex + 1}',
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
                            ? 'See Result'
                            : 'Continue',
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
                            'Congratulations! 🎉',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your skin type has been determined successfully',
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
                                    'Score Details',
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
                    'Restart Quiz',
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
      case 'oily':
        return 'Oily';
      case 'dry':
        return 'Dry';
      case 'combination':
        return 'Combination';
      case 'sensitive':
        return 'Sensitive';
      case 'acne_prone':
        return 'Acne-Prone';
      case 'normal':
        return 'Normal';
      default:
        return key;
    }
  }
}
