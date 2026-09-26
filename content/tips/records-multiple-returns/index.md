---
slug: records-multiple-returns
title: Return multiple values with a record
summary: A record returns two or more values without a throwaway class, and destructuring unpacks them in one line at the call site.
category: dart
tags: [records, patterns, dart3, types]
level: beginner
published: 2026-09-08
status: current
origin:
  upstream_id: 107
  upstream_path: tips/0107-happy-birthday-records-dart-3/index.md
  change: modernized
related: [switch-on-records, destructure-lists, stopwatch-measure-time]
---

A function needs to hand back two values. Writing a class for that feels heavy, and returning a `List<Object>` throws the types away. Return a record:

<?code-excerpt "records-multiple-returns/stats.dart" region="positional"?>
```dart
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
```

Once there are more than two values, or two of the same type, name the fields. The names are part of the type, so the caller can't mix them up:

<?code-excerpt "records-multiple-returns/stats.dart" region="named"?>
```dart
// @note named fields read better at the call site
({double mean, int count}) summarize(List<int> values) {
  final total = values.fold(0, (sum, v) => sum + v);
  return (mean: total / values.length, count: values.length);
}
```

## Unpacking the result

Destructure right where you call the function. Positional fields bind by position. Named fields bind by name, and `:name` saves you writing the name twice:

<?code-excerpt "records-multiple-returns/stats.dart" region="destructure"?>
```dart
final (low, high) = minMax(scores);
// @note :mean is short for mean: mean
final (:mean, :count) = summarize(scores);
return '$count scores, $low to $high, '
    'mean ${mean.toStringAsFixed(1)}';
```

You can also keep the record and read its fields: `stats.mean` for named fields, `$1` and `$2` for positional ones.

## Good to know

Records get `==` and `hashCode` for free, based on their fields. Named fields match by name, so the order you write them in doesn't matter:

<?code-excerpt "records-multiple-returns/stats.dart" region="equality"?>
```dart
// @note records compare by value
return (mean: 2.0, count: 3) == (count: 3, mean: 2.0);
```

That makes records handy as map keys and in tests: `expect(minMax([5]), (5, 5))` just works.

## Watch out

Records are great for a result that lives for a line or two. If the same shape travels through several layers of your app, or needs methods, `toJson` or docs on each field, give it a proper class. A `typedef` can name a record type, but it's still only a shape, not a type of its own.

<!-- tips:nav -->

---

**#010** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#009 ref.watch, ref.read or ref.listen?](../ref-watch-read-listen/index.md)  
→ Next: [#011 Return SizedBox.shrink() when there is nothing to show](../sizedbox-shrink/index.md)
<!-- /tips:nav -->
