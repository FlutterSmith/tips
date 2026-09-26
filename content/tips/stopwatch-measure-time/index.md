---
slug: stopwatch-measure-time
title: Measure execution time with Stopwatch
summary: DateTime.now() reads the wall clock, which can jump. Stopwatch can't, so use it to time code.
category: dart
tags: [performance, async, records]
level: beginner
published: 2026-09-01
status: current
origin:
  upstream_id: 116
  upstream_path: tips/0116-measure-time/index.md
  change: rewritten
related: [future-provider-future]
---

Need to know how long an async call takes? Wrap it in a small generic helper built on `Stopwatch`. It hands back the result and the time it took, as a record.

<?code-excerpt "stopwatch-measure-time/measure.dart" region="helper"?>
```dart
/// Runs [action] and returns its result together with how long it took.
Future<(T, Duration)> measure<T>(Future<T> Function() action) async {
  // @note monotonic: it never jumps backwards
  final stopwatch = Stopwatch()..start();
  final result = await action();
  // @note a record: the value and the time
  return (result, stopwatch.elapsed);
}
```

Calling it reads naturally, because you can destructure the record right where you await it:

<?code-excerpt "stopwatch-measure-time/measure.dart" region="usage"?>
```dart
Future<String> loadProfile(Future<String> Function() fetch) async {
  final (profile, took) = await measure(fetch);
  log('Profile loaded in ${took.inMilliseconds} ms');
  return profile;
}
```

## Why not DateTime.now()?

`DateTime.now()` reads the wall clock. The wall clock can move when the device syncs its time or the user changes it, so the difference between two readings can be wrong, or even negative.

`Stopwatch` uses a monotonic clock. It only ever moves forward, which is exactly what you want when you time code.

<?code-excerpt "stopwatch-measure-time/measure.dart" region="avoid"?>
```dart dont="Wall-clock time. It can jump while you measure."
final start = DateTime.now();
await work();
final took = DateTime.now().difference(start);
```

<?code-excerpt "stopwatch-measure-time/measure.dart" region="prefer"?>
```dart do="Monotonic. It only moves forward."
final stopwatch = Stopwatch()..start();
await work();
final took = stopwatch.elapsed;
```

## Watch out

A single run in debug mode tells you very little. Measure in profile mode (`flutter run --profile`), repeat it a few times, and look at the spread before you act on a number.

<!-- tips:nav -->

---

**#001** · Dart language · [All tips](../../../CATALOG.md)

→ Next: [#002 Column(spacing:) replaces a SizedBox between every child](../column-row-spacing/index.md)
<!-- /tips:nav -->
