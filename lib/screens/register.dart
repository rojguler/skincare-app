import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme.dart';
import '../services/firebase_service.dart';
import '../services/local_auth_service.dart';
import 'login.dart';
import 'welcome_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form validation states
  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Add listeners for real-time validation
    _nameCtrl.addListener(_validateName);
    _emailCtrl.addListener(_validateEmail);
    _passCtrl.addListener(_validatePassword);
    _confirmPassCtrl.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameCtrl.text.trim().length >= 2;
    });
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(_emailCtrl.text.trim());
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passCtrl.text.length >= 6;
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid = _confirmPassCtrl.text == _passCtrl.text;
    });
  }

  Future<void> _handleRegister() async {
    // Form validasyonu
    _validateName();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (!_isNameValid ||
        !_isEmailValid ||
        !_isPasswordValid ||
        !_isConfirmPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen tüm alanları doğru şekilde doldurun'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (!_acceptedTerms || !_acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Lütfen şartları ve gizlilik politikasını kabul edin',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    _hapticFeedback();

    try {
      print('📝 KAYIT BAŞLADI: ${_emailCtrl.text.trim()}');
      
      // Önce Firebase ile dene
      try {
        await FirebaseService.createUserWithEmailAndPassword(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
        );
        print('✅ FIREBASE KAYIT BAŞARILI!');
        
        // Profil bilgilerini Firebase'e kaydet
        await FirebaseService.saveProfile({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'registeredAt': DateTime.now().toIso8601String(),
        });
      } catch (firebaseError) {
        print('⚠️ Firebase kayıt hatası, Local Auth kullanılıyor...');
        
        // Firebase başarısız, local auth kullan
        await LocalAuthService.register(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
          _nameCtrl.text.trim(),
        );
        print('✅ LOCAL AUTH KAYIT BAŞARILI!');
      }

      // Profil bilgilerini local'e de kaydet (hybrid)
      if (!kIsWeb) {
        try {
          final profileBox = Hive.box('profile');
          await profileBox.put('name', _nameCtrl.text.trim());
          await profileBox.put('email', _emailCtrl.text.trim());
        } catch (e) {
          print('Hive profile save error: $e');
        }
      }

      if (mounted) {
        // Ana sayfaya yönlendir
        Navigator.pushReplacementNamed(context, '/home');
        
        // Başarı mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Hoş geldin ${_nameCtrl.text}! Hesabın oluşturuldu'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('❌ KAYIT HATASI: $e');
      
      if (mounted) {
        // Exception mesajını göster
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Text(
          'Kullanım Şartları',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'GlowSun uygulamasını kullanarak aşağıdaki şartları kabul etmiş olursunuz:\n\n'
          '• Kişisel verilerinizin güvenli şekilde saklanması\n'
          '• Uygulama içeriğinin kişisel kullanım için olduğu\n'
          '• Cilt bakımı önerilerinin genel bilgi amaçlı olduğu\n'
          '• Profesyonel tıbbi tavsiye yerine geçmediği',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anladım',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: Text(
          'Gizlilik Politikası',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Gizliliğiniz bizim için önemli:\n\n'
          '• Kişisel verileriniz cihazınızda güvenle saklanır\n'
          '• Üçüncü taraflarla paylaşılmaz\n'
          '• Verileriniz şifrelenerek korunur\n'
          '• İstediğiniz zaman verilerinizi silebilirsiniz',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anladım',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isValid = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? AppColors.pink.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.lightPink.withValues(alpha: 0.3),
              AppColors.pink.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Simple Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          _hapticFeedback();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const WelcomePage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return SlideTransition(
                                      position: animation.drive(
                                        Tween(
                                          begin: const Offset(-1.0, 0.0),
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(curve: Curves.easeInOut),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Simple Logo
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        size: 35,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Simple Title
                    Text(
                      'Hesap Oluştur',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'GlowSun ailesine katıl',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Simple Form
                    Column(
                      children: [
                        // Name Field
                        _buildInputField(
                          controller: _nameCtrl,
                          hint: 'Ad Soyad',
                          icon: Icons.person_outline,
                          isValid: _isNameValid,
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        _buildInputField(
                          controller: _emailCtrl,
                          hint: 'E-posta',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isValid: _isEmailValid,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        _buildInputField(
                          controller: _passCtrl,
                          hint: 'Şifre',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePass,
                          isValid: _isPasswordValid,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        _buildInputField(
                          controller: _confirmPassCtrl,
                          hint: 'Şifre tekrar',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          isValid: _isConfirmPasswordValid,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Simple Checkboxes
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (value) => setState(
                                () => _acceptedTerms = value ?? false,
                              ),
                              activeColor: AppColors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _acceptedTerms = !_acceptedTerms,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Kullanım şartlarını kabul ediyorum',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' (görüntüle)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.pink,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showTermsDialog,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedPrivacy,
                              onChanged: (value) => setState(
                                () => _acceptedPrivacy = value ?? false,
                              ),
                              activeColor: AppColors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _acceptedPrivacy = !_acceptedPrivacy,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        'Gizlilik politikasını kabul ediyorum',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' (görüntüle)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.pink,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _showPrivacyDialog,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pink,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Hesap Oluştur',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Simple Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabın var mı? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _hapticFeedback();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginPage(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return SlideTransition(
                                        position: animation.drive(
                                          Tween(
                                            begin: const Offset(-1.0, 0.0),
                                            end: Offset.zero,
                                          ).chain(
                                            CurveTween(curve: Curves.easeInOut),
                                          ),
                                        ),
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Giriş Yap',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.pink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
