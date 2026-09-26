// #docregion result
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
// #enddocregion result

// #docregion produce
Result<double> parsePrice(String input) {
  final price = double.tryParse(input);
  if (price == null) {
    // @note the failure is in the return type, not hidden
    return Failure(FormatException('Not a price: "$input"'));
  }
  return Success(price);
}
// #enddocregion produce

// #docregion consume
String describe(Result<double> result) {
  // @note leave out a case and this stops compiling
  return switch (result) {
    Success(:final value) => 'Total: ${value.toStringAsFixed(2)}',
    Failure(:final error) => 'Could not read the price: $error',
  };
}
// #enddocregion consume

// #docregion guard
/// Turns a call that throws into one that returns a [Result].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Exception catch (e) {
    return Failure(e);
  }
}
// #enddocregion guard
