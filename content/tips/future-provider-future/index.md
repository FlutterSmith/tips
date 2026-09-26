---
slug: future-provider-future
title: Getting a Future from a FutureProvider
summary: Watch provider.future to await one async provider inside another, and combine the results with plain async code.
category: state
tags: [riverpod, providers, async]
level: intermediate
published: 2026-09-03
status: current
origin:
  upstream_id: 110
  upstream_path: tips/0110-riverpod-watch-future-provider/index.md
  change: modernized
related: [stopwatch-measure-time]
---

When one async provider depends on another, don't unwrap `AsyncValue` by hand. Watch `.future` instead, and you get a plain `Future` you can await:

<?code-excerpt "future-provider-future/combine.dart" region="sequential"?>
```dart
final totalProvider = FutureProvider<int>((ref) async {
  // @note .future is the Future behind the provider
  final a = await ref.watch(firstProvider.future);
  final b = await ref.watch(secondProvider.future);
  // @note plain async code from here on
  return a + b;
});
```

While either input is still loading, `totalProvider` is in its loading state too. If one of them fails, the error flows through to `totalProvider`. You write the happy path and Riverpod does the rest.

## Run them in parallel

The version above waits for `firstProvider` before it even starts watching `secondProvider`. Watch both first, then wait for them together with a record's `.wait`:

<?code-excerpt "future-provider-future/combine.dart" region="parallel"?>
```dart
final fastTotalProvider = FutureProvider<int>((ref) async {
  // @note both start now, so they run in parallel
  final (a, b) = await (
    ref.watch(firstProvider.future),
    ref.watch(secondProvider.future),
  ).wait;
  return a + b;
});
```

## Good to know

- It works the same for `StreamProvider`: `.future` gives you the next value as a `Future`.
- Use `ref.watch`, not `ref.read`. Watching means `totalProvider` recomputes when an input changes.
- In tests, `container.read(totalProvider.future)` lets you await the final value directly.

<!-- tips:nav -->

---

**#003** · State management · [All tips](../../../CATALOG.md)

← Previous: [#002 Column(spacing:) replaces a SizedBox between every child](../column-row-spacing/index.md)  
→ Next: [#004 Check context.mounted after every await](../context-mounted-async-gaps/index.md)
<!-- /tips:nav -->
