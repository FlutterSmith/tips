---
slug: require-value-async-init
title: Initialise async dependencies in main() and use requireValue
summary: Await a FutureProvider once before runApp, then read it synchronously everywhere with requireValue. No loading states for things that are always ready.
category: state
tags: [riverpod, async]
level: intermediate
published: 2026-09-19
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 131
  upstream_path: tips/0131-future-provider-require-value/index.md
  change: modernized
related: [future-provider-future, which-provider, async-value-widget]
---

Some dependencies are async to create but should be ready before the first frame: `SharedPreferences`, a local database, a config file. If you expose them through a `FutureProvider`, every provider that uses them turns async too. That's a lot of loading states for something that takes a few milliseconds at startup.

Declare the dependency as a `FutureProvider`, and let the providers that need it unwrap it with `requireValue`:

<?code-excerpt "require-value-async-init/startup.dart" region="providers"?>
```dart
final settingsStoreProvider = FutureProvider<SettingsStore>(
  (ref) => SettingsStore.open(),
  // @note fail fast at startup instead of retrying
  retry: (retryCount, error) => null,
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  // @note sync: main() already waited for the store
  final store = ref.watch(settingsStoreProvider).requireValue;
  return store.read('theme') == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;
});
```

Then make sure it is ready before the app starts. Create the `ProviderContainer` yourself, await the provider's `.future`, and hand the container to `UncontrolledProviderScope`:

<?code-excerpt "require-value-async-init/startup.dart" region="main"?>
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // @note wait for the async dependency once
  await container.read(settingsStoreProvider.future);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SettingsApp(),
    ),
  );
}
```

From here on, widgets use the dependency like any sync value:

<?code-excerpt "require-value-async-init/startup.dart" region="widget"?>
```dart
class SettingsApp extends ConsumerWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // @note no AsyncValue, no loading branch
      themeMode: ref.watch(themeModeProvider),
      home: const Scaffold(),
    );
  }
}
```

## Why requireValue?

`AsyncValue.value` is nullable in Riverpod 3, so you'd need a `!` or a fallback. `requireValue` returns the value or throws, which is what you want here: if the store isn't ready, that's a bug in startup, not a state to render.

Read it too early and it throws `AsyncValueIsLoadingException`. If the provider failed, it throws a `ProviderException` that wraps the original error.

## Watch out

Riverpod 3 retries failing providers by default, up to ten times with growing delays. Only `Error`s such as `StateError` skip the retries. While retries are pending, `.future` doesn't complete. If opening the store throws at startup, `main()` would sit on the splash screen instead of failing. `retry: (retryCount, error) => null` turns that off for this one provider, so the error reaches `main()` straight away and you can show a proper error screen.

## Good to know

- Before this pattern, the usual trick was a provider that throws `UnimplementedError` and an `overrideWithValue` in `main()`. It still works. The version above keeps the real implementation in the provider, so tests only need to await it or override it.
- In tests, `await container.read(settingsStoreProvider.future)` first, just as `main()` does.

<!-- tips:nav -->

---

**#025** · State management · [All tips](../../../CATALOG.md)

← Previous: [#024 firstOrNull instead of try/catch on StateError](../first-or-null/index.md)  
→ Next: [#026 Show real progress with a value on progress indicators](../determinate-progress/index.md)
<!-- /tips:nav -->
