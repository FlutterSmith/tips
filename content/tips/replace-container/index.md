---
slug: replace-container
title: Replace Container with the widgets it wraps
summary: Container is a bundle of Padding, ColoredBox, DecoratedBox, Align and SizedBox. Use those directly and the whole subtree can be const.
category: widgets
tags: [widgets, layout]
level: beginner
published: 2026-09-13
status: current
origin:
  upstream_id: 135
  upstream_path: tips/0135-replace-container-nested-widgets/index.md
  change: kept
related: [sizedbox-shrink, intrinsic-width]
---

`Container` is convenient, but it has no `const` constructor. Every time its parent rebuilds, Flutter gets a new `Container` and runs its build again, even when nothing changed.

<?code-excerpt "replace-container/welcome_card.dart" region="container"?>
```dart
// @note not const: Container has no const constructor
return Container(
  width: 240,
  height: 120,
  color: Colors.teal,
  padding: const EdgeInsets.all(16),
  alignment: Alignment.center,
  child: const Text('Welcome'),
);
```

Under the hood, `Container` just builds other widgets for you, one per property you set. Build them yourself and the whole card becomes `const`:

<?code-excerpt "replace-container/welcome_card.dart" region="nested"?>
```dart
// @note the whole subtree is const now
return const SizedBox(
  width: 240,
  height: 120,
  child: ColoredBox(
    color: Colors.teal,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Welcome')),
    ),
  ),
);
```

The layout is identical. The test for this tip renders both and gets the same 240 by 120 box, with the text in exactly the same place. It also rebuilds the parent and checks that Flutter reuses the same `ColoredBox` instance rather than building a new one.

## Which widget for which property

- `width`, `height`, `constraints`: `SizedBox` or `ConstrainedBox`
- `color`: `ColoredBox`
- `decoration` (borders, radius, gradient, shadow): `DecoratedBox`
- `padding` and `margin`: `Padding`
- `alignment`: `Align`, or `Center`

The order matters. `Container` puts the padding inside the color, and the size outside both, so nest them the same way: size, then color, then padding, then alignment.

For rounded corners, reach for `DecoratedBox`:

<?code-excerpt "replace-container/welcome_card.dart" region="decorated"?>
```dart
return const DecoratedBox(
  decoration: BoxDecoration(
    color: Colors.teal,
    // @note DecoratedBox for borders, radius, gradients
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Welcome'),
  ),
);
```

## Is Container bad?

No. When a style depends on runtime values, nothing can be `const` anyway, and one `Container` reads better than five nested widgets. Use the specific widgets when the values are known at compile time, or when you only need one of them: a `Container` with just `padding` is a `Padding` with extra steps.

<!-- tips:nav -->

---

**#017** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#016 Await several futures with a record's .wait](../future-wait-records/index.md)  
→ Next: [#018 AsyncValue.guard instead of try/catch in notifiers](../async-value-guard/index.md)
<!-- /tips:nav -->
