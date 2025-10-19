import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../theme/insets.dart';
import '../models/sign_in_form_model.dart';
import '../models/sign_up_form_model.dart';
import '../onboarding_controller.dart';
import 'folder_tab.dart';
import 'sign_in_form.dart';
import 'sign_up_form.dart';

/// Custom tabbed card widget that creates the folder-tab design
class CustomTabbedCard extends StatelessWidget {
  /// Creates an instance of the [CustomTabbedCard] widget.
  const CustomTabbedCard({
    required this.controller,
    super.key,
  });

  /// Controller for the onboarding process.
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.tabController,
      builder: (context, child) {
        final currentIndex = controller.tabController.index;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main card content
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 500, // Fixed height to match design
                  child: Stack(
                    children: [
                      // Form content area
                      Positioned.fill(
                        bottom: 80, // Leave space for button and tabs
                        child: IndexedStack(
                          index: currentIndex,
                          children: [
                            // Sign Up Form Fields
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(Insets.large),
                              child: SignUpForm(
                                signUpFormKey: controller.signUpFormKey,
                                formModel: SignUpFormModel(
                                  nameController: controller.nameController,
                                  emailController: controller.emailController,
                                  passwordController: controller.passwordController,
                                ),
                                onSignUp: controller.handleSignUp,
                                onGoogleSignUp: controller.handleGoogleSignUp,
                                showSubmitButton: false, // Hide button in form
                              ),
                            ),
                            // Sign In Form Fields
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(Insets.large),
                              child: SignInForm(
                                signInFormKey: controller.signInFormKey,
                                formModel: SignInFormModel(
                                  emailController: controller.emailController,
                                  passwordController: controller.passwordController,
                                ),
                                onSignIn: controller.handleSignIn,
                                onGoogleSignIn: controller.handleGoogleSignIn,
                                showSubmitButton: false, // Hide button in form
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Submit button pinned to bottom
                      Positioned(
                        left: Insets.large,
                        right: Insets.large,
                        bottom: 60, // Above the tabs
                        child: ElevatedButton(
                          onPressed: currentIndex == 0 ? controller.handleSignUp : controller.handleSignIn,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Custom folder-style tabs at bottom
            Transform.translate(
              offset: const Offset(0, -1), // Overlap with card slightly
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gapWidth = 4.0; // Small gap between tabs
                  final tabWidth = (constraints.maxWidth - gapWidth) / 2;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: tabWidth,
                        child: FolderTab(
                          text: context.l10n.newAccount,
                          isSelected: currentIndex == 0,
                          onTap: () => controller.tabController.animateTo(0),
                          selectedColor: Colors.grey[300]!,
                          unselectedColor: Colors.grey[300]!.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: gapWidth),
                      SizedBox(
                        width: tabWidth,
                        child: FolderTab(
                          text: context.l10n.login,
                          isSelected: currentIndex == 1,
                          onTap: () => controller.tabController.animateTo(1),
                          selectedColor: Colors.grey[300]!,
                          unselectedColor: Colors.grey[300]!.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
