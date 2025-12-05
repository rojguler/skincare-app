import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'register.dart';
import 'login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _logoAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Ana animasyon controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animasyon controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Particle animasyon controller
    _particleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Fade animasyonu
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Slide animasyonu
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Logo scale animasyonu
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Button scale animasyonu
    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Particle animasyonu
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasyonları başlat
    _animationController.forward();
    _logoAnimationController.forward();
    _particleAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.yellow.withValues(alpha: 0.1),
              AppColors.lightPink.withValues(alpha: 0.2),
              AppColors.pink.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Particles
            ...List.generate(6, (index) => _buildParticle(index)),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo ve Başlık Bölümü
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Premium Logo Container
                            AnimatedBuilder(
                              animation: _logoAnimationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _logoScaleAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.pink,
                                          AppColors.yellow,
                                          AppColors.lightPink,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.pink.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 5,
                                        ),
                                        BoxShadow(
                                          color: AppColors.yellow.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                      child: Icon(
                                        Icons.wb_sunny_rounded,
                                        size: 60,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 48),

                            // Premium Typography
                            Text(
                              'GlowSun',
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: AppColors.pink.withValues(
                                      alpha: 0.3,
                                    ),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Cilt Bakım Yolculuğunuz',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Premium Description Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.pink.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Güzellik rutininizi takip edin,\nprofesyonel cilt bakım önerileri alın',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Premium Buttons Section
                      ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Column(
                          children: [
                            // Primary Action Button
                            Container(
                              width: double.infinity,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.pink, AppColors.primary],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.pink.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _hapticFeedback();
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const RegisterPage(),
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
                                                    begin: const Offset(
                                                      1.0,
                                                      0.0,
                                                    ),
                                                    end: Offset.zero,
                                                  ).chain(
                                                    CurveTween(
                                                      curve: Curves.easeInOut,
                                                    ),
                                                  ),
                                                ),
                                                child: child,
                                              );
                                            },
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_rounded,
                                          color: AppColors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Hesap Oluştur',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Secondary Action Button
                            Container(
                              width: double.infinity,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.pink.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _hapticFeedback();
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const LoginPage(),
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
                                                    begin: const Offset(
                                                      1.0,
                                                      0.0,
                                                    ),
                                                    end: Offset.zero,
                                                  ).chain(
                                                    CurveTween(
                                                      curve: Curves.easeInOut,
                                                    ),
                                                  ),
                                                ),
                                                child: child,
                                              );
                                            },
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login_rounded,
                                          color: AppColors.textPrimary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Giriş Yap',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Social Login Section
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.textSecondary
                                                  .withValues(alpha: 0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        'veya',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.textSecondary
                                                  .withValues(alpha: 0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Social Media Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialButton(
                                      icon: Icons.apple,
                                      label: 'Apple',
                                      onTap: () => _handleSocialLogin('Apple'),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildSocialButton(
                                      icon: Icons.facebook,
                                      label: 'Facebook',
                                      onTap: () =>
                                          _handleSocialLogin('Facebook'),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildSocialButton(
                                      icon: Icons.g_mobiledata,
                                      label: 'Google',
                                      onTap: () => _handleSocialLogin('Google'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final progress = _particleAnimation.value;

        // Different animation patterns for each particle
        double x, y;
        switch (index) {
          case 0:
            x = size.width * 0.1 + (size.width * 0.2 * progress);
            y = size.height * 0.2 + (size.height * 0.1 * (1 - progress));
            break;
          case 1:
            x = size.width * 0.8 - (size.width * 0.15 * progress);
            y = size.height * 0.3 + (size.height * 0.2 * progress);
            break;
          case 2:
            x = size.width * 0.2 + (size.width * 0.3 * (1 - progress));
            y = size.height * 0.7 + (size.height * 0.15 * progress);
            break;
          case 3:
            x = size.width * 0.7 + (size.width * 0.2 * progress);
            y = size.height * 0.1 + (size.height * 0.3 * (1 - progress));
            break;
          case 4:
            x = size.width * 0.05 + (size.width * 0.1 * progress);
            y = size.height * 0.8 + (size.height * 0.1 * (1 - progress));
            break;
          case 5:
            x = size.width * 0.9 - (size.width * 0.1 * progress);
            y = size.height * 0.6 + (size.height * 0.2 * progress);
            break;
          default:
            x = size.width * 0.5;
            y = size.height * 0.5;
        }

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: 8 + (index * 2),
            height: 8 + (index * 2),
            decoration: BoxDecoration(
              color: AppColors.pink.withValues(alpha: 0.1 + (index * 0.05)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _hapticFeedback();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.pink.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider ile giriş yakında eklenecek!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
