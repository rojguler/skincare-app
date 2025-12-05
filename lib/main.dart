import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'screens/welcome_page.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home_page.dart';
import 'screens/statistics_page.dart' as stats;
import 'screens/calendar_page.dart';
import 'screens/profile_page_modern.dart';
import 'screens/habits_page.dart';
import 'screens/skincare_info_page.dart';
import 'core/theme.dart';
import 'core/logger.dart';
import 'core/error_handler.dart';
import 'core/security.dart';
import 'models/skincare_entry.dart';
import 'utils/hive_helper.dart';
import 'providers/habit_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize core services
    await _initializeServices();
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    // Log critical error and still run the app
    AppLogger.critical('Failed to initialize services', error: e);
    runApp(const ProviderScope(child: MyApp()));
  }
}

/// Initialize all core services
Future<void> _initializeServices() async {
  final logger = AppLogger.createScopedLogger('AppInitialization');
  
  try {
    // Initialize logger first
    await AppLogger.initialize();
    logger.info('Logger initialized');

    // Initialize security manager
    await SecurityManager.initialize();
    logger.info('Security manager initialized');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('Firebase initialized');

    // Initialize date formatting
    await initializeDateFormatting('tr_TR', null);
    logger.info('Date formatting initialized');
    
    // Initialize Hive with web compatibility
    if (!kIsWeb) {
      await _initializeHive();
      logger.info('Hive initialized');
    }

    logger.info('All services initialized successfully');
  } catch (e) {
    logger.error('Failed to initialize services', error: e);
    rethrow;
  }
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SkincareEntryAdapter());

  // Open all required boxes with proper error handling
  final boxNames = [
    'entries',
    'stats',
    'profile',
    'habits',
    'goals',
    'settings',
    'routines',
    'statsBox',
    'reminders',
    'users',      // LocalAuth için
    'auth',       // LocalAuth için
  ];

  for (final boxName in boxNames) {
    try {
      await Hive.openBox(boxName);
    } catch (e) {
      AppLogger.error('Failed to open Hive box: $boxName', error: e);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cilt Bakım Takip',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.pink,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.yellow,
          primary: AppColors.pink,
          background: AppColors.background,
          surface: AppColors.white,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.pink),
          titleTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pink,
            foregroundColor: AppColors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.pink,
          foregroundColor: AppColors.textPrimary,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          shadowColor: AppColors.shadowLight,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.yellow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.pink.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.pink.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.pink, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),

      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeShell(),
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    stats.UserStatsPage(),
    HabitsPage(),
    ProfilePageModern(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 15,
              offset: const Offset(0, -3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.pink,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.6),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.pink,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 24),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded, size: 24),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded, size: 24),
              label: 'İstatistikler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_rounded, size: 24),
              label: 'Alışkanlıklar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
