import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when sign-up succeeds but email verification is required.
/// The user must check their email and verify before logging in.
class EmailConfirmationNeededException extends AuthException {
  EmailConfirmationNeededException(String email)
      : super(
          'Please check your email ($email) to verify your account.',
        );
}
