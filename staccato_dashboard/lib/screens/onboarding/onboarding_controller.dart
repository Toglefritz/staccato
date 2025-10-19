import 'dart:async';

import 'package:flutter/material.dart';
import 'onboarding_route.dart';
import 'onboarding_view.dart';

/// Controller for the onboarding screen that manages state and business logic.
///
/// Extends `State<OnboardingRoute>` to provide state management capabilities and serves as the bridge between the route
/// and view components. Manages the authentication interface with tab navigation between sign up and sign in.
class OnboardingController extends State<OnboardingRoute> with TickerProviderStateMixin {
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
      // TODO(Toglefritz): Implement sign up logic
      // For now, just show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up functionality coming soon!')),
        );
      }
    }
  }

  /// Handles sign in form submission.
  Future<void> handleSignIn() async {
    if (_signInFormKey.currentState?.validate() ?? false) {
      // TODO(Toglefritz): Implement sign in logic
      // For now, just show a SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in functionality coming soon!')),
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
