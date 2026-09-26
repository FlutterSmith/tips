---
slug: elevated-button-style
title: Style an ElevatedButton with styleFrom and themes
summary: Use ElevatedButton.styleFrom for one button, ElevatedButtonThemeData for all of them, and WidgetStateProperty when a style depends on state.
category: widgets
tags: [buttons, theming]
level: beginner
published: 2026-09-23
status: current
origin:
  upstream_id: 11
  upstream_path: tips/0011-how-to-style-an-elevatedbutton-in-flutter/index.md
  change: modernized
related: [replace-container, determinate-progress]
---

`ElevatedButton` takes a `ButtonStyle`, and building one by hand is verbose. `ElevatedButton.styleFrom` takes plain values and does it for you:

<?code-excerpt "elevated-button-style/buttons.dart" region="style-from"?>
```dart
return ElevatedButton(
  // @note plain values in, a full ButtonStyle out
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.indigo,
    disabledBackgroundColor: Colors.grey.shade300,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 32),
  ),
  onPressed: onPressed,
  child: const Text('Checkout'),
);
```

`styleFrom` fills in the states for you, too: `disabledBackgroundColor` is used when `onPressed` is null, and the pressed and hover overlays are derived from `foregroundColor`.

## Style every button at once

Copying that style onto each button doesn't scale. Put it in the theme:

<?code-excerpt "elevated-button-style/buttons.dart" region="theme"?>
```dart
return MaterialApp(
  theme: ThemeData(
    // @note applies to buttons without their own style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.amber,
      ),
    ),
  ),
  home: home,
);
```

Every `ElevatedButton` without its own `style` now picks it up. A local `style` still wins, property by property: a button that only sets `backgroundColor` keeps the theme's `foregroundColor`.

## Styles that depend on state

When one property should differ per state, build a `ButtonStyle` with `WidgetStateProperty`:

<?code-excerpt "elevated-button-style/buttons.dart" region="states"?>
```dart
final pressableStyle = ButtonStyle(
  // @note called with the current states on every change
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return Colors.grey;
    if (states.contains(WidgetState.pressed)) return Colors.indigo;
    return Colors.indigo.shade300;
  }),
  foregroundColor: const WidgetStatePropertyAll(Colors.white),
);
```

`resolveWith` gets the current set of `WidgetState`s: pressed, hovered, focused, disabled and so on. Check the most specific ones first. For a value that never changes, `WidgetStatePropertyAll` saves you the function.

The test for this tip presses the button and checks that the painted color changes, then disables it and checks again.

## Migrating older code

`MaterialStateProperty` and `MaterialState` are the old names. They're deprecated aliases of `WidgetStateProperty` and `WidgetState`, so a find and replace is all it takes. Older still, `RaisedButton` and its `color` parameter are gone; `ElevatedButton` with `styleFrom` is the replacement.

<!-- tips:nav -->

---

**#029** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#028 Parse JSON safely with map patterns](../json-pattern-matching/index.md)  
→ Next: [#030 Check ref.mounted after an await in a provider](../ref-mounted/index.md)
<!-- /tips:nav -->
