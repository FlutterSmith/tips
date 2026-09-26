import 'package:flutter_riverpod/flutter_riverpod.dart';
// #docregion state-notifier
// @note Riverpod 3 moved StateNotifier here
import 'package:flutter_riverpod/legacy.dart';
// #enddocregion state-notifier

import 'scoreline.dart';

// #docregion state-notifier
final legacyScorelineProvider =
    StateNotifierProvider<ScorelineStateNotifier, Scoreline>(
      (ref) => ScorelineStateNotifier(ref),
    );

class ScorelineStateNotifier extends StateNotifier<Scoreline> {
  ScorelineStateNotifier(this.ref) : super((home: 0, away: 0));

  final Ref ref;

  void homeGoal() {
    final points = ref.read(goalValueProvider);
    state = (home: state.home + points, away: state.away);
  }

  void reset() => state = (home: 0, away: 0);
}
// #enddocregion state-notifier
