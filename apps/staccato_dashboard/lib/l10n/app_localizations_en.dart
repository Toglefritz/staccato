// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Staccato';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameRequiredError => 'Enter your full name.';

  @override
  String get email => 'Email';

  @override
  String get emailRequiredError => 'Please enter an email address.';

  @override
  String get password => 'Password';

  @override
  String get emailInvalidError => 'This is not a valid email address.';

  @override
  String get passwordLengthError =>
      'Your password should have at least six characters.';

  @override
  String get passwordRequiredError => 'Enter a password, please.';

  @override
  String get newAccount => 'New Account';

  @override
  String get login => 'Login';

  @override
  String get submit => 'Submit';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome Back';
}
