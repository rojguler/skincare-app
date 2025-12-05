import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Yerel authentication servisi (Firebase olmadan)
class LocalAuthService {
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'currentUser';

  /// Kullanıcı kaydı oluştur
  static Future<bool> register(String email, String password, String name) async {
    try {
      if (kIsWeb) {
        // Web için SharedPreferences kullan
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('users') ?? '{}';
        final users = json.decode(usersJson) as Map<String, dynamic>;
        
        // E-posta zaten kayıtlı mı kontrol et
        if (users.containsKey(email)) {
          throw Exception('Bu e-posta adresi zaten kullanımda!');
        }
        
        // Şifre doğrulama
        if (password.length < 6) {
          throw Exception('Şifre en az 6 karakter olmalı!');
        }

        // Şifreyi hashle
        final hashedPassword = _hashPassword(password);

        // Kullanıcıyı kaydet
        users[email] = {
          'email': email,
          'password': hashedPassword,
          'name': name,
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        await prefs.setString('users', json.encode(users));
        await _setCurrentUser(email);
        
        return true;
      } else {
        // Mobile için Hive kullan
        final usersBox = await Hive.openBox(_usersBoxName);
        
        // E-posta zaten kayıtlı mı kontrol et
        if (usersBox.containsKey(email)) {
          throw Exception('Bu e-posta adresi zaten kullanımda!');
        }

        // Şifre doğrulama
        if (password.length < 6) {
          throw Exception('Şifre en az 6 karakter olmalı!');
        }

        // Şifreyi hashle
        final hashedPassword = _hashPassword(password);

        // Kullanıcıyı kaydet
        await usersBox.put(email, {
          'email': email,
          'password': hashedPassword,
          'name': name,
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Otomatik giriş yap
        await _setCurrentUser(email);

        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Kullanıcı girişi
  static Future<bool> login(String email, String password) async {
    try {
      if (kIsWeb) {
        // Web için SharedPreferences kullan
        final prefs = await SharedPreferences.getInstance();
        final usersJson = prefs.getString('users') ?? '{}';
        final users = json.decode(usersJson) as Map<String, dynamic>;

        // Kullanıcı var mı kontrol et
        if (!users.containsKey(email)) {
          throw Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.');
        }

        // Kullanıcı bilgilerini al
        final userData = users[email] as Map<String, dynamic>;
        final storedHashedPassword = userData['password'];

        // Şifreyi doğrula
        final hashedPassword = _hashPassword(password);
        if (hashedPassword != storedHashedPassword) {
          throw Exception('Şifre hatalı!');
        }

        // Giriş başarılı, current user'ı kaydet
        await _setCurrentUser(email);

        return true;
      } else {
        // Mobile için Hive kullan
        final usersBox = await Hive.openBox(_usersBoxName);

        // Kullanıcı var mı kontrol et
        if (!usersBox.containsKey(email)) {
          throw Exception('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.');
        }

        // Kullanıcı bilgilerini al
        final userData = usersBox.get(email) as Map;
        final storedHashedPassword = userData['password'];

        // Şifreyi doğrula
        final hashedPassword = _hashPassword(password);
        if (hashedPassword != storedHashedPassword) {
          throw Exception('Şifre hatalı!');
        }

        // Giriş başarılı, current user'ı kaydet
        await _setCurrentUser(email);

        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Çıkış yap
  static Future<void> logout() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } else {
      final authBox = await Hive.openBox('auth');
      await authBox.delete(_currentUserKey);
    }
  }

  /// Mevcut kullanıcıyı al
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final currentUserEmail = prefs.getString(_currentUserKey);

        if (currentUserEmail == null) return null;

        final usersJson = prefs.getString('users') ?? '{}';
        final users = json.decode(usersJson) as Map<String, dynamic>;
        final userData = users[currentUserEmail];

        if (userData == null) return null;

        return Map<String, dynamic>.from(userData);
      } else {
        final authBox = await Hive.openBox('auth');
        final currentUserEmail = authBox.get(_currentUserKey);

        if (currentUserEmail == null) return null;

        final usersBox = await Hive.openBox(_usersBoxName);
        final userData = usersBox.get(currentUserEmail);

        if (userData == null) return null;

        return Map<String, dynamic>.from(userData);
      }
    } catch (e) {
      return null;
    }
  }

  /// Kullanıcı giriş yapmış mı?
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Şifreyi hashle (SHA-256)
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Current user'ı kaydet
  static Future<void> _setCurrentUser(String email) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, email);
    } else {
      final authBox = await Hive.openBox('auth');
      await authBox.put(_currentUserKey, email);
    }
  }
}

