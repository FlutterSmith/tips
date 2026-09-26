---
slug: sizedbox-shrink
title: Return SizedBox.shrink() when there is nothing to show
summary: A build method must return a widget. For "nothing", return const SizedBox.shrink(), not an empty Container.
category: widgets
tags: [widgets, layout]
level: beginner
published: 2026-09-09
status: current
origin:
  upstream_id: 69
  upstream_path: tips/0069-sizedbox-shrink/index.md
  change: kept
related: [replace-container, column-row-spacing]
---

Sometimes a widget has nothing to show, but `build` still has to return something. Return `SizedBox.shrink()`:

<?code-excerpt "sizedbox-shrink/discount_badge.dart" region="shrink"?>
```dart
if (percent == 0) {
  // @note const, zero by zero
  return const SizedBox.shrink();
}
return Text('-$percent%');
```

It asks for a size of zero by zero and it's `const`, so it costs next to nothing.

## Why not Container()?

An empty `Container` looks harmless, but it isn't const, and with no child it doesn't shrink. It expands to fill whatever space its parent allows. Inside a `Center`, that's the whole screen:

<?code-excerpt "sizedbox-shrink/discount_badge.dart" region="container"?>
```dart dont="Not const, and fills its parent."
if (percent == 0) {
  // @note no child: it grows to fill its parent
  return Container();
}
return Text('-$percent%');
```

<?code-excerpt "sizedbox-shrink/discount_badge.dart" region="shrink"?>
```dart do="Const, and takes no space."
if (percent == 0) {
  // @note const, zero by zero
  return const SizedBox.shrink();
}
return Text('-$percent%');
```

The test for this tip measures both: the `SizedBox.shrink()` badge is `Size.zero`, and the `Container` badge is as big as the test screen.

## Skip the widget entirely

Inside a `Row`, `Column` or any other list of children, you often don't need a placeholder at all. A collection `if` leaves the widget out:

<?code-excerpt "sizedbox-shrink/discount_badge.dart" region="collection-if"?>
```dart
return Row(
  spacing: 8,
  children: [
    Text(price),
    // @note no widget at all when there's no discount
    if (percent > 0) DiscountBadge(percent: percent),
  ],
);
```

This matters when the parent adds `spacing`. An empty `SizedBox` still counts as a child, so it gets a gap next to it. A missing child doesn't.

## Watch out

`SizedBox.shrink()` only asks to be small. If the parent passes tight constraints, for example a `SizedBox` with a fixed size, `Expanded`, or `CrossAxisAlignment.stretch`, the constraints win and the box grows to fit them.

<!-- tips:nav -->

---

**#011** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#010 Return multiple values with a record](../records-multiple-returns/index.md)  
→ Next: [#012 Which Riverpod 3 provider should you use?](../which-provider/index.md)
<!-- /tips:nav -->
