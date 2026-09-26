// Riverpod 2 code: FamilyNotifier was removed in Riverpod 3.
// expect: extends_non_class, override_on_non_overriding_member, undefined_identifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

// #docregion old
class OldQuantity extends FamilyNotifier<int, String> {
  @override
  int build(String sku) => 1;

  void increment() {
    // `arg` held the argument.
    if (arg.isNotEmpty) state++;
  }
}
// #enddocregion old
