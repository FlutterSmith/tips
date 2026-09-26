// expect: non_exhaustive_switch_expression
import 'package:tips_examples/tips/sealed-class-result/result.dart';

// #docregion missing
String describe(Result<double> result) {
  // @note error: Failure isn't handled
  return switch (result) {
    Success(:final value) => 'Total: $value',
  };
}
// #enddocregion missing
