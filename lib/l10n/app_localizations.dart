import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ariokan Index'**
  String get appTitle;

  /// No description provided for @signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signup_title;

  /// No description provided for @signup_username_label.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get signup_username_label;

  /// No description provided for @signup_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signup_email_label;

  /// No description provided for @signup_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signup_password_label;

  /// No description provided for @signup_submit.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup_submit;

  /// No description provided for @signup_submit_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get signup_submit_done;

  /// No description provided for @signup_error_usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is already taken.'**
  String get signup_error_usernameTaken;

  /// No description provided for @signup_error_usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid username.'**
  String get signup_error_usernameInvalid;

  /// No description provided for @signup_error_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get signup_error_emailInvalid;

  /// No description provided for @signup_error_passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get signup_error_passwordWeak;

  /// No description provided for @signup_error_networkFailure.
  ///
  /// In en, this message translates to:
  /// **'Network issue, try again.'**
  String get signup_error_networkFailure;

  /// No description provided for @signup_error_rollbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Account creation partially failed. Please contact support.'**
  String get signup_error_rollbackFailed;

  /// No description provided for @signup_error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get signup_error_unknown;

  /// No description provided for @signup_field_error_username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get signup_field_error_username_required;

  /// No description provided for @signup_field_error_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get signup_field_error_email_required;

  /// No description provided for @signup_field_error_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get signup_field_error_password_required;

  /// No description provided for @signup_error_emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Try signing in instead.'**
  String get signup_error_emailAlreadyInUse;

  /// No description provided for @login_error_auth.
  ///
  /// In en, this message translates to:
  /// **'Username or password wrong'**
  String get login_error_auth;

  /// No description provided for @login_error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get login_error_network;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
