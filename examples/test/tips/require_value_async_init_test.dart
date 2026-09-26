import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/require-value-async-init/startup.dart';

final _retriedStoreProvider = FutureProvider<SettingsStore>(
  (ref) => throw Exception('no disk'),
);

void main() {
  test('requireValue throws while the store is loading', () {
    final container = ProviderContainer.test();
    expect(
      () => container.read(themeModeProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<AsyncValueIsLoadingException>(),
        ),
      ),
    );
  });

  test('after awaiting .future, reads are synchronous', () async {
    final container = ProviderContainer.test();
    await container.read(settingsStoreProvider.future);
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('with retry off, a failed init fails at once', () {
    fakeAsync((async) {
      final container = ProviderContainer.test(
        overrides: [
          settingsStoreProvider.overrideWith(
            (ref) => throw Exception('no disk'),
          ),
        ],
      );
      Object? error;
      container
          .read(settingsStoreProvider.future)
          .then(
            (_) {},
            onError: (Object e) {
              error = e;
            },
          );
      async.flushMicrotasks();
      expect(error, isA<Exception>());
    });
  });

  test('with default retry, the Future keeps waiting', () {
    fakeAsync((async) {
      final container = ProviderContainer.test();
      var done = false;
      container
          .read(_retriedStoreProvider.future)
          .then(
            (_) {},
            onError: (Object _) {
              done = true;
            },
          );
      async.elapse(const Duration(seconds: 5));
      expect(done, isFalse);
    });
  });

  testWidgets('the app reads the theme without a loading state', (
    tester,
  ) async {
    final container = ProviderContainer.test();
    await tester.runAsync(
      () => container.read(settingsStoreProvider.future),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SettingsApp(),
      ),
    );
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
