(int, int) ends(List<int> values) {
  // #docregion ends
  // @note ... skips everything in the middle
  final [first, ..., last] = values;
  // #enddocregion ends
  return (first, last);
}

(String, List<String>) headAndTail(List<String> words) {
  // #docregion rest
  // @note name the rest to keep it as a list
  final [head, ...tail] = words;
  // #enddocregion rest
  return (head, tail);
}

// #docregion switch
String describe(List<int> values) {
  return switch (values) {
    [] => 'empty',
    [final only] => 'just $only',
    [final a, final b] => 'a pair: $a and $b',
    // @note first and last, with anything in between
    [final first, ..., final last] => 'from $first to $last',
  };
}
// #enddocregion switch

(int, int) twoOf(List<int> values) {
  // #docregion throws
  // @note throws StateError unless the length is exactly 2
  final [a, b] = values;
  // #enddocregion throws
  return (a, b);
}

(int, int)? safeEnds(List<int> values) {
  // #docregion if-case
  // @note no match, no throw: the branch is skipped
  if (values case [final first, ..., final last]) {
    return (first, last);
  }
  return null;
  // #enddocregion if-case
}
