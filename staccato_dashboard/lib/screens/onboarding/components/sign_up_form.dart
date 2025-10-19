import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/insets.dart';
import '../models/sign_up_form_model.dart';

/// A form used to create a new account in the Staccato system.
class SignUpForm extends StatelessWidget {
  /// Creates a new [SignUpForm] widget.
  const SignUpForm({
    required this.signUpFormKey,
    required this.formModel,
    required this.onSignUp,
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
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF212121)),
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
            ElevatedButton(
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
