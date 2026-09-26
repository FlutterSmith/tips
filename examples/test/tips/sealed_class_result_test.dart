import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/sealed-class-result/result.dart';

void main() {
  test('a valid price is a Success with the value', () {
    final result = parsePrice('12.5');
    expect(result, isA<Success<double>>());
    expect((result as Success<double>).value, 12.5);
  });

  test('a bad price is a Failure, not a throw', () {
    final result = parsePrice('twelve');
    expect(result, isA<Failure<double>>());
    expect((result as Failure<double>).error, isA<FormatException>());
  });

  test('the switch handles both cases', () {
    expect(describe(parsePrice('3')), 'Total: 3.00');
    expect(
      describe(parsePrice('x')),
      startsWith('Could not read the price'),
    );
  });

  test('guard turns a thrown exception into a Failure', () async {
    final ok = await guard(() async => 42);
    expect((ok as Success<int>).value, 42);

    final failed = await guard<int>(
      () async => throw const FormatException('bad'),
    );
    expect((failed as Failure<int>).error, isA<FormatException>());
  });

  test('guard lets Errors through', () {
    expect(
      guard<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
