import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security utilities for the application
class SecurityManager {
  static const String _keyPrefix = 'secure_';
  static const String _saltKey = '${_keyPrefix}salt';
  static const String _encryptionKey = '${_keyPrefix}encryption_key';

  /// Initialize security manager
  static Future<void> initialize() async {
    await _ensureEncryptionKey();
  }

  /// Generate a secure random salt
  static String generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash a password with salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify a password against its hash
  static bool verifyPassword(String password, String hash, String salt) {
    final hashedPassword = hashPassword(password, salt);
    return hashedPassword == hash;
  }

  /// Encrypt sensitive data
  static String encryptData(String data) {
    try {
      final key = _getEncryptionKey();
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes + key.codeUnits);
      return base64Encode(digest.bytes);
    } catch (e) {
      throw SecurityException('Failed to encrypt data: $e');
    }
  }

  /// Decrypt sensitive data
  static String decryptData(String encryptedData) {
    try {
      // Note: This is a simple implementation
      // In production, use proper encryption libraries like encrypt package
      final key = _getEncryptionKey();
      final bytes = base64Decode(encryptedData);
      final digest = sha256.convert(bytes + key.codeUnits);
      return utf8.decode(digest.bytes);
    } catch (e) {
      throw SecurityException('Failed to decrypt data: $e');
    }
  }

  /// Securely store data in SharedPreferences
  static Future<void> secureStore(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedValue = encryptData(value);
      await prefs.setString('${_keyPrefix}$key', encryptedValue);
    } catch (e) {
      throw SecurityException('Failed to secure store data: $e');
    }
  }

  /// Securely retrieve data from SharedPreferences
  static Future<String?> secureRetrieve(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedValue = prefs.getString('${_keyPrefix}$key');
      if (encryptedValue == null) return null;
      return decryptData(encryptedValue);
    } catch (e) {
      throw SecurityException('Failed to secure retrieve data: $e');
    }
  }

  /// Securely delete data from SharedPreferences
  static Future<void> secureDelete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_keyPrefix}$key');
    } catch (e) {
      throw SecurityException('Failed to secure delete data: $e');
    }
  }

  /// Validate input to prevent injection attacks
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"\'']'), '')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .trim();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Anonymize email for logging purposes
  static String anonymizeEmail(String email) {
    if (email.isEmpty) return '***';
    
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '***@$domain';
    }
    
    final visibleChars = username.length > 4 ? 2 : 1;
    final hiddenChars = '*' * (username.length - visibleChars);
    final visiblePart = username.substring(0, visibleChars);
    
    return '$visiblePart$hiddenChars@$domain';
  }

  /// Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    if (strength >= 4 && password.length >= 8) {
      return PasswordStrength.strong;
    } else if (strength >= 2) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// Generate a secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final bytes = utf8.encode(random.toString());
    final digest = sha256.convert(bytes);
    final hash = digest.toString();
    
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[int.parse(hash.substring(i * 2, i * 2 + 2), radix: 16) % chars.length];
    }
    return result;
  }

  /// Check if device is rooted (Android) or jailbroken (iOS)
  static Future<bool> isDeviceSecure() async {
    if (Platform.isAndroid) {
      return await _isAndroidRooted();
    } else if (Platform.isIOS) {
      return await _isIOSJailbroken();
    }
    return true;
  }

  /// Check if Android device is rooted
  static Future<bool> _isAndroidRooted() async {
    // This is a simplified check
    // In production, use proper root detection libraries
    try {
      final result = await Process.run('which', ['su']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if iOS device is jailbroken
  static Future<bool> _isIOSJailbroken() async {
    // This is a simplified check
    // In production, use proper jailbreak detection libraries
    try {
      final result = await Process.run('which', ['cydia']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get encryption key
  static String _getEncryptionKey() {
    // In production, use proper key management
    return 'glowsun_encryption_key_2024';
  }

  /// Ensure encryption key exists
  static Future<void> _ensureEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_encryptionKey)) {
      final key = generateSecureRandomString(32);
      await prefs.setString(_encryptionKey, key);
    }
  }

  /// Clear all secure data
  static Future<void> clearAllSecureData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw SecurityException('Failed to clear secure data: $e');
    }
  }
}

/// Password strength enumeration
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Security exception class
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Input validation utilities
class InputValidator {
  /// Validate and sanitize user input
  static String validateAndSanitize(String input, {
    int? maxLength,
    bool allowSpecialChars = true,
    String? allowedChars,
  }) {
    String sanitized = SecurityManager.sanitizeInput(input);
    
    if (maxLength != null && sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    if (allowedChars != null) {
      sanitized = sanitized.replaceAll(RegExp('[^$allowedChars]'), '');
    }
    
    return sanitized;
  }

  /// Validate file upload
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Validate file size
  static bool isValidFileSize(int fileSizeInBytes, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }
}

/// Data privacy utilities
class PrivacyManager {
  /// Anonymize user data
  static String anonymizeData(String data) {
    if (data.length <= 2) return '***';
    
    final firstChar = data[0];
    final lastChar = data[data.length - 1];
    final middleChars = '*' * (data.length - 2);
    
    return '$firstChar$middleChars$lastChar';
  }

  /// Anonymize email
  static String anonymizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***@***';
    
    final username = parts[0];
    final domain = parts[1];
    
    final anonymizedUsername = username.length > 2 
        ? '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}'
        : '**';
    
    return '$anonymizedUsername@$domain';
  }

  /// Check if data contains sensitive information
  static bool containsSensitiveData(String data) {
    final sensitivePatterns = [
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'), // Credit card
      RegExp(r'\b\d{11}\b'), // Turkish ID
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email
    ];
    
    return sensitivePatterns.any((pattern) => pattern.hasMatch(data));
  }
}
