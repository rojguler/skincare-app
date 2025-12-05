import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/skincare_entry.dart';
import '../core/error_handler.dart';
import '../core/logger.dart';
import '../core/security.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication Methods
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final logger = AppLogger.createScopedLogger('FirebaseAuth');
    
    try {
      logger.info('Attempting to sign in with email: ${SecurityManager.anonymizeEmail(email)}');
      
      // Validate input
      if (!SecurityManager.isValidEmail(email)) {
        throw AuthenticationException(message: 'Geçersiz e-posta formatı');
      }
      
      if (password.length < 6) {
        throw AuthenticationException(message: 'Şifre en az 6 karakter olmalı');
      }
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await _analytics.logLogin();
      logger.info('Sign in successful');
      
      return credential;
    } on FirebaseAuthException catch (e) {
      final errorMessage = ErrorHandler.getFirebaseErrorMessage(e);
      logger.error('Firebase auth error: ${e.code}', error: e);
      throw AuthenticationException(message: errorMessage);
    } catch (e) {
      logger.error('Unexpected error during sign in', error: e);
      throw AuthenticationException(message: 'Giriş yapılamadı. Lütfen tekrar deneyin.');
    }
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logSignUp(signUpMethod: 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      // Firebase Authentication hatalarını fırlat
      if (e.code == 'weak-password') {
        throw Exception('Şifre çok zayıf! En az 6 karakter olmalı.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi zaten kullanımda!');
      } else if (e.code == 'invalid-email') {
        throw Exception('Geçersiz e-posta adresi!');
      } else {
        throw Exception('Kayıt oluşturulamadı: ${e.message}');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore Methods for Skincare Entries
  static Future<void> saveSkincareEntry(SkincareEntry entry) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('entries')
            .doc(entry.id)
            .set({
              'id': entry.id,
              'date': entry.date.toIso8601String(),
              'products': entry.products,
              'notes': entry.notes,
              'imagePaths': entry.imagePaths,
              'createdAt': entry.createdAt.toIso8601String(),
              'skinType': entry.skinType,
            });

        await _analytics.logEvent(name: 'skincare_entry_saved');
      }
    } catch (e) {
      print('Save entry error: $e');
    }
  }

  static Future<List<SkincareEntry>> getSkincareEntries() async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('entries')
            .orderBy('createdAt', descending: true)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          return SkincareEntry(
            id: data['id'],
            date: DateTime.parse(data['date']),
            products: List<String>.from(data['products']),
            notes: data['notes'],
            imagePaths: List<String>.from(data['imagePaths']),
            createdAt: DateTime.parse(data['createdAt']),
            skinType: data['skinType'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Get entries error: $e');
      return [];
    }
  }

  // Habits Methods
  static Future<void> saveHabits(
    Map<String, List<Map<String, dynamic>>> habits,
  ) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('data')
            .doc('habits')
            .set({
              'habits': habits,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Save habits error: $e');
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getHabits() async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('data')
            .doc('habits')
            .get();

        if (doc.exists) {
          final data = doc.data()!['habits'] as Map<String, dynamic>;
          return Map<String, List<Map<String, dynamic>>>.from(data);
        }
      }
      return <String, List<Map<String, dynamic>>>{
        'daily': <Map<String, dynamic>>[],
        'weekly': <Map<String, dynamic>>[],
        'monthly': <Map<String, dynamic>>[],
      };
    } catch (e) {
      print('Get habits error: $e');
      return <String, List<Map<String, dynamic>>>{
        'daily': <Map<String, dynamic>>[],
        'weekly': <Map<String, dynamic>>[],
        'monthly': <Map<String, dynamic>>[],
      };
    }
  }

  // Profile Methods
  static Future<void> saveProfile(Map<String, dynamic> profileData) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('data')
            .doc('profile')
            .set({...profileData, 'lastUpdated': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      print('Save profile error: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('data')
            .doc('profile')
            .get();

        if (doc.exists) {
          return doc.data()!;
        }
      }
      return {};
    } catch (e) {
      print('Get profile error: $e');
      return {};
    }
  }

  // Storage Methods for Images
  static Future<String?> uploadImage(String imagePath, String fileName) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        final ref = _storage.ref().child('users/${user.uid}/images/$fileName');
        await ref.putData(await File(imagePath).readAsBytes());
        return await ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  // Analytics Methods
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print('Log event error: $e');
    }
  }

  // Messaging Methods
  static Future<void> initializeMessaging() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _messaging.getToken();
        print('FCM Token: $token');

        // Save token to Firestore
        final user = getCurrentUser();
        if (user != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('data')
              .doc('fcm_token')
              .set({
                'token': token,
                'lastUpdated': FieldValue.serverTimestamp(),
              });
        }
      }
    } catch (e) {
      print('Initialize messaging error: $e');
    }
  }

  // Sync Methods
  static Future<void> syncDataToCloud() async {
    try {
      // Kullanıcı giriş yapmış mı kontrol et
      final user = getCurrentUser();
      if (user == null) {
        print('⚠️ Kullanıcı giriş yapmamış, Firebase sync atlanıyor');
        return; // Kullanıcı yoksa sync yapma
      }

      // Sync habits
      final habitsBox = Hive.box('habits');
      final habits = <String, List<Map<String, dynamic>>>{
        'daily': List<Map<String, dynamic>>.from(
          habitsBox.get('dailyHabits') ?? [],
        ),
        'weekly': List<Map<String, dynamic>>.from(
          habitsBox.get('weeklyHabits') ?? [],
        ),
        'monthly': List<Map<String, dynamic>>.from(
          habitsBox.get('monthlyHabits') ?? [],
        ),
      };
      await saveHabits(habits);

      // Sync profile
      final profileBox = Hive.box('profile');
      final profile = {
        'name': profileBox.get('name'),
        'email': profileBox.get('email'),
        'age': profileBox.get('age'),
        'skinType': profileBox.get('skinType'),
        'skinProblems': profileBox.get('skinProblems') ?? [],
      };
      await saveProfile(profile);

      await logEvent('data_synced_to_cloud');
      print('✅ Firebase sync başarılı');
    } catch (e) {
      print('❌ Sync to cloud error: $e');
    }
  }

  static Future<void> syncDataFromCloud() async {
    try {
      // Kullanıcı giriş yapmış mı kontrol et
      final user = getCurrentUser();
      if (user == null) {
        print('⚠️ Kullanıcı giriş yapmamış, Firebase sync atlanıyor');
        return; // Kullanıcı yoksa sync yapma
      }

      // Sync habits
      final habits = await getHabits();
      final habitsBox = Hive.box('habits');
      habitsBox.put('dailyHabits', habits['daily']);
      habitsBox.put('weeklyHabits', habits['weekly']);
      habitsBox.put('monthlyHabits', habits['monthly']);

      // Sync profile
      final profile = await getProfile();
      final profileBox = Hive.box('profile');
      profile.forEach((key, value) {
        profileBox.put(key, value);
      });

      await logEvent('data_synced_from_cloud');
      print('✅ Firebase\'den veriler cekildi');
    } catch (e) {
      print('❌ Sync from cloud error: $e');
    }
  }
}
