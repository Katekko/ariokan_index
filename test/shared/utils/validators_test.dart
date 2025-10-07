import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/core/utils/validators.dart';
import 'package:ariokan_index/shared/constants/limits.dart';

void main() {
  group('validateUsername', () {
    test('accepts valid lowercase usernames', () {
      expect(validateUsername('valid_name123'), isNull);
      expect(validateUsername('abc'), isNull);
      expect(validateUsername('a_b9'), isNull);
    });

    test('rejects invalid usernames', () {
      expect(validateUsername('Abc'), isNotNull, reason: 'uppercase not allowed');
      expect(validateUsername('ab'), isNotNull, reason: 'too short');
      expect(validateUsername('this_is_way_too_long_for_rule'), isNotNull);
      expect(validateUsername('bad-char!'), isNotNull);
      expect(validateUsername('space user'), isNotNull);
    });
  });

  group('validateEmail', () {
    test('accepts simple valid emails', () {
      expect(validateEmail('user@example.com'), isNull);
      expect(validateEmail('a.b+c_d-1@sub.domain.io'), isNull);
    });

    test('rejects invalid emails', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('user@'), isNotNull);
      expect(validateEmail('@domain.com'), isNotNull);
      expect(validateEmail('user@domain'), isNotNull);
      expect(validateEmail('user@@domain.com'), isNotNull);
    });
  });

  group('validatePassword', () {
    test('accepts boundary lengths', () {
      expect(validatePassword('a' * passwordMinLength), isNull);
      expect(validatePassword('b' * passwordMaxLength), isNull);
    });

    test('rejects too short and too long', () {
      expect(validatePassword('a' * (passwordMinLength - 1)), isNotNull);
      expect(validatePassword('c' * (passwordMaxLength + 1)), isNotNull);
    });
  });
}
