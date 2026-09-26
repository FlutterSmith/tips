---
slug: ref-mounted
title: Check ref.mounted after an await in a provider
summary: A provider can be disposed while a Future is pending. Check ref.mounted after the await before you touch state, or Riverpod 3 throws.
category: state
tags: [riverpod, async]
level: intermediate
published: 2026-09-24
status: current
packages: { flutter_riverpod: "^3.0.0" }
related: [async-value-guard, context-mounted-async-gaps, notifier-replaces-state-notifier]
---

A user types a search, then leaves the screen before the results arrive. The `autoDispose` provider behind the screen is gone by the time the `await` returns. In Riverpod 3, every `Ref` and notifier member except `mounted` throws once the provider is disposed, so the write at the end blows up:

<?code-excerpt "ref-mounted/search.dart" region="unchecked"?>
```dart dont="Throws if the provider was disposed during the await."
Future<void> searchUnchecked(String query) async {
  final results = await ref.read(searchApiProvider).find(query);
  state = results;
}
```

<?code-excerpt "ref-mounted/search.dart" region="checked"?>
```dart do="Drops the result quietly when nobody is listening."
Future<void> search(String query) async {
  final results = await ref.read(searchApiProvider).find(query);
  // @note false once the provider is disposed
  if (!ref.mounted) return;
  state = results;
}
```

It's the provider version of `context.mounted`. Check it after every `await` that comes before a use of `ref` or `state`.

## A rebuild is not a dispose

What `ref.mounted` reports depends on where you ask.

In a notifier, `ref` always points at the current build. The notifier object survives rebuilds, so `ref.invalidate` or a changed dependency doesn't flip `mounted`. Only disposal does. A result that arrives after a rebuild is still written. If that's wrong for your case, compare a request id or the input before writing.

In a function provider such as `FutureProvider`, the `ref` belongs to one run of the body. When a watched provider changes, that run is over and its `ref` reports `false`. That makes a simple debounce:

<?code-excerpt "ref-mounted/search.dart" region="debounce"?>
```dart
final suggestionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final api = ref.watch(searchApiProvider);
  final query = ref.watch(searchQueryProvider);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  // @note this ref belongs to one build; a new query ends it
  if (!ref.mounted) return const [];
  return api.find(query);
});
```

Type four letters quickly and each keystroke starts a new run. The older runs wake up after 300 ms, see `mounted` is false, and return without calling the API. Only the last query is sent. The value an outdated run returns is thrown away, so `const []` never reaches the UI.

## Good to know

- `ref.onDispose` is the other tool. It runs when the provider is disposed or rebuilds, so you can cancel an HTTP request or a timer instead of waiting for it to finish. Use `mounted` when there is nothing to cancel.
- `ref.mounted` replaces `StateNotifier.mounted` when you migrate.

<!-- tips:nav -->

---

**#030** · State management · [All tips](../../../CATALOG.md)

← Previous: [#029 Style an ElevatedButton with styleFrom and themes](../elevated-button-style/index.md)  
<!-- /tips:nav -->
