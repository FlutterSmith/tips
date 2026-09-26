---
slug: selection-area
title: Make text selectable across widgets with SelectionArea
summary: Wrap a subtree in SelectionArea and one selection runs across all its Text widgets. SelectionContainer.disabled carves out the parts to skip.
category: widgets
tags: [text]
level: beginner
published: 2026-09-18
status: current
origin:
  upstream_id: 133
  upstream_path: tips/0133-selection-area/index.md
  change: kept
related: [replace-container]
---

Plain `Text` can't be selected. `SelectableText` fixes that for one block, but each block gets its own selection, so the user can't copy a heading and the paragraph under it in one go. Wrap the whole thing in `SelectionArea` instead:

<?code-excerpt "selection-area/article.dart" region="area"?>
```dart
// @note one selection across every Text below
body: SelectionArea(
  onSelectionChanged: onSelectionChanged,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Sourdough basics'),
      const Text('Feed the starter twice a day.'),
      // @note skipped by selection and copy
      SelectionContainer.disabled(
        child: TextButton(
          onPressed: () {},
          child: const Text('Share'),
        ),
      ),
      const Text('Bake at 250 degrees.'),
    ],
  ),
),
```

Every `Text` below the `SelectionArea` joins one selection. Users get the gestures their platform expects: long press and handles on mobile, click and drag on desktop and web. The context menu with Copy and Select all comes with it.

## Leave parts out

A button label in the middle of an article shouldn't end up in the clipboard. Wrap it in `SelectionContainer.disabled` and the selection skips over it.

The test for this tip drags a mouse from the heading to the last line and reads the result from `onSelectionChanged`. All three paragraphs are in it and 'Share' isn't. Without the disabled container, 'Share' is copied too.

## Good to know

- `onSelectionChanged` hands you a `SelectedContent` with the `plainText` the user selected. Use it if you need to act on the selection, for example to enable a "Quote" button.
- `contextMenuBuilder` lets you change the menu, or pass `null` to hide it.
- Put `SelectionArea` as high as makes sense, for example around a page body. Wrapping every paragraph separately brings back the one-block-at-a-time problem.
- It needs a `MaterialApp` or `CupertinoApp` above it for localized menu labels. Without Material, `SelectableRegion` is the lower-level widget it builds on.

<!-- tips:nav -->

---

**#023** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#022 Pass arguments to a Notifier through its constructor](../notifier-with-arguments/index.md)  
→ Next: [#024 firstOrNull instead of try/catch on StateError](../first-or-null/index.md)
<!-- /tips:nav -->
