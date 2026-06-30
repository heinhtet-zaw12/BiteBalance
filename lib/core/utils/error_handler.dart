import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/core/errors/failures.dart';

/// Converts raw exceptions into user-friendly error messages.
/// Never exposes raw exception text to the user.
class ErrorHandler {
  ErrorHandler._();

  /// Returns a human-readable message for any error.
  static String message(Object error) {
    // Quota exhaustion — already has user-friendly message
    if (error is QuotaExhaustedException) {
      return error.message;
    }

    // Domain-layer failures (wrapping underlying exceptions)
    if (error is Failure) {
      return _mapFailureMessage(error.message);
    }

    // Supabase Auth errors
    if (error is AuthException) {
      return _mapAuthException(error);
    }

    // Supabase Postgrest errors (DB / API)
    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }

    // Network errors
    if (error is SocketException) {
      return 'Please check your internet connection and try again.';
    }
    if (error is HttpException) {
      return 'Unable to reach the server. Please try again later.';
    }
    if (error is TimeoutException) {
      return 'The request timed out. Please try again.';
    }

    // If the error is a Failure message string (from our domain layer)
    final raw = error.toString();

    // Strip "Exception: " prefix if present
    final cleaned = raw.replaceFirst(RegExp(r'^Exception:\s*'), '');

    // Check known substrings
    if (cleaned.toLowerCase().contains('network') ||
        cleaned.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again.';
    }
    if (cleaned.toLowerCase().contains('timeout')) {
      return 'The request timed out. Please try again.';
    }
    if (cleaned.toLowerCase().contains('profile not found')) {
      return 'We couldn\'t find your profile. Please set it up first.';
    }
    if (cleaned.toLowerCase().contains('user not authenticated')) {
      return 'Please sign in again to continue.';
    }
    if (cleaned.toLowerCase().contains('no user returned')) {
      return 'Authentication failed. Please try again.';
    }

    // Generic fallback — never show raw exception
    return 'Something went wrong. Please try again.';
  }

  static String _mapAuthException(AuthException e) {
    return _mapFailureMessage(e.message);
  }

  /// Maps a raw error message string to a user-friendly version.
  /// Used for both AuthExceptions and Failure wrappers.
  static String _mapFailureMessage(String raw) {
    final msg = raw.toLowerCase();

    if (msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered') ||
        msg.contains('email address is already')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (msg.contains('password') && msg.contains('short')) {
      return 'Password is too short. Use at least 6 characters.';
    }
    if (msg.contains('password') && msg.contains('weak')) {
      return 'Password is too weak. Try mixing letters and numbers.';
    }
    if (msg.contains('invalid email') || msg.contains('valid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('email not confirmed') ||
        msg.contains('email not verified')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Too many failed attempts. Please wait a few minutes.';
    }
    if (msg.contains('temporarily unavailable') ||
        msg.contains('quota')) {
      return 'AI analysis is temporarily unavailable. Please try again in a few minutes.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'No internet connection. Please try again.';
    }
    if (msg.contains('session expired') || msg.contains('token')) {
      return 'Your session has expired. Please sign in again.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  static String _mapPostgrestException(PostgrestException e) {
    // Common PostgREST error codes
    switch (e.code) {
      case '23505': // unique_violation
        return 'This record already exists.';
      case '23503': // foreign_key_violation
        return 'Related data not found. Please check your input.';
      case '23502': // not_null_violation
        return 'Some required fields are missing.';
      case '42P01': // undefined_table
        return 'A server configuration error occurred. Please contact support.';
      case 'PGRST301': // row-level security
        return 'You don\'t have permission to perform this action.';
    }

    final msg = e.message.toLowerCase();
    if (msg.contains('jwt') || msg.contains('expired')) {
      return 'Your session has expired. Please sign in again.';
    }
    if (msg.contains('permission') || msg.contains('denied')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (msg.contains('not found')) {
      return 'The requested data was not found.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Please check your internet connection and try again.';
    }

    return 'A server error occurred. Please try again.';
  }
}
