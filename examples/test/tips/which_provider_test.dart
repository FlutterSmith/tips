import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/which-provider/legacy.dart';
import 'package:tips_examples/tips/which-provider/providers.dart';

void main() {
  test('Provider exposes a plain value', () {
    final fixed = DateTime(2026, 9, 9);
    final container = ProviderContainer.test(
      overrides: [clockProvider.overrideWithValue(() => fixed)],
    );
    expect(container.read(clockProvider)(), fixed);
  });

  test('FutureProvider wraps the result in AsyncValue', () async {
    final container = ProviderContainer.test();
    expect(
      container.read(latestReleaseProvider),
      isA<AsyncLoading<Release>>(),
    );
    final release = await container.read(
      latestReleaseProvider.future,
    );
    expect(release.version, '3.4.3');
  });

  test('StreamProvider follows the stream', () async {
    final container = ProviderContainer.test();
    final seen = <int>[];
    container.listen(onlineUsersProvider, (_, next) {
      if (next case AsyncData(:final value)) seen.add(value);
    });
    await pumpEventQueue();
    expect(seen, [3, 5, 8]);
  });

  test('NotifierProvider is synchronous', () {
    final container = ProviderContainer.test();
    container.read(stepCounterProvider.notifier).step();
    expect(container.read(stepCounterProvider), 1);
  });

  test('AsyncNotifierProvider loads, then changes', () async {
    final container = ProviderContainer.test();
    await container.read(watchlistProvider.future);
    await container.read(watchlistProvider.notifier).add('Arrival');
    expect(container.read(watchlistProvider).value, [
      'Dune',
      'Arrival',
    ]);
  });

  test(
    'StreamNotifierProvider takes stream values and posts',
    () async {
      final container = ProviderContainer.test();
      container.listen(chatProvider, (_, _) {});
      expect(await container.read(chatProvider.future), 'Welcome');
      container.read(chatProvider.notifier).post('Hi');
      expect(container.read(chatProvider).value, 'Hi');
    },
  );

  test('StateProvider still works from legacy.dart', () {
    final container = ProviderContainer.test();
    container.read(currentPageProvider.notifier).state = 2;
    expect(container.read(currentPageProvider), 2);
  });
}
