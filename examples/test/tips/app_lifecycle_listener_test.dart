import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/app-lifecycle-listener/privacy_curtain.dart';

Finder get _curtain => find.byWidgetPredicate(
  (w) => w is ColoredBox && w.color == Colors.black,
);

Future<void> _moveTo(
  WidgetTester tester,
  List<AppLifecycleState> states,
) async {
  for (final state in states) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pump();
}

const _background = [
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
];

const _foreground = [
  AppLifecycleState.hidden,
  AppLifecycleState.inactive,
  AppLifecycleState.resumed,
];

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
  });

  testWidgets(
    'covers the app in the background, uncovers on resume',
    (tester) async {
      await tester.pumpWidget(
        const PrivateApp(home: Text('Balance: 1,024')),
      );
      expect(_curtain, findsNothing);

      await _moveTo(tester, [AppLifecycleState.inactive]);
      expect(_curtain, findsOneWidget);

      await _moveTo(tester, _background.skip(1).toList());
      expect(_curtain, findsOneWidget);

      await _moveTo(tester, _foreground);
      expect(_curtain, findsNothing);
      expect(find.text('Balance: 1,024'), findsOneWidget);
    },
  );

  testWidgets('no setState after dispose', (tester) async {
    await tester.pumpWidget(
      const PrivateApp(home: Text('Balance: 1,024')),
    );
    await tester.pumpWidget(const SizedBox());

    await _moveTo(tester, _background);
    await _moveTo(tester, _foreground);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onStateChange sees every state', (tester) async {
    final seen = <AppLifecycleState>[];
    await tester.pumpWidget(LifecycleLog(onChange: seen.add));

    await _moveTo(tester, _background);
    await _moveTo(tester, _foreground);
    expect(seen, [..._background, ..._foreground]);
  });
}
