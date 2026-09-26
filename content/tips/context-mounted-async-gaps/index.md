---
slug: context-mounted-async-gaps
title: Check context.mounted after every await
summary: A BuildContext can go stale while you await. Check context.mounted before you use it again, or grab what you need first.
category: widgets
tags: [context, async]
level: beginner
published: 2026-09-04
status: current
origin:
  upstream_id: 60
  upstream_path: tips/0060-build-context-async-gaps/index.md
  change: merged
related: [app-lifecycle-listener]
---

The user taps Save, then hits back before the request finishes. When the `await` returns, the widget that owned `context` is gone, and `Navigator.of(context)` throws. Check `context.mounted` before you touch the context again:

<?code-excerpt "context-mounted-async-gaps/save_button.dart" region="mounted"?>
```dart
return ElevatedButton(
  onPressed: () async {
    await save();
    // @note the widget may be gone by now
    if (!context.mounted) return;
    Navigator.of(context).pop();
  },
  child: const Text('Save'),
);
```

The analyzer catches the unchecked version for you. The `use_build_context_synchronously` lint is part of `flutter_lints`, so a new project already reports it:

<?code-excerpt "broken/context-mounted-async-gaps/unchecked.dart" region="unchecked"?>
```dart dont="Uses context after the await. The lint flags it."
return ElevatedButton(
  onPressed: () async {
    await save();
    Navigator.of(context).pop();
  },
  child: const Text('Save'),
);
```

<?code-excerpt "context-mounted-async-gaps/save_button.dart" region="mounted"?>
```dart do="Bails out if the widget has been unmounted."
return ElevatedButton(
  onPressed: () async {
    await save();
    // @note the widget may be gone by now
    if (!context.mounted) return;
    Navigator.of(context).pop();
  },
  child: const Text('Save'),
);
```

`mounted` lives on `BuildContext` itself, so this works in a `StatelessWidget` and in plain callbacks. Inside a `State`, the `mounted` getter does the same job:

<?code-excerpt "context-mounted-async-gaps/save_button.dart" region="state"?>
```dart
Future<void> _publish() async {
  await widget.save();
  // @note State.mounted: same check, no context needed
  if (!mounted) return;
  setState(() => _status = 'Published');
}
```

## When you still want the result

Returning early is right for navigation. For a confirmation message it means the user never sees it. In that case, look up the object you need before the gap. A `ScaffoldMessenger` lives above the route, so it outlives the page:

<?code-excerpt "context-mounted-async-gaps/save_button.dart" region="capture"?>
```dart
return ElevatedButton(
  onPressed: () async {
    // @note look it up while the context is still valid
    final messenger = ScaffoldMessenger.of(context);
    await save();
    messenger.showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  },
  child: const Text('Save'),
);
```

## Watch out

- One check covers one gap. If there's another `await` after it, check again.
- Don't silence the lint with an `ignore` comment. It is almost always pointing at a real crash waiting for a slow network.
- Capturing works for objects that outlive the widget, like `ScaffoldMessenger` or a root `Navigator`. Capturing something tied to the page itself just moves the problem.

<!-- tips:nav -->

---

**#004** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#003 Getting a Future from a FutureProvider](../future-provider-future/index.md)  
→ Next: [#005 A Result type with a sealed class](../sealed-class-result/index.md)
<!-- /tips:nav -->
