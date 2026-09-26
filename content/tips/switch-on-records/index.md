---
slug: switch-on-records
title: Switch on a record to match several values at once
summary: Put two or three values in a record and switch on it. Each case is a row in a table, instead of a tangle of if/else.
category: dart
tags: [patterns, records, dart3]
level: intermediate
published: 2026-09-06
status: current
origin:
  upstream_id: 112
  upstream_path: tips/0112-switch-matrix/index.md
  change: modernized
related: [sealed-class-result, records-multiple-returns, destructure-lists]
---

When the answer depends on several values, an `if`/`else` chain hides the logic in its ordering. Wrap the values in a record and switch on that instead:

<?code-excerpt "switch-on-records/status.dart" region="switch"?>
```dart
// @note one record, matched column by column
return switch ((connection, hasData, hasError)) {
  (Connection.waiting, _, _) => 'Loading',
  (_, true, _) => 'Got data',
  (_, _, true) => 'Got an error',
  // @note _ in every slot catches whatever is left
  _ => 'Nothing yet',
};
```

Each case reads as a row: which values it cares about, and `_` for the ones it doesn't. The cases are tried from top to bottom, so the first match wins, just like the chain it replaces:

<?code-excerpt "switch-on-records/status.dart" region="if-chain"?>
```dart dont="The logic hides in the ordering of the branches."
if (connection == Connection.waiting) {
  return 'Loading';
} else if (hasData) {
  return 'Got data';
} else if (hasError) {
  return 'Got an error';
} else {
  return 'Nothing yet';
}
```

<?code-excerpt "switch-on-records/status.dart" region="switch"?>
```dart do="One row per case. The table is the logic."
// @note one record, matched column by column
return switch ((connection, hasData, hasError)) {
  (Connection.waiting, _, _) => 'Loading',
  (_, true, _) => 'Got data',
  (_, _, true) => 'Got an error',
  // @note _ in every slot catches whatever is left
  _ => 'Nothing yet',
};
```

## A real matrix

With two enums you can spell out the whole grid. Guards (`when`) and `||` patterns keep it short:

<?code-excerpt "switch-on-records/status.dart" region="matrix"?>
```dart
enum Move { rock, paper, scissors }

enum Outcome { win, lose, draw }

Outcome play(Move me, Move them) {
  return switch ((me, them)) {
    // @note binds both values and compares them in a guard
    (final a, final b) when a == b => Outcome.draw,
    (Move.rock, Move.scissors) ||
    (Move.paper, Move.rock) ||
    (Move.scissors, Move.paper) => Outcome.win,
    _ => Outcome.lose,
  };
}
```

## Good to know

- The double parentheses in `switch ((a, b))` are needed: the outer pair belongs to `switch`, the inner pair builds the record.
- Without a final `_`, the compiler checks that every combination is covered. With enums and `bool`s, that means a missing row is a compile error.

## Watch out

A catch-all `_` switches that check off. It's fine as the last row, but if you add an enum value later, the compiler won't point you to this switch. For small enums, prefer listing the rows.

<!-- tips:nav -->

---

**#008** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#007 Use MediaQuery.sizeOf instead of MediaQuery.of](../mediaquery-sizeof/index.md)  
→ Next: [#009 ref.watch, ref.read or ref.listen?](../ref-watch-read-listen/index.md)
<!-- /tips:nav -->
