---
slug: sealed-class-result
title: A Result type with a sealed class
summary: Return success or failure instead of throwing, and let an exhaustive switch make sure every caller handles both.
category: dart
tags: [sealed-classes, errors, patterns]
level: intermediate
published: 2026-09-04
status: current
origin:
  upstream_id: 62
  upstream_path: tips/0062-try-catch-result-type/index.md
  change: rewritten
related: [switch-on-records, json-pattern-matching]
---

A function that throws doesn't say so in its signature, and the compiler won't remind anyone to catch. When failure is a normal outcome, return it. A `sealed class` with two subclasses is all you need:

<?code-excerpt "sealed-class-result/result.dart" region="result"?>
```dart
/// Either a value or the exception that stopped us getting one.
// @note sealed: every subclass lives in this file
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final Exception error;
}
```

The function now says what can go wrong right in its return type:

<?code-excerpt "sealed-class-result/result.dart" region="produce"?>
```dart
Result<double> parsePrice(String input) {
  final price = double.tryParse(input);
  if (price == null) {
    // @note the failure is in the return type, not hidden
    return Failure(FormatException('Not a price: "$input"'));
  }
  return Success(price);
}
```

## Handling it

Callers `switch` on the result. Because `Result` is sealed, the compiler knows `Success` and `Failure` are the only cases, and object patterns pull out the fields. Forget the failure case and you get a compile error, not a crash in production:

<?code-excerpt "broken/sealed-class-result/missing_case.dart" region="missing"?>
```dart dont="Doesn't compile: the switch isn't exhaustive."
String describe(Result<double> result) {
  // @note error: Failure isn't handled
  return switch (result) {
    Success(:final value) => 'Total: $value',
  };
}
```

<?code-excerpt "sealed-class-result/result.dart" region="consume"?>
```dart do="Both cases handled. The compiler checks it for you."
String describe(Result<double> result) {
  // @note leave out a case and this stops compiling
  return switch (result) {
    Success(:final value) => 'Total: ${value.toStringAsFixed(2)}',
    Failure(:final error) => 'Could not read the price: $error',
  };
}
```

## Wrapping code that throws

Most APIs still throw. A small helper turns them into a `Result` at the edge of your code:

<?code-excerpt "sealed-class-result/result.dart" region="guard"?>
```dart
/// Turns a call that throws into one that returns a [Result].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Exception catch (e) {
    return Failure(e);
  }
}
```

It catches `Exception` only. An `Error` such as `StateError` is a bug, and it should still crash loudly.

## Do you need a package?

For this shape, no. Packages like fpdart give you `Either` with `map`, `flatMap` and friends, which pay off when you chain many fallible steps. If all you want is "value or error, handled exhaustively", twenty lines of your own code do it with no dependency.

## Watch out

Don't return `Result` from everything. Several calls in a row that can each fail read better inside one `try` block than as a ladder of switches. Use `Result` where the caller has to decide what to do with a failure, like at the boundary between your data layer and your UI.

<!-- tips:nav -->

---

**#005** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#004 Check context.mounted after every await](../context-mounted-async-gaps/index.md)  
→ Next: [#006 The parts of a Riverpod 3 provider](../provider-anatomy/index.md)
<!-- /tips:nav -->
