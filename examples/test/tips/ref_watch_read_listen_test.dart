import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/ref-watch-read-listen/sign_out.dart';

class _ControlledRepository extends SessionRepository {
  final pending = Completer<void>();

  @override
  Future<void> signOut() => pending.future;
}

Widget _app(SessionRepository repository, Widget button) {
  return ProviderScope(
    overrides: [
      sessionRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(home: Scaffold(body: button)),
  );
}

bool _enabled(WidgetTester tester) => tester
    .widget<ElevatedButton>(find.byType(ElevatedButton))
    .enabled;

void main() {
  testWidgets('watch disables the button while loading', (
    tester,
  ) async {
    final repository = _ControlledRepository();
    await tester.pumpWidget(_app(repository, const SignOutButton()));
    expect(_enabled(tester), isTrue);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(_enabled(tester), isFalse);

    repository.pending.complete();
    await tester.pump();
    expect(_enabled(tester), isTrue);
  });

  testWidgets('listen shows a SnackBar on error', (tester) async {
    final repository = _ControlledRepository();
    await tester.pumpWidget(_app(repository, const SignOutButton()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    repository.pending.completeError(StateError('offline'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Bad state: offline'), findsOneWidget);
  });

  testWidgets('read in build never sees the loading state', (
    tester,
  ) async {
    final repository = _ControlledRepository();
    await tester.pumpWidget(
      _app(repository, const StaleSignOutButton()),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(_enabled(tester), isTrue);

    repository.pending.complete();
  });

  testWidgets('watch in build does', (tester) async {
    final repository = _ControlledRepository();
    await tester.pumpWidget(
      _app(repository, const FreshSignOutButton()),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(_enabled(tester), isFalse);

    repository.pending.complete();
  });

  test('the controller goes loading, then data', () async {
    final repository = _ControlledRepository();
    final container = ProviderContainer.test(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final states = <AsyncValue<void>>[];
    container.listen(signOutProvider, (_, next) => states.add(next));
    await container.read(signOutProvider.future);

    final done = container.read(signOutProvider.notifier).signOut();
    expect(container.read(signOutProvider).isLoading, isTrue);
    repository.pending.complete();
    await done;
    expect(states.last, isA<AsyncData<void>>());
  });
}
