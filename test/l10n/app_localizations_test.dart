import 'package:ariokan_index/l10n/app_localizations.dart';
import 'package:ariokan_index/l10n/app_localizations_en.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations delegate', () {
    test('shouldReload returns false', () {
      expect(
        AppLocalizations.delegate.shouldReload(AppLocalizations.delegate),
        isFalse,
      );
    });

    test('isSupported only en', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
      expect(
        AppLocalizations.delegate.isSupported(const Locale('pt')),
        isFalse,
      );
    });

    test('unsupported locale throws', () {
      expect(
        () => lookupAppLocalizations(const Locale('pt')),
        throwsFlutterError,
      );
    });
  });

  group('AppLocalizationsEn getters', () {
    final en = AppLocalizationsEn();

    test('all string getters non-empty', () {
      final values = <String>[
        en.appTitle,
        en.signup_title,
        en.signup_username_label,
        en.signup_email_label,
        en.signup_password_label,
        en.signup_submit,
        en.signup_submit_done,
        en.signup_error_usernameTaken,
        en.signup_error_usernameInvalid,
        en.signup_error_emailInvalid,
        en.signup_error_passwordWeak,
        en.signup_error_networkFailure,
        en.signup_error_rollbackFailed,
        en.signup_error_unknown,
        en.signup_field_error_username_required,
        en.signup_field_error_email_required,
        en.signup_field_error_password_required,
        en.signup_error_emailAlreadyInUse,
      ];
      expect(values.any((v) => v.isEmpty), isFalse);
    });
  });
}
