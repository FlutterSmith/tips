import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/records-multiple-returns/stats.dart';

void main() {
  test('minMax returns both values in one record', () {
    final (low, high) = minMax([4, 9, 1, 7]);
    expect(low, 1);
    expect(high, 9);
    expect(minMax([5]), (5, 5));
  });

  test('summarize returns named fields', () {
    final stats = summarize([2, 4, 6]);
    expect(stats.mean, 4.0);
    expect(stats.count, 3);
  });

  test('destructuring feeds the report', () {
    expect(report([2, 4, 9]), '3 scores, 2 to 9, mean 5.0');
  });

  test('records are equal by value, named order ignored', () {
    expect(sameShape(), isTrue);
  });
}
