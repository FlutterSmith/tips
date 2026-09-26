import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/stopwatch-measure-time/measure.dart';

void main() {
  test('measure returns the result and the elapsed time', () async {
    const delay = Duration(milliseconds: 30);
    final (value, took) = await measure(
      () => Future.delayed(delay, () => 42),
    );
    expect(value, 42);
    expect(took, greaterThanOrEqualTo(delay));
  });

  test('loadProfile passes the result through', () async {
    expect(await loadProfile(() async => 'ada'), 'ada');
  });

  test('both timing styles measure the work', () async {
    Future<void> work() =>
        Future.delayed(const Duration(milliseconds: 5));
    expect(await wallClock(work), isNot(Duration.zero));
    expect(
      await monotonic(work),
      greaterThanOrEqualTo(const Duration(milliseconds: 5)),
    );
  });
}
