import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/first-or-null/lookup.dart';

const ada = User('Ada', isAdmin: true);
const bob = User('Bob');

void main() {
  test('firstWhere throws StateError when nothing matches', () {
    expect(
      () => [bob].firstWhere((u) => u.isAdmin),
      throwsStateError,
    );
  });

  test('firstWhereOrNull matches the try/catch version', () {
    for (final users in [
      <User>[],
      [bob],
      [bob, ada],
    ]) {
      expect(firstAdmin(users), firstAdminWithTryCatch(users));
    }
    expect(firstAdmin([bob, ada]), ada);
    expect(firstAdmin([bob]), isNull);
  });

  test('firstOrNull is null for an empty list', () {
    expect(greeting([]), 'No users yet');
    expect(greeting([bob, ada]), 'Hi, Bob');
  });

  test('singleOrNull wants exactly one', () {
    expect(onlyUser([]), isNull);
    expect(onlyUser([ada]), ada);
    expect(onlyUser([ada, bob]), isNull);
    expect(() => [ada, bob].single, throwsStateError);
  });
}
