// #docregion extension
// @note adds a method; every String method stays
extension ShoutX on String {
  String shout() => '${toUpperCase()}!';
}
// #enddocregion extension

// #docregion type
// @note a new static type over String, gone at runtime
extension type const UserId(String value) {
  bool get isGuest => value.startsWith('guest-');
}

extension type const OrderId(String value) {}
// #enddocregion type

// #docregion usage
String greet(UserId id) =>
    id.isGuest ? 'Welcome, guest' : 'Welcome back, ${id.value}';
// #enddocregion usage

String greetAda() {
  // #docregion call
  const id = UserId('ada');
  // @note an OrderId or a plain String won't compile here
  return greet(id);
  // #enddocregion call
}

bool isJustAString() {
  // #docregion erased
  const id = UserId('ada');
  final Object? raw = id;
  // @note the wrapper is erased: at runtime it is a String
  return raw is String;
  // #enddocregion erased
}
