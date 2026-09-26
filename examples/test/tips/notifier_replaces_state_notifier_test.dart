import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/notifier-replaces-state-notifier/legacy_scoreline.dart';
import 'package:tips_examples/tips/notifier-replaces-state-notifier/scoreline.dart';

void main() {
  test('both versions reach the same state', () {
    final container = ProviderContainer.test(
      overrides: [goalValueProvider.overrideWithValue(2)],
    );
    container.read(scorelineProvider.notifier).homeGoal();
    container.read(legacyScorelineProvider.notifier).homeGoal();

    expect(container.read(scorelineProvider), (home: 2, away: 0));
    expect(
      container.read(legacyScorelineProvider),
      container.read(scorelineProvider),
    );
  });

  test('Notifier skips updates that are == to the old state', () {
    final container = ProviderContainer.test();
    var notifierUpdates = 0;
    var stateNotifierUpdates = 0;
    container.listen(scorelineProvider, (_, _) => notifierUpdates++);
    container.listen(
      legacyScorelineProvider,
      (_, _) => stateNotifierUpdates++,
    );

    // Already 0-0: a new but equal record.
    container.read(scorelineProvider.notifier).reset();
    container.read(legacyScorelineProvider.notifier).reset();

    expect(notifierUpdates, 0);
    expect(stateNotifierUpdates, 1);
  });
}
