// expect: argument_type_not_assignable, undefined_method
import 'package:tips_examples/tips/extension-types/user_id.dart';

void mixUp() {
  // #docregion mix-up
  const order = OrderId('o-42');
  // @note error: an OrderId is not a UserId
  greet(order);
  // @note error: String methods are hidden
  UserId('ada').toUpperCase();
  // #enddocregion mix-up
}
