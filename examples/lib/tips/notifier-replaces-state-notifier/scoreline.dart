import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Scoreline = ({int home, int away});

final goalValueProvider = Provider<int>((ref) => 1);

// #docregion notifier
final scorelineProvider =
    NotifierProvider<ScorelineNotifier, Scoreline>(
      ScorelineNotifier.new,
    );

class ScorelineNotifier extends Notifier<Scoreline> {
  // @note the initial state moves from super() to build()
  @override
  Scoreline build() => (home: 0, away: 0);

  void homeGoal() {
    // @note ref is a member: no constructor parameter
    final points = ref.read(goalValueProvider);
    state = (home: state.home + points, away: state.away);
  }

  void reset() => state = (home: 0, away: 0);
}
// #enddocregion notifier
