---
slug: future-wait-records
title: Await several futures with a record's .wait
summary: Future.wait gives you a List of Object. A record of futures with .wait keeps each type and tells you which one failed.
category: dart
tags: [async, records, errors]
level: intermediate
published: 2026-09-12
status: current
origin:
  upstream_id: 80
  upstream_path: tips/0080-future.wait/index.md
  change: modernized
related: [future-provider-future, records-multiple-returns, stopwatch-measure-time]
---

Two independent calls shouldn't wait for each other. `Future.wait` runs them concurrently, but when the futures return different types you get a `List<Object>` back and have to cast:

<?code-excerpt "future-wait-records/wallet.dart" region="list"?>
```dart dont="The types are lost. A wrong index is a runtime error."
final results = await Future.wait([
  wallet.transactionCount(),
  wallet.owner(),
]);
// @note List<Object>: the types are gone, so you cast
final count = results[0] as int;
final owner = results[1] as String;
```

<?code-excerpt "future-wait-records/wallet.dart" region="record"?>
```dart do="Each value keeps its type. No casts."
// @note (int, String): each value keeps its type
final (count, owner) = await (
  wallet.transactionCount(),
  wallet.owner(),
).wait;
```

Put the futures in a record and call `.wait` on it. It comes from an extension in `dart:async` and works for records of two to nine futures (positional fields only). You get back a record with the same shape, so you can destructure it straight away.

## When one of them fails

`Future.wait` completes with the first error it sees. Values from the futures that did succeed are gone.

The record's `.wait` still waits for all of them, then throws a `ParallelWaitError`. Its `values` and `errors` have the same shape as your record: a value or `null` for each slot, and an `AsyncError` or `null` for each slot.

<?code-excerpt "future-wait-records/wallet.dart" region="errors"?>
```dart
try {
  final (count, owner) = await (
    wallet.transactionCount(),
    wallet.owner(),
  ).wait;
  return '$owner: $count transactions';
  // @note one error type, typed like the record
} on ParallelWaitError<
  (int?, String?),
  (AsyncError?, AsyncError?)
> catch (e) {
  // @note values that did arrive are still here
  final (count, owner) = e.values;
  return 'partial: count $count, owner $owner';
}
```

That's useful when a successful result holds a resource that you need to close, or when partial data is better than none.

## Good to know

- Lists get the same treatment: `[f1, f2].wait` returns a `List<T>` and also throws `ParallelWaitError` on failure.
- `.wait` never fails early. If one future fails fast and another takes ten seconds, you wait ten seconds. `Future.wait(eagerError: true)` is the option for failing fast.
- Concurrent isn't parallel. Both futures run on one isolate, which is right for I/O. For heavy computation, use `Isolate.run`.

<!-- tips:nav -->

---

**#016** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#015 Give buttons the same width with IntrinsicWidth](../intrinsic-width/index.md)  
→ Next: [#017 Replace Container with the widgets it wraps](../replace-container/index.md)
<!-- /tips:nav -->
