---
slug: first-or-null
title: firstOrNull instead of try/catch on StateError
summary: first, firstWhere and single throw when nothing matches. The OrNull versions return null, and the type system makes you handle it.
category: dart
tags: [collections, null-safety]
level: beginner
published: 2026-09-19
status: current
origin:
  upstream_id: 88
  upstream_path: tips/0088-list-single/index.md
  change: modernized
related: [destructure-lists, null-aware-elements]
---

`first`, `firstWhere` and `single` throw a `StateError` when the list doesn't have what they expect. Wrapping them in `try`/`catch` works, but it's noisy, and it catches an `Error`, which is meant to signal a bug:

<?code-excerpt "first-or-null/lookup.dart" region="try-catch"?>
```dart dont="Catches a StateError to handle a normal case."
try {
  return users.firstWhere((u) => u.isAdmin);
  // @note catching an Error to handle a normal case
} on StateError {
  return null;
}
```

<?code-excerpt "first-or-null/lookup.dart" region="where-or-null"?>
```dart do="Returns null. The type User? says so."
// @note from package:collection
return users.firstWhereOrNull((u) => u.isAdmin);
```

`firstWhereOrNull` lives in `package:collection`, next to `lastWhereOrNull` and `singleWhereOrNull`.

## No package needed

The versions without a test are built into `dart:core`: `firstOrNull`, `lastOrNull`, `singleOrNull` and `elementAtOrNull`. They're getters on every `Iterable`:

<?code-excerpt "first-or-null/lookup.dart" region="or-null"?>
```dart
// @note in dart:core, no import needed
final first = users.firstOrNull;
return first == null ? 'No users yet' : 'Hi, ${first.name}';
```

## single vs singleOrNull

`single` is an assertion: "there is exactly one". Use it when anything else is a bug and you want to know. `singleOrNull` treats zero and many the same way:

<?code-excerpt "first-or-null/lookup.dart" region="single"?>
```dart
// @note null for zero users and for two or more
return users.singleOrNull;
```

## Watch out

- `null` can't tell "not found" apart from "found a `null`". On a `List<User?>`, use `indexWhere` or check `isEmpty` first.
- `lastOrNull` may walk the whole iterable. On a `List` it's instant, on a lazy `where(...)` it isn't.
- If you only need to know whether something matches, `any` says it more clearly.

<!-- tips:nav -->

---

**#024** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#023 Make text selectable across widgets with SelectionArea](../selection-area/index.md)  
→ Next: [#025 Initialise async dependencies in main() and use requireValue](../require-value-async-init/index.md)
<!-- /tips:nav -->
