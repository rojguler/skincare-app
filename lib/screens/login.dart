import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/error_handler.dart';
import '../core/validators.dart';
import '../core/logger.dart';
import '../core/security.dart';
import '../services/firebase_service.dart';
import '../services/local_auth_service.dart';
import 'register.dart';
import 'welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin, FormValidationMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Form validation states
  String? _emailError;
  String? _passwordError;
  final _logger = AppLogger.createScopedLogger('LoginPage');

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
    
    // Add controllers for validation
    addController('email', _emailCtrl);
    addController('password', _passCtrl);
    
    // Add listeners for real-time validation
    _emailCtrl.addListener(_validateEmail);
    _passCtrl.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Validate email field
  void _validateEmail() {
    setState(() {
      _emailError = Validators.validateEmail(_emailCtrl.text);
    });
  }

  /// Validate password field
  void _validatePassword() {
    setState(() {
      _passwordError = Validators.validatePassword(_passCtrl.text);
    });
  }

  /// Validate entire form
  bool _validateForm() {
    _validateEmail();
    _validatePassword();
    return _emailError == null && _passwordError == null;
  }

  Future<void> _saveLoginDay() async {
    final statsBox = await Hive.openBox('statsBox');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<String> loginDays = List<String>.from(
      statsBox.get('loginDays', defaultValue: []),
    );

    if (!loginDays.contains(today)) {
      loginDays.add(today);
      await statsBox.put('loginDays', loginDays);
    }
  }

  Future<void> _handleLogin() async {
    _logger.info('Login attempt started');
    
    // Form validation
    if (!_validateForm()) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Lütfen tüm alanları doğru şekilde doldurun',
      );
      return;
    }

    setState(() => _isLoading = true);
    _hapticFeedback();

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text.trim();
      
      _logger.info('Attempting login with email: ${SecurityManager.anonymizeEmail(email)}');
      
      // Try Firebase first
      try {
        await FirebaseService.signInWithEmailAndPassword(email, password);
        _logger.info('Firebase login successful');
        
        // Sync data from cloud
        await FirebaseService.syncDataFromCloud();
      } catch (firebaseError) {
        _logger.warning('Firebase login failed, trying local auth', error: firebaseError);
        
        // Fallback to local auth
        await LocalAuthService.login(email, password);
        _logger.info('Local auth login successful');
      }
      
      // Save login day
      await _saveLoginDay();

      if (mounted) {
        _logger.info('Login successful, navigating to home');
        Navigator.pushReplacementNamed(context, '/home');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Hoş geldin! Giriş başarılı'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } on AuthenticationException catch (e) {
      _logger.error('Authentication failed', error: e);
      ErrorHandler.showErrorSnackBar(context, e.message);
    } on NetworkException catch (e) {
      _logger.error('Network error during login', error: e);
      ErrorHandler.showErrorSnackBar(
        context,
        'İnternet bağlantınızı kontrol edin',
        onRetry: _handleLogin,
      );
    } catch (e) {
      _logger.error('Unexpected error during login', error: e);
      ErrorHandler.showErrorSnackBar(
        context,
        'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

                    const SizedBox(height: 40),

                    // Simple Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(20),
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
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Simple Title
                    Text(
                      'Hoş Geldin!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Hesabına giriş yap',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Simple Form
                    Column(
                      children: [
                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.pink.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'E-posta',
                              hintStyle: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.pink.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Şifre',
                              hintStyle: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
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
                                    'Giriş Yap',
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

                    // Simple Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabın yok mu? ',
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
                                        const RegisterPage(),
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
                                            begin: const Offset(1.0, 0.0),
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
                            'Kayıt Ol',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.pink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
