// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ariokan Index';

  @override
  String get signup_title => 'Create your account';

  @override
  String get signup_username_label => 'Username';

  @override
  String get signup_email_label => 'Email';

  @override
  String get signup_password_label => 'Password';

  @override
  String get signup_submit => 'Sign Up';

  @override
  String get signup_submit_done => 'Done';

  @override
  String get signup_error_usernameTaken => 'That username is already taken.';

  @override
  String get signup_error_usernameInvalid => 'Please enter a valid username.';

  @override
  String get signup_error_emailInvalid => 'Please enter a valid email address.';

  @override
  String get signup_error_passwordWeak => 'Password is too weak.';

  @override
  String get signup_error_networkFailure => 'Network issue, try again.';

  @override
  String get signup_error_rollbackFailed => 'Account creation partially failed. Please contact support.';

  @override
  String get signup_error_unknown => 'Something went wrong. Try again.';

  @override
  String get signup_field_error_username_required => 'Username is required.';

  @override
  String get signup_field_error_email_required => 'Email is required.';

  @override
  String get signup_field_error_password_required => 'Password is required.';

  @override
  String get signup_error_emailAlreadyInUse => 'This email is already in use. Try signing in instead.';
}
