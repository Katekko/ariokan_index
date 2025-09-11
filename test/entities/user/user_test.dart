import 'package:ariokan_index/entities/user/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    final created = DateTime.utc(2025, 1, 1, 12);
    const id = 'u1';
    const username = 'user';
    const email = 'user@example.com';

    test('toMap and fromMap are inverse', () {
      final u = User(
        id: id,
        username: username,
        email: email,
        createdAt: created,
      );
      final map = u.toMap();
      final u2 = User.fromMap(map);
      expect(u2.id, id);
      expect(u2.username, username);
      expect(u2.email, email);
      expect(u2.createdAt.toIso8601String(), created.toIso8601String());
    });

    test('copyWith overrides selected fields immutably', () {
      final u = User(
        id: id,
        username: username,
        email: email,
        createdAt: created,
      );
      final u2 = u.copyWith(username: 'other', email: 'o@example.com');
      expect(u2.id, id);
      expect(u2.username, 'other');
      expect(u2.email, 'o@example.com');
      expect(u2.createdAt, created);
      expect(u, isNot(equals(u2)));
    });

    test('toString contains key fields', () {
      final u = User(
        id: id,
        username: username,
        email: email,
        createdAt: created,
      );
      expect(u.toString(), contains('User(id: u1'));
      expect(u.toString(), contains('username: user'));
    });

    test('props include all values for Equatable', () {
      final u1 = User(
        id: id,
        username: username,
        email: email,
        createdAt: created,
      );
      final u2 = User(
        id: id,
        username: username,
        email: email,
        createdAt: created,
      );
      expect(u1, equals(u2));
    });
  });
}
