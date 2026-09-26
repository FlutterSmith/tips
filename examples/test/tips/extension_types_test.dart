import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/extension-types/user_id.dart';

void main() {
  test('an extension method adds to String', () {
    expect('hi'.shout(), 'HI!');
  });

  test('an extension type has its own members', () {
    expect(greetAda(), 'Welcome back, ada');
    expect(greet(const UserId('guest-7')), 'Welcome, guest');
  });

  test('at runtime the wrapper is the String itself', () {
    expect(isJustAString(), isTrue);
    const id = UserId('ada');
    expect(identical(id.value, id as Object?), isTrue);
  });
}
