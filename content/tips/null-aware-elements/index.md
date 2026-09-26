---
slug: null-aware-elements
title: Skip nulls in collection literals with ...? and ?value
summary: The null-aware spread adds nothing for a null list, and a null-aware element leaves out a null entry, so you can drop the if (x != null).
category: dart
tags: [collections, null-safety]
level: beginner
published: 2026-09-16
status: current
origin:
  upstream_id: 155
  upstream_path: tips/0155-null-aware-spread-operator/index.md
  change: modernized
related: [first-or-null, json-pattern-matching]
---

Building a list from a list that might be `null`? Use the null-aware spread `...?`. When the list is `null` it adds nothing, instead of throwing:

<?code-excerpt "null-aware-elements/query.dart" region="spread"?>
```dart
List<String> nextPage(List<String>? loaded, List<String> page) {
  // @note ...? adds nothing when loaded is null
  return [...?loaded, ...page];
}
```

That covers whole collections. For single values that might be `null`, put a `?` in front of the element. The entry is only added when the value isn't `null`:

<?code-excerpt "null-aware-elements/query.dart" region="element"?>
```dart
Map<String, String> queryParams({
  required String q,
  String? sort,
  int? page,
}) {
  return {
    'q': q,
    // @note ?value: the entry is skipped when sort is null
    'sort': ?sort,
    'page': ?page?.toString(),
  };
}
```

`queryParams(q: 'dart')` gives `{'q': 'dart'}`, with no `'sort': null` for the server to trip over.

## Compared to collection if

The same map with collection `if` repeats every name:

<?code-excerpt "null-aware-elements/query.dart" region="collection-if"?>
```dart dont="Each value is named twice."
return {
  'q': q,
  if (sort != null) 'sort': sort,
  if (page != null) 'page': page.toString(),
};
```

<?code-excerpt "null-aware-elements/query.dart" region="element"?>
```dart do="One ? per entry. The value is promoted for you."
Map<String, String> queryParams({
  required String q,
  String? sort,
  int? page,
}) {
  return {
    'q': q,
    // @note ?value: the entry is skipped when sort is null
    'sort': ?sort,
    'page': ?page?.toString(),
  };
}
```

The `use_null_aware_elements` lint, part of the recommended set, points these out for you.

## In lists and sets

It works the same way for list and set elements:

<?code-excerpt "null-aware-elements/query.dart" region="list"?>
```dart
List<String> tags(String? primary, String? secondary) => [
  // @note same for list and set elements
  ?primary,
  ?secondary,
  'all',
];
```

## Watch out

In a map, the `?` goes on the side that might be `null`: `?key: value`, `key: ?value`, or both. And `?page?.toString()` has two different question marks: the first skips the entry, the second is the usual null-aware call.

<!-- tips:nav -->

---

**#021** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#020 React to the app going to the background with AppLifecycleListener](../app-lifecycle-listener/index.md)  
→ Next: [#022 Pass arguments to a Notifier through its constructor](../notifier-with-arguments/index.md)
<!-- /tips:nav -->
