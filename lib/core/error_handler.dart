import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

/// Centralized error handling system for the application
class ErrorHandler {
  static const String _tag = 'ErrorHandler';

  /// Logs error with proper formatting
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final errorMessage = error.toString();
    
    if (kDebugMode) {
      print('[$timestamp] ERROR in $context: $errorMessage');
      if (additionalInfo != null) {
        print('Additional Info: $additionalInfo');
      }
      if (stackTrace != null) {
        print('Stack Trace: $stackTrace');
      }
    }
    
    // TODO: In production, send to crash reporting service (Firebase Crashlytics)
  }

  /// Shows user-friendly error message
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: 'Close',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows error dialog with retry option
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? retryText,
    VoidCallback? onRetry,
    String? cancelText,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (retryText != null && onRetry != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  retryText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Handles network errors
  static String getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('internet')) {
      return 'Check your internet connection';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out';
    } else if (errorString.contains('server')) {
      return 'Server error occurred';
    } else {
      return 'An unexpected error occurred';
    }
  }

  /// Handles Firebase errors
  static String getFirebaseErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user-not-found')) {
      return 'No user found with this email address';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('email-already-in-use')) {
      return 'This email address is already in use';
    } else if (errorString.contains('weak-password')) {
      return 'Password is too weak, must be at least 6 characters';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (errorString.contains('user-disabled')) {
      return 'This account has been disabled';
    } else {
      return 'Authentication error';
    }
  }

  /// Handles validation errors
  static String getValidationErrorMessage(String field, String error) {
    switch (field.toLowerCase()) {
      case 'email':
        if (error.contains('required')) return 'Email is required';
        if (error.contains('invalid')) return 'Invalid email format';
        break;
      case 'password':
        if (error.contains('required')) return 'Password is required';
        if (error.contains('min')) return 'Password must be at least 6 characters';
        if (error.contains('match')) return 'Passwords do not match';
        break;
      case 'name':
        if (error.contains('required')) return 'Name is required';
        if (error.contains('min')) return 'Name must be at least 2 characters';
        break;
    }
    return 'Invalid $field';
  }
}

/// Custom exception classes
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
        );
}

class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          originalError: originalError,
        );
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
        );
}
