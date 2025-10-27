import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/authentication/authentication_service.dart';
import '../../services/authentication/exceptions/firebase_auth_creation_exception.dart';
import '../../services/authentication/exceptions/user_document_creation_exception.dart'
    as auth_exceptions;
import '../../services/authentication/models/auth_methods.dart';
import '../../services/user_management/user_management.dart';
import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for the onboarding screen that manages state and business logic.
///
/// Extends `State<OnboardingRoute>` to provide state management capabilities and serves as the bridge between the route
/// and view components. Manages the authentication interface with tab navigation between sign up and sign in.
class OnboardingController extends State<OnboardingRoute>
    with TickerProviderStateMixin {
  /// Tab controller for managing authentication tabs.
  late TabController _tabController;

  /// Form key for sign up form validation.
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  /// Form key for sign in form validation.
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  /// Text field controller for the email field.
  final TextEditingController _emailController = TextEditingController();

  /// Text field controller for the password fields.
  final TextEditingController _passwordController = TextEditingController();

  /// Text field controller for the name field.
  final TextEditingController _nameController = TextEditingController();

  /// Getter for the tab controller.
  TabController get tabController => _tabController;

  /// Getter for sign-up form key.
  GlobalKey<FormState> get signUpFormKey => _signUpFormKey;

  /// Getter for sign-in form key.
  GlobalKey<FormState> get signInFormKey => _signInFormKey;

  /// Getter for email text field controller.
  TextEditingController get emailController => _emailController;

  /// Getter for password text field controller.
  TextEditingController get passwordController => _passwordController;

  /// Getter for name text field controller.
  TextEditingController get nameController => _nameController;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller with 2 tabs (Sign Up, Sign In).
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) => OnboardingView(this);

  /// Handles sign up form submission.
  Future<void> handleSignUp() async {
    if (_signUpFormKey.currentState?.validate() ?? false) {
      try {
        await AuthenticationService.createUser(
          method: AuthMethod.basicAuth,
          emailAddress: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          familyId:
              'temp_family_${DateTime.now().millisecondsSinceEpoch}', // Temporary family ID
          permissionLevel:
              UserPermissionLevel.primary, // First user is typically primary
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthCreationException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to create account. Please check your credentials and try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on auth_exceptions.UserDocumentCreationException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created but failed to set up user profile. Please contact support.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Handles sign in form submission.
  Future<void> handleSignIn() async {
    if (_signInFormKey.currentState?.validate() ?? false) {
      try {
        // Use Firebase Auth directly for basic email/password sign-in
        final UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        if (credential.user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed in successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String message;
          switch (e.code) {
            case 'user-not-found':
              message = 'No user found with this email address.';
            case 'wrong-password':
              message = 'Incorrect password.';
            case 'invalid-email':
              message = 'Invalid email address.';
            case 'user-disabled':
              message = 'This account has been disabled.';
            default:
              message = 'Sign in failed: ${e.message}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign in failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Handles Google sign-in specifically.
  Future<void> handleGoogleSignIn() async {
    try {
      final user = await AuthenticationService.signInWithGoogle();

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in with Google successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign in was cancelled.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles Google sign-up specifically.
  Future<void> handleGoogleSignUp() async {
    try {
      await AuthenticationService.createUser(
        method: AuthMethod.google,
        displayName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'New User', // Fallback if name field is empty
        familyId:
            'temp_family_${DateTime.now().millisecondsSinceEpoch}', // Temporary family ID
        permissionLevel:
            UserPermissionLevel.primary, // First user is typically primary
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created with Google successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthCreationException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to create account with Google. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on auth_exceptions.UserDocumentCreationException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created but failed to set up user profile. Please contact support.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign up failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles user sign out.
  Future<void> handleSignOut() async {
    try {
      await AuthenticationService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }
}
