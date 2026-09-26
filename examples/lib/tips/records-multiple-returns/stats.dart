// #docregion positional
// @note two values, one return type, no class
(int, int) minMax(List<int> values) {
  var low = values.first;
  var high = values.first;
  for (final v in values.skip(1)) {
    if (v < low) low = v;
    if (v > high) high = v;
  }
  return (low, high);
}
// #enddocregion positional

// #docregion named
// @note named fields read better at the call site
({double mean, int count}) summarize(List<int> values) {
  final total = values.fold(0, (sum, v) => sum + v);
  return (mean: total / values.length, count: values.length);
}
// #enddocregion named

String report(List<int> scores) {
  // #docregion destructure
  final (low, high) = minMax(scores);
  // @note :mean is short for mean: mean
  final (:mean, :count) = summarize(scores);
  return '$count scores, $low to $high, '
      'mean ${mean.toStringAsFixed(1)}';
  // #enddocregion destructure
}

bool sameShape() {
  // #docregion equality
  // @note records compare by value
  return (mean: 2.0, count: 3) == (count: 3, mean: 2.0);
  // #enddocregion equality
}
