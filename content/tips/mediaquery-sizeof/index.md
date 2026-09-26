---
slug: mediaquery-sizeof
title: Use MediaQuery.sizeOf instead of MediaQuery.of
summary: MediaQuery.of rebuilds your widget when anything changes. MediaQuery.sizeOf and friends rebuild only when the value you read changes.
category: widgets
tags: [performance, layout]
level: intermediate
published: 2026-09-06
status: current
origin:
  upstream_id: 108
  upstream_path: tips/0108-media-query-inherited-model/index.md
  change: modernized
related: [intrinsic-width]
---

`MediaQuery.of(context)` makes your widget depend on the whole `MediaQueryData`. The keyboard opens, the user switches to dark mode, the system text size changes: each of those rebuilds it, even if all you read was the width. Ask for the one aspect you need:

<?code-excerpt "mediaquery-sizeof/width_label.dart" region="size-of"?>
```dart
// @note subscribes to the size and nothing else
final width = MediaQuery.sizeOf(context).width;
return Text('${width.round()} px wide');
```

`MediaQuery` is an `InheritedModel`, so each `...Of` method registers a dependency on one aspect only. The widget above rebuilds when the size changes and ignores the rest.

<?code-excerpt "mediaquery-sizeof/width_label.dart" region="of"?>
```dart dont="Rebuilds when the keyboard opens, too."
// @note subscribes to every MediaQuery property
final width = MediaQuery.of(context).size.width;
return Text('${width.round()} px wide');
```

<?code-excerpt "mediaquery-sizeof/width_label.dart" region="size-of"?>
```dart do="Rebuilds only when the size changes."
// @note subscribes to the size and nothing else
final width = MediaQuery.sizeOf(context).width;
return Text('${width.round()} px wide');
```

The test for this tip counts builds: changing `viewInsets` or `platformBrightness` rebuilds the `MediaQuery.of` version and leaves the `sizeOf` version alone.

## The rest of the family

There is a method for each property you're likely to read:

<?code-excerpt "mediaquery-sizeof/width_label.dart" region="others"?>
```dart
final padding = MediaQuery.paddingOf(context);
final landscape =
    MediaQuery.orientationOf(context) == Orientation.landscape;
final scaler = MediaQuery.textScalerOf(context);
```

Others include `viewInsetsOf`, `viewPaddingOf`, `platformBrightnessOf` and `devicePixelRatioOf`. Each has a `maybe...Of` variant that returns null when there's no `MediaQuery` above.

## Good to know

- Reading two aspects means two small dependencies. That's still cheaper than depending on everything.
- `viewInsets` changes on every frame while the keyboard animates. A screen built with `MediaQuery.of` near the root rebuilds on each of those frames.
- If you need the space your widget actually gets, not the screen size, use `LayoutBuilder` instead.

<!-- tips:nav -->

---

**#007** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#006 The parts of a Riverpod 3 provider](../provider-anatomy/index.md)  
→ Next: [#008 Switch on a record to match several values at once](../switch-on-records/index.md)
<!-- /tips:nav -->
