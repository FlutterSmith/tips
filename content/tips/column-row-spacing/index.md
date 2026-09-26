---
slug: column-row-spacing
title: Column(spacing:) replaces a SizedBox between every child
summary: Row, Column and Flex take a spacing value, so you no longer need a SizedBox or the gap package between children.
category: widgets
tags: [layout, widgets]
level: beginner
published: 2026-09-02
status: current
origin:
  upstream_id: 23
  upstream_path: tips/0023-the-gap-widget/index.md
  change: rewritten
---

Putting a `SizedBox` between every child of a `Column` gets old fast, and it's easy to forget one when you reorder things. `Row`, `Column` and `Flex` have a `spacing` parameter that does the job for you:

<?code-excerpt "column-row-spacing/spacing.dart" region="spacing"?>
```dart
return const Column(
  // @note one value instead of a SizedBox per gap
  spacing: 12,
  children: [
    Text('Mushrooms'),
    Text('Olives'),
    // @note no extra space after the last child
    Text('Basil'),
  ],
);
```

The layout is identical to the old way, with one number to change instead of four widgets:

<?code-excerpt "column-row-spacing/spacing.dart" region="sized-boxes"?>
```dart dont="A SizedBox per gap. Easy to miss one when you reorder."
return const Column(
  children: [
    Text('Mushrooms'),
    SizedBox(height: 12),
    Text('Olives'),
    SizedBox(height: 12),
    Text('Basil'),
  ],
);
```

<?code-excerpt "column-row-spacing/spacing.dart" region="spacing"?>
```dart do="One value on the parent. Reorder freely."
return const Column(
  // @note one value instead of a SizedBox per gap
  spacing: 12,
  children: [
    Text('Mushrooms'),
    Text('Olives'),
    // @note no extra space after the last child
    Text('Basil'),
  ],
);
```

It works the same way along a `Row`:

<?code-excerpt "column-row-spacing/spacing.dart" region="row"?>
```dart
return Row(
  spacing: 8,
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    GestureDetector(onTap: () {}, child: const Text('Cancel')),
    GestureDetector(onTap: () {}, child: const Text('Save')),
  ],
);
```

## Good to know

- `spacing` goes along the main axis only. For wrapping content, `Wrap` has had `spacing` and `runSpacing` for years.
- Space from `mainAxisAlignment` (like `spaceBetween`) is added on top of `spacing`, not instead of it.
- Need a different gap in one spot? Keep `spacing` for the common case and add a single `SizedBox` where it differs.

Before `spacing` existed, the [gap](https://pub.dev/packages/gap) package was the neat way to do this. For new code you don't need it any more.

<!-- tips:nav -->

---

**#002** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#001 Measure execution time with Stopwatch](../stopwatch-measure-time/index.md)  
→ Next: [#003 Getting a Future from a FutureProvider](../future-provider-future/index.md)
<!-- /tips:nav -->
