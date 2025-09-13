import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/shared/utils/result.dart';

void main() {
  group('Result.fold/map', () {
    test('Success fold returns success branch value', () {
      const Result<String, String> r = Success('ok');
      final folded = r.fold(
        failure: (_) => 'x',
        success: (v) => v.toUpperCase(),
      );
      expect(folded, 'OK');
    });

    test('Failure fold returns failure branch value', () {
      const Result<String, int> r = Failure('err');
      final folded = r.fold(failure: (e) => e.length, success: (_) => 0);
      expect(folded, 3);
    });

    test('map transforms only success', () {
      const Result<String, int> r = Success(2);
      final mapped = r.map((v) => v * 10);
      expect(mapped, const Success<String, int>(20));
    });

    test('map keeps failure untouched', () {
      const Result<String, int> r = Failure('boom');
      final mapped = r.map((v) => v * 10);
      expect(mapped, const Failure<String, int>('boom'));
    });

    test('mapError transforms only failure', () {
      const Result<String, int> r = Failure('bad');
      final mapped = r.mapError((e) => e.toUpperCase());
      expect(mapped, const Failure<String, int>('BAD'));
    });

    test('mapError keeps success untouched', () {
      const Result<String, int> r = Success(5);
      final mapped = r.mapError((e) => e.toUpperCase());
      expect(mapped, const Success<String, int>(5));
    });
  });

  group('Result equality & toString', () {
    test('Success equality and hashCode', () {
      const a = Success<String, int>(1);
      const b = Success<String, int>(1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), 'Success(1)');
    });

    test('Failure equality and hashCode', () {
      const a = Failure<String, int>('err');
      const b = Failure<String, int>('err');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), 'Failure(err)');
    });
  });
}
