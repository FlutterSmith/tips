import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/context-mounted-async-gaps/save_button.dart';

/// A home page that pushes [page] when 'Open' is tapped.
Widget _app(Widget page) => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(body: page),
          ),
        ),
        child: const Text('Open'),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _goBack(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).pop();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pops the route when the save finishes in time', (
    tester,
  ) async {
    final done = Completer<void>();
    await tester.pumpWidget(
      _app(SaveButton(save: () => done.future)),
    );
    await _open(tester);

    await tester.tap(find.text('Save'));
    done.complete();
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('does nothing once the widget is unmounted', (
    tester,
  ) async {
    final done = Completer<void>();
    await tester.pumpWidget(
      _app(SaveButton(save: () => done.future)),
    );
    await _open(tester);

    await tester.tap(find.text('Save'));
    await _goBack(tester);
    done.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The home route was not popped a second time.
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('a captured messenger still shows the SnackBar', (
    tester,
  ) async {
    final done = Completer<void>();
    await tester.pumpWidget(
      _app(SaveAndNotifyButton(save: () => done.future)),
    );
    await _open(tester);

    await tester.tap(find.text('Save'));
    await _goBack(tester);
    done.complete();
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('State.mounted guards setState', (tester) async {
    final done = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(home: DraftEditor(save: () => done.future)),
    );
    await tester.tap(find.text('Draft'));
    await tester.pumpWidget(const SizedBox());
    done.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('State updates while mounted', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DraftEditor(save: () async {})),
    );
    await tester.tap(find.text('Draft'));
    await tester.pump();
    expect(find.text('Published'), findsOneWidget);
  });
}
