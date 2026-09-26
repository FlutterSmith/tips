import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stands in for SharedPreferences, a database, or a config file.
class SettingsStore {
  SettingsStore._(this._values);

  static Future<SettingsStore> open() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return SettingsStore._({'theme': 'dark'});
  }

  final Map<String, String> _values;

  String? read(String key) => _values[key];
}

// #docregion providers
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
// #enddocregion providers

// #docregion main
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
// #enddocregion main

// #docregion widget
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
// #enddocregion widget
