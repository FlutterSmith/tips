import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/destructure-lists/lists.dart';

void main() {
  test('first and last with ... in between', () {
    expect(ends([1, 2, 3, 4, 5]), (1, 5));
    expect(ends([1, 2]), (1, 2));
  });

  test('a named rest element collects the middle', () {
    final (head, tail) = headAndTail(['git', 'commit', '-m']);
    expect(head, 'git');
    expect(tail, ['commit', '-m']);
    expect(headAndTail(['ls']).$2, isEmpty);
  });

  test('switch picks the case by length', () {
    expect(describe([]), 'empty');
    expect(describe([7]), 'just 7');
    expect(describe([1, 2]), 'a pair: 1 and 2');
    expect(describe([1, 2, 3, 9]), 'from 1 to 9');
  });

  test('a declaration that does not match throws StateError', () {
    expect(() => ends([1]), throwsStateError);
    expect(() => twoOf([1, 2, 3]), throwsStateError);
    expect(twoOf([1, 2]), (1, 2));
  });

  test('if-case skips instead of throwing', () {
    expect(safeEnds([1]), isNull);
    expect(safeEnds([3, 4, 5]), (3, 5));
  });
}
