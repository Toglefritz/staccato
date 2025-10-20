import 'package:flutter/material.dart';

/// Represents the collection of text editing controllers used in the sign-in form.
///
/// This model encapsulates all text controllers associated with the sign-in form fields. It provides a single point of
/// management for creating and disposing of these controllers, keeping the widget class clean and making controller
/// handling more maintainable.
class SignInFormModel {
  /// Controls the text input for the user's email address field.
  ///
  /// This value is used as the unique identifier for authentication.
  final TextEditingController emailController;

  /// Controls the text input for the user's password field.
  ///
  /// Stores the password entered by the user during sign-up. Should be validated for minimum length and complexity
  /// before submission.
  final TextEditingController passwordController;

  /// Creates a new instance of [SignInFormModel].
  SignInFormModel({
    required this.emailController,
    required this.passwordController,
  });

  /// Disposes all text controllers associated with the form.
  ///
  /// This method must be called when the form model is no longer in use to free up system resources and prevent memory
  /// leaks.
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
