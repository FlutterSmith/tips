import 'package:collection/collection.dart';

class User {
  const User(this.name, {this.isAdmin = false});
  final String name;
  final bool isAdmin;
}

User? firstAdminWithTryCatch(List<User> users) {
  // #docregion try-catch
  try {
    return users.firstWhere((u) => u.isAdmin);
    // @note catching an Error to handle a normal case
  } on StateError {
    return null;
  }
  // #enddocregion try-catch
}

User? firstAdmin(List<User> users) {
  // #docregion where-or-null
  // @note from package:collection
  return users.firstWhereOrNull((u) => u.isAdmin);
  // #enddocregion where-or-null
}

String greeting(List<User> users) {
  // #docregion or-null
  // @note in dart:core, no import needed
  final first = users.firstOrNull;
  return first == null ? 'No users yet' : 'Hi, ${first.name}';
  // #enddocregion or-null
}

User? onlyUser(List<User> users) {
  // #docregion single
  // @note null for zero users and for two or more
  return users.singleOrNull;
  // #enddocregion single
}
