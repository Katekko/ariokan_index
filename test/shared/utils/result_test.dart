import 'package:flutter_test/flutter_test.dart';
import 'package:ariokan_index/shared/utils/result.dart';

void main() {
  test('Success map preserves success', () {
    const Result<String, String> r = Success('ok');
    final mapped = r.map((v) => v.toUpperCase());
    expect(mapped, equals(const Success<String, String>('OK')));
  });

  test('Failure map keeps error', () {
    const Result<String, int> r = Failure('err');
    final mapped = r.map((v) => v + 1);
    expect(mapped, equals(const Failure<String, int>('err')));
  });

  test('fold returns correct branch', () {
    const Result<String, int> r1 = Success(10);
    const Result<String, int> r2 = Failure('bad');
    expect(r1.fold(failure: (_) => 0, success: (v) => v), 10);
    expect(r2.fold(failure: (e) => e.length, success: (_) => 0), 3);
  });
}
