---
slug: intrinsic-width
title: Give buttons the same width with IntrinsicWidth
summary: Wrap a Column in IntrinsicWidth and stretch its children, and every button matches the widest one, whatever the text size.
category: widgets
tags: [layout]
level: intermediate
published: 2026-09-11
status: current
origin:
  upstream_id: 136
  upstream_path: tips/0136-intrinsic-width/index.md
  change: kept
related: [column-row-spacing, replace-container]
---

A menu of buttons looks ragged when each one is as wide as its own label. The quick fix is a fixed width, but that number is a guess. It stops fitting as soon as the user bumps up the system text size, or a translation runs longer.

Let the widest child set the width instead:

<?code-excerpt "intrinsic-width/menu.dart" region="intrinsic"?>
```dart
// @note sizes the column to its widest child
return IntrinsicWidth(
  child: Column(
    spacing: 8,
    // @note then every button stretches to that width
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(onPressed: () {}, child: const Text('Play')),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Settings'),
      ),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Leaderboards'),
      ),
    ],
  ),
);
```

`IntrinsicWidth` asks the `Column` how wide it would like to be, which is the width of its widest child, and gives it exactly that. `CrossAxisAlignment.stretch` then makes every button fill it. Without `IntrinsicWidth`, `stretch` would pull the buttons across the whole screen.

<?code-excerpt "intrinsic-width/menu.dart" region="fixed"?>
```dart dont="160 fits today. Double the text size and labels wrap."
return SizedBox(
  // @note a guess that breaks with larger text
  width: 160,
  child: Column(
    spacing: 8,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(onPressed: () {}, child: const Text('Play')),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Settings'),
      ),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Leaderboards'),
      ),
    ],
  ),
);
```

<?code-excerpt "intrinsic-width/menu.dart" region="intrinsic"?>
```dart do="As wide as the longest label, at any text size."
// @note sizes the column to its widest child
return IntrinsicWidth(
  child: Column(
    spacing: 8,
    // @note then every button stretches to that width
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(onPressed: () {}, child: const Text('Play')),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Settings'),
      ),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Leaderboards'),
      ),
    ],
  ),
);
```

The test for this tip renders the menu at 1x and 2x text scale. Each time, all three buttons are exactly as wide as the 'Leaderboards' button on its own. The fixed version stays at 160 and the long label wraps onto a second line.

## Watch out

`IntrinsicWidth` isn't free. To answer "how wide would you like to be?", Flutter runs an extra, speculative layout pass over the subtree before the real one. The Flutter docs call it relatively expensive and warn that nesting it can make layout O(N²) in the depth of the tree.

For a short menu or a dialog's actions that cost doesn't matter. Don't wrap long lists or deep trees in it, and never put it inside each item of a `ListView`.

## Good to know

`IntrinsicHeight` does the same thing vertically. It's handy for a `Row` whose children should all be as tall as the tallest one, for example a divider next to a card of text.

<!-- tips:nav -->

---

**#015** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#014 One widget for AsyncValue loading and error states](../async-value-widget/index.md)  
→ Next: [#016 Await several futures with a record's .wait](../future-wait-records/index.md)
<!-- /tips:nav -->
