import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/insets.dart';
import '../models/sign_in_form_model.dart';

/// A form used to log into an existing account in the Staccato system.
class SignInForm extends StatelessWidget {
  /// Creates a new [SignInForm] widget.
  const SignInForm({
    required this.signInFormKey,
    required this.formModel,
    required this.onSignIn,
    this.showSubmitButton = true,
    super.key,
  });

  /// A [GlobalKey] for the form.
  final GlobalKey<FormState> signInFormKey;

  /// A [SignInFormModel] that contains the state of the form.
  ///
  /// This class provides controllers for each field in this form.
  final SignInFormModel formModel;

  /// A callback for when the user submits the form.
  final void Function() onSignIn;

  /// Whether to show the submit button.
  final bool showSubmitButton;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.small),
            child: Text(
              context.l10n.welcomeBack,
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
            padding: const EdgeInsets.only(bottom: Insets.xSmall),
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
                  return null;
                },
              ),
            ),
          ),

          if (showSubmitButton)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.small),
              child: ElevatedButton(
                onPressed: onSignIn,
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
        ],
      ),
    );
  }
}
