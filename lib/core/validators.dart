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
      return 'Email address is required';
    }
    
    if (!RegExp(_emailRegex).hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (value.length > 128) {
      return 'Password is too long (max 128 characters)';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates name field
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Name is too long (max 50 characters)';
    }
    
    if (!RegExp(_nameRegex).hasMatch(value.trim())) {
      return 'Name should only contain letters';
    }
    
    return null;
  }

  /// Validates required fields
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }

  /// Validates numeric input
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validates skin type selection
  static String? validateSkinType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Skin type selection is required';
    }
    
    const validSkinTypes = ['Dry', 'Oily', 'Combination', 'Normal', 'Sensitive'];
    if (!validSkinTypes.contains(value.trim())) {
      return 'Please select a valid skin type';
    }
    
    return null;
  }

  /// Validates notes field
  static String? validateNotes(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Notes must be at most 500 characters';
    }
    return null;
  }

  /// Validates product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Product name must be at most 100 characters';
    }
    
    return null;
  }

  /// Validates barcode
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Barcode is required';
    }
    
    final cleanBarcode = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanBarcode.length < 8 || cleanBarcode.length > 14) {
      return 'Please enter a valid barcode (8-14 digits)';
    }
    
    return null;
  }

  /// Validates rating
  static String? validateRating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Rating is required';
    }
    
    final rating = double.tryParse(value.trim());
    if (rating == null) {
      return 'Please enter a valid rating';
    }
    
    if (rating < 1.0 || rating > 5.0) {
      return 'Rating must be between 1 and 5';
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
