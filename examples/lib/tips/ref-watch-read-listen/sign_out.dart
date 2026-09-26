import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionRepository {
  Future<void> signOut() async {}
}

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(),
);

// #docregion controller
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
// #enddocregion controller

class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  // #docregion button
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
  // #enddocregion button
}

class StaleSignOutButton extends ConsumerWidget {
  const StaleSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #docregion read-in-build
    final state = ref.read(signOutProvider);
    // #enddocregion read-in-build
    return ElevatedButton(
      onPressed: state.isLoading
          ? null
          : () => ref.read(signOutProvider.notifier).signOut(),
      child: const Text('Sign out'),
    );
  }
}

class FreshSignOutButton extends ConsumerWidget {
  const FreshSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #docregion watch-in-build
    final state = ref.watch(signOutProvider);
    // #enddocregion watch-in-build
    return ElevatedButton(
      onPressed: state.isLoading
          ? null
          : () => ref.read(signOutProvider.notifier).signOut(),
      child: const Text('Sign out'),
    );
  }
}
