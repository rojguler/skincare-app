import 'package:flutter/material.dart';

/// Comprehensive validation utilities for form inputs
class Validators {
  static const String _emailRegex = 
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String _passwordRegex = 
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$';
  static const String _phoneRegex = 
      r'^\+?[1-9]\d{1,14}$';
  static const String _nameRegex = 
      r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]{2,50}$';

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    if (!RegExp(_emailRegex).hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    if (value.length > 128) {
      return 'Şifre çok uzun (max 128 karakter)';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Validates name field
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad gerekli';
    }
    
    if (value.trim().length < 2) {
      return 'Ad soyad en az 2 karakter olmalı';
    }
    
    if (value.trim().length > 50) {
      return 'Ad soyad çok uzun (max 50 karakter)';
    }
    
    if (!RegExp(_nameRegex).hasMatch(value.trim())) {
      return 'Ad soyad sadece harfler içermeli';
    }
    
    return null;
  }

  /// Validates required fields
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olmalı';
    }
    return null;
  }

  /// Validates numeric input
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Geçerli bir sayı girin';
    }
    
    return null;
  }

  /// Validates skin type selection
  static String? validateSkinType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cilt tipi seçimi gerekli';
    }
    
    const validSkinTypes = ['Kuru', 'Yağlı', 'Karma', 'Normal', 'Hassas'];
    if (!validSkinTypes.contains(value.trim())) {
      return 'Geçerli bir cilt tipi seçin';
    }
    
    return null;
  }

  /// Validates notes field
  static String? validateNotes(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Notlar en fazla 500 karakter olmalı';
    }
    return null;
  }

  /// Validates product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ürün adı gerekli';
    }
    
    if (value.trim().length < 2) {
      return 'Ürün adı en az 2 karakter olmalı';
    }
    
    if (value.trim().length > 100) {
      return 'Ürün adı en fazla 100 karakter olmalı';
    }
    
    return null;
  }

  /// Validates barcode
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Barkod gerekli';
    }
    
    final cleanBarcode = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanBarcode.length < 8 || cleanBarcode.length > 14) {
      return 'Geçerli bir barkod girin (8-14 haneli)';
    }
    
    return null;
  }

  /// Validates rating
  static String? validateRating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Değerlendirme gerekli';
    }
    
    final rating = double.tryParse(value.trim());
    if (rating == null) {
      return 'Geçerli bir değerlendirme girin';
    }
    
    if (rating < 1.0 || rating > 5.0) {
      return 'Değerlendirme 1-5 arasında olmalı';
    }
    
    return null;
  }

  /// Combines multiple validators
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

/// Custom form field validator mixin
mixin FormValidationMixin {
  final Map<String, String?> _validationErrors = {};
  final Map<String, TextEditingController> _controllers = {};

  /// Adds a controller for validation
  void addController(String key, TextEditingController controller) {
    _controllers[key] = controller;
  }

  /// Validates a single field
  String? validateField(String key, String? Function(String?) validator) {
    final controller = _controllers[key];
    if (controller == null) return null;
    
    final error = validator(controller.text);
    _validationErrors[key] = error;
    return error;
  }

  /// Validates all fields
  bool validateAllFields(Map<String, String? Function(String?)> validators) {
    bool isValid = true;
    _validationErrors.clear();

    for (final entry in validators.entries) {
      final error = validateField(entry.key, entry.value);
      if (error != null) {
        isValid = false;
      }
    }

    return isValid;
  }

  /// Gets validation error for a field
  String? getValidationError(String key) {
    return _validationErrors[key];
  }

  /// Clears validation errors
  void clearValidationErrors() {
    _validationErrors.clear();
  }

  /// Checks if form is valid
  bool get isFormValid => _validationErrors.values.every((error) => error == null);

  /// Gets all validation errors
  Map<String, String?> get validationErrors => Map.unmodifiable(_validationErrors);
}
