---
slug: destructure-lists
title: Destructure lists with list patterns
summary: List patterns pull values out of a list by position, and a rest element skips or collects whatever sits in the middle.
category: dart
tags: [patterns, collections, dart3]
level: beginner
published: 2026-09-10
status: current
origin:
  upstream_id: 111
  upstream_path: tips/0111-destructure-lists-dart/index.md
  change: kept
related: [switch-on-records, records-multiple-returns, first-or-null]
---

Need the first and last item of a list? Skip the index maths and use a list pattern:

<?code-excerpt "destructure-lists/lists.dart" region="ends"?>
```dart
// @note ... skips everything in the middle
final [first, ..., last] = values;
```

`...` is a rest element. It matches any number of elements, including none. Give it a name and you get those elements as a list:

<?code-excerpt "destructure-lists/lists.dart" region="rest"?>
```dart
// @note name the rest to keep it as a list
final [head, ...tail] = words;
```

## In a switch

List patterns shine in a `switch`, where each case says which lengths it accepts. The compiler knows these four cases cover every possible list:

<?code-excerpt "destructure-lists/lists.dart" region="switch"?>
```dart
String describe(List<int> values) {
  return switch (values) {
    [] => 'empty',
    [final only] => 'just $only',
    [final a, final b] => 'a pair: $a and $b',
    // @note first and last, with anything in between
    [final first, ..., final last] => 'from $first to $last',
  };
}
```

## Watch out

A pattern in a variable declaration must match, or it throws a `StateError` at runtime. `[a, b]` needs exactly two elements, and `[first, ..., last]` needs at least two. The analyzer can't check list lengths for you:

<?code-excerpt "destructure-lists/lists.dart" region="throws"?>
```dart dont="Throws when the list has any other length."
// @note throws StateError unless the length is exactly 2
final [a, b] = values;
```

<?code-excerpt "destructure-lists/lists.dart" region="if-case"?>
```dart do="if-case: a list that doesn't fit is simply skipped."
// @note no match, no throw: the branch is skipped
if (values case [final first, ..., final last]) {
  return (first, last);
}
return null;
```

Use the plain declaration only when the length is guaranteed, for example when you built the list a line earlier. For input you don't control, use `if-case` or a `switch`.

<!-- tips:nav -->

---

**#013** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#012 Which Riverpod 3 provider should you use?](../which-provider/index.md)  
→ Next: [#014 One widget for AsyncValue loading and error states](../async-value-widget/index.md)
<!-- /tips:nav -->
