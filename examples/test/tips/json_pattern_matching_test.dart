import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/json-pattern-matching/shape.dart';

void main() {
  test('parses each shape by its type', () {
    final square = Shape.fromJson({'type': 'square', 'side': 10.0});
    expect((square as Square).side, 10.0);
    final circle = Shape.fromJson({'type': 'circle', 'radius': 5.0});
    expect((circle as Circle).radius, 5.0);
  });

  test('bad input is a FormatException, not a TypeError', () {
    for (final json in <Map<String, Object?>>[
      {'type': 'triangle'},
      {'type': 'square'},
      {'type': 'square', 'side': '10'},
      {'side': 10.0},
    ]) {
      expect(
        () => Shape.fromJson(json),
        throwsFormatException,
        reason: '$json',
      );
    }
  });

  test('the cast version throws a TypeError on bad input', () {
    expect(
      () => oldFromJson({'type': 'square', 'side': '10'}),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => oldFromJson({'side': 10.0}),
      throwsA(isA<TypeError>()),
    );
  });

  test('extra keys are ignored', () {
    final json = {'type': 'circle', 'radius': 1.0, 'color': 'red'};
    expect(Shape.fromJson(json), isA<Circle>());
  });

  test('if-case reads a nested value or gives null', () {
    expect(
      avatarUrl({
        'user': {'avatar': 'a.png', 'name': 'Ada'},
      }),
      'a.png',
    );
    expect(avatarUrl({'user': 'Ada'}), isNull);
    expect(avatarUrl({}), isNull);
  });
}
