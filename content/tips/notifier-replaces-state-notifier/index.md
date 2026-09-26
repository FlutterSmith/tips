---
slug: notifier-replaces-state-notifier
title: Migrate a StateNotifier to a Notifier
summary: StateNotifier now lives in legacy.dart. Moving to Notifier takes a few mechanical steps, and one behaviour change is worth knowing about.
category: state
tags: [riverpod, migration]
level: intermediate
published: 2026-09-21
status: current
packages: { flutter_riverpod: "^3.0.0" }
related: [which-provider, notifier-with-arguments, ref-mounted]
---

Riverpod 3 moved `StateNotifier` and `StateNotifierProvider` to `package:flutter_riverpod/legacy.dart`. Old code keeps compiling once you change the import, but `Notifier` is the replacement, and the move is mostly mechanical.

<?code-excerpt "notifier-replaces-state-notifier/legacy_scoreline.dart" region="state-notifier"?>
```dart dont="StateNotifier: ref passed in, initial state in super()."
// @note Riverpod 3 moved StateNotifier here
import 'package:flutter_riverpod/legacy.dart';
// ···
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
```

<?code-excerpt "notifier-replaces-state-notifier/scoreline.dart" region="notifier"?>
```dart do="Notifier: ref built in, initial state from build()."
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
```

## The steps

1. Extend `Notifier<T>` (or `AsyncNotifier<T>`) instead of `StateNotifier<T>`.
2. Move the value you passed to `super(...)` into `build()`.
3. Delete the `Ref` field and constructor parameter. `ref` is already a member.
4. Swap `StateNotifierProvider<N, T>((ref) => N(ref))` for `NotifierProvider<N, T>(N.new)`.
5. Replace `mounted` with `ref.mounted`, and `addListener` or `stream` with `listenSelf`.

Widgets don't change. `ref.watch(scorelineProvider)` and `ref.read(scorelineProvider.notifier).homeGoal()` look exactly as before.

## Watch out

`StateNotifier` notified listeners whenever the new state was not *identical* to the old one. Riverpod 3 notifiers compare with `==`. Setting a new record, list or `==`-implementing class that equals the current state is now silently skipped:

```text
reset() on 0-0 → StateNotifier: listeners run
reset() on 0-0 → Notifier: nothing happens
```

That is usually what you want, and it saves rebuilds. If your code relied on a "same value, notify anyway" update, override `updateShouldNotify` in the notifier.

## Good to know

- Don't touch `ref` or `state` in a notifier's constructor. The notifier isn't attached to a provider yet, and both throw. Do that work in `build()`.
- Values the old constructor took from `ref.read` can come from `ref.watch` in `build()`. The state then resets when that dependency changes, just as the old `StateNotifierProvider` recreated its notifier.
- Constructor arguments that came from a `.family` stay constructor arguments. See the family notifier tip for the new signature.

<!-- tips:nav -->

---

**#027** · State management · [All tips](../../../CATALOG.md)

← Previous: [#026 Show real progress with a value on progress indicators](../determinate-progress/index.md)  
→ Next: [#028 Parse JSON safely with map patterns](../json-pattern-matching/index.md)
<!-- /tips:nav -->
