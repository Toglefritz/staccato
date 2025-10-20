import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/insets.dart';
import '../models/sign_up_form_model.dart';

/// A form used to create a new account in the Staccato system.
class SignUpForm extends StatelessWidget {
  /// Google logo SVG data
  static const String _googleLogoSvg = '''
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
  <path fill="none" d="M0 0h48v48H0z"></path>
</svg>
''';

  /// Creates a new [SignUpForm] widget.
  const SignUpForm({
    required this.signUpFormKey,
    required this.formModel,
    required this.onSignUp,
    required this.onGoogleSignUp,
    this.showSubmitButton = true,
    super.key,
  });

  /// A [GlobalKey] for the form.
  final GlobalKey<FormState> signUpFormKey;

  /// A [SignUpFormModel] that contains the state of the form.
  ///
  /// This class provides controllers for each field in this form.
  final SignUpFormModel formModel;

  /// A callback for when the user submits the form.
  final void Function() onSignUp;

  /// A callback for when the user signs up with Google.
  final void Function() onGoogleSignUp;

  /// Whether to show the submit button.
  final bool showSubmitButton;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Text(
              context.l10n.createAccount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: formModel.nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.fullName,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF212121),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.fullNameRequiredError;
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: formModel.emailController,
                decoration: InputDecoration(
                  labelText: context.l10n.email,
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF212121)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.emailRequiredError;
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return context.l10n.emailInvalidError;
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: TextFormField(
                controller: formModel.passwordController,
                decoration: InputDecoration(
                  labelText: context.l10n.password,
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF212121)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.passwordRequiredError;
                  }
                  if (value.length < 6) {
                    return context.l10n.passwordLengthError;
                  }
                  return null;
                },
              ),
            ),
          ),
          if (showSubmitButton)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.small),
              child: ElevatedButton(
                onPressed: onSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: Insets.small),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.submit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Always show Google sign-up option
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Insets.small),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),

          ElevatedButton.icon(
            onPressed: onGoogleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: Insets.small),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
            ),
            icon: SvgPicture.string(
              _googleLogoSvg,
              height: 20,
              width: 20,
            ),
            label: const Text(
              'Sign up with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
