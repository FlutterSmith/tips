---
slug: async-value-guard
title: AsyncValue.guard instead of try/catch in notifiers
summary: AsyncValue.guard runs a Future and hands back AsyncData or AsyncError, so notifier methods need no try/catch.
category: state
tags: [riverpod, errors]
level: intermediate
published: 2026-09-14
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 44
  upstream_path: tips/0044-async-value-guard-vs-try-catch/index.md
  change: modernized
related: [ref-mounted, async-value-widget, ref-watch-read-listen]
---

A method on an `AsyncNotifier` that saves or deletes something has to set three states: loading, then data or error. With `try`/`catch` you write each one out by hand:

<?code-excerpt "async-value-guard/save_note.dart" region="try-catch"?>
```dart dont="Three assignments, and easy to forget the stack trace."
Future<void> saveWithTryCatch(String text) async {
  final api = ref.read(notesApiProvider);
  state = const AsyncLoading();
  try {
    await api.save(text);
    state = const AsyncData(null);
  } catch (error, stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}
```

<?code-excerpt "async-value-guard/save_note.dart" region="guard"?>
```dart do="One call. Data or error, with the stack trace."
Future<void> save(String text) async {
  final api = ref.read(notesApiProvider);
  state = const AsyncLoading();
  // @note data on success, AsyncError on any throw
  state = await AsyncValue.guard(() => api.save(text));
}
```

`AsyncValue.guard` awaits the function you pass. If it completes, you get `AsyncData` with the result. If it throws, you get `AsyncError` with the error and its stack trace. The widget watching `saveNoteProvider` sees the same states either way.

## Good to know

- `guard` catches everything, `Error`s included. Pass a second argument to be picky: `AsyncValue.guard(save, (e) => e is! ArgumentError)` rethrows anything the test rejects.
- Setting `state` to `AsyncLoading` or `AsyncError` keeps the previous value. `state.value` still returns the last good data, which lets the UI keep showing it next to the error.
- The notifier doesn't throw, so the caller doesn't need its own `try`. Show the error from the state with `ref.listen`.

## Watch out

The `await` is a gap. If the provider is disposed before the save finishes (say an `autoDispose` provider whose screen was closed), setting `state` afterwards throws. Check `ref.mounted` before the last write:

<?code-excerpt "async-value-guard/save_note.dart" region="mounted"?>
```dart
Future<void> save(String text) async {
  final api = ref.read(notesApiProvider);
  state = const AsyncLoading();
  final result = await AsyncValue.guard(() => api.save(text));
  // @note the screen may have closed during the await
  if (!ref.mounted) return;
  state = result;
}
```

Keeping the guard result in a local first means the check sits between the await and the write, where it belongs.

<!-- tips:nav -->

---

**#018** · State management · [All tips](../../../CATALOG.md)

← Previous: [#017 Replace Container with the widgets it wraps](../replace-container/index.md)  
→ Next: [#019 Extension types vs extension methods](../extension-types/index.md)
<!-- /tips:nav -->
