---
slug: ref-watch-read-listen
title: ref.watch, ref.read or ref.listen?
summary: Watch to rebuild, read for a one-off value inside a callback, listen to run side effects like SnackBars.
category: state
tags: [riverpod]
level: beginner
published: 2026-09-07
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 46
  upstream_path: tips/0046-riverpod-difference-between-ref-watch-ref-read-ref-listen/index.md
  change: modernized
related: [provider-anatomy, async-value-guard, async-value-widget]
---

`Ref` and `WidgetRef` give you three ways to get at a provider, and picking the wrong one leads to stale UI or wasted rebuilds. The short version:

- `ref.watch`: use the value and rebuild when it changes.
- `ref.read`: get the value once, right now. For callbacks and notifier methods.
- `ref.listen`: run code when the value changes, without rebuilding.

A sign-out button needs all three. The controller does the work:

<?code-excerpt "ref-watch-read-listen/sign_out.dart" region="controller"?>
```dart
final signOutProvider =
    AsyncNotifierProvider<SignOutController, void>(
      SignOutController.new,
    );

class SignOutController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signOut() async {
    // @note read: we want the repository once, right now
    final repository = ref.read(sessionRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(repository.signOut);
  }
}
```

The button watches the state to disable itself, reads the notifier when tapped, and listens for errors to show a `SnackBar`:

<?code-excerpt "ref-watch-read-listen/sign_out.dart" region="button"?>
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // @note listen: side effects, no rebuild
  ref.listen(signOutProvider, (previous, next) {
    if (next case AsyncError(:final error)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  });
  // @note watch: rebuild when the state changes
  final state = ref.watch(signOutProvider);
  return ElevatedButton(
    onPressed: state.isLoading
        ? null
        // @note read: one call inside a callback
        : () => ref.read(signOutProvider.notifier).signOut(),
    child: const Text('Sign out'),
  );
}
```

## Why not read in build?

`ref.read` in `build` gives you the value at that moment and never subscribes. The button stays enabled while the sign-out runs, because nothing tells it to rebuild.

<?code-excerpt "ref-watch-read-listen/sign_out.dart" region="read-in-build"?>
```dart dont="Reads once. The widget misses every later change."
final state = ref.read(signOutProvider);
```

<?code-excerpt "ref-watch-read-listen/sign_out.dart" region="watch-in-build"?>
```dart do="Subscribes. The widget rebuilds on each change."
final state = ref.watch(signOutProvider);
```

## Why not watch in a callback?

The opposite mistake: `ref.watch` inside `onPressed` or a notifier method. A callback runs once and returns, so there is nothing to rebuild. Use `ref.read` there.

## Good to know

- Inside providers the rules are the same. `ref.watch` in the provider body or `build`, `ref.read` in notifier methods.
- `ref.listen` in a widget's `build` is safe. Riverpod removes the old listener each time the widget rebuilds, so you never get duplicates.
- The listener gets `previous` and `next`. Compare them when you only care about a transition, such as loading to data.
- Need a listener outside `build`, say in `initState`? Use `ref.listenManual` and close the subscription it returns.

<!-- tips:nav -->

---

**#009** · State management · [All tips](../../../CATALOG.md)

← Previous: [#008 Switch on a record to match several values at once](../switch-on-records/index.md)  
→ Next: [#010 Return multiple values with a record](../records-multiple-returns/index.md)
<!-- /tips:nav -->
