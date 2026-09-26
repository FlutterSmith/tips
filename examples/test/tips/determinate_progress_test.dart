import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/determinate-progress/upload_progress.dart';

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

double? _ringValue(WidgetTester tester) => tester
    .widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    )
    .value;

void main() {
  testWidgets('both indicators show the same value', (tester) async {
    await tester.pumpWidget(
      _app(const UploadProgress(progress: 0.4)),
    );
    expect(_ringValue(tester), 0.4);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0.4,
    );
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('a value means no animation of its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const UploadProgress(progress: 0.4)),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('no value means it spins forever', (tester) async {
    await tester.pumpWidget(_app(const CircularProgressIndicator()));
    await tester.pump(const Duration(seconds: 10));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('the countdown runs from 1.0 down to 0.0', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const CountdownRing(duration: Duration(seconds: 10))),
    );
    expect(_ringValue(tester), 1);

    await tester.pump(const Duration(seconds: 5));
    expect(_ringValue(tester), closeTo(0.5, 0.01));

    await tester.pumpAndSettle();
    expect(_ringValue(tester), 0);
  });

  testWidgets('screen readers get the value from 0 to 100', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const UploadProgress(progress: 0.4)),
    );
    expect(
      tester.getSemantics(find.byType(LinearProgressIndicator)).value,
      '40',
    );
    handle.dispose();
  });

  testWidgets('values above 1.0 are clamped', (tester) async {
    await tester.pumpWidget(
      _app(const UploadProgress(progress: 1.2)),
    );
    expect(tester.takeException(), isNull);
    final handle = tester.ensureSemantics();
    await tester.pump();
    expect(
      tester
          .getSemantics(find.byType(CircularProgressIndicator))
          .value,
      '100',
    );
    handle.dispose();
  });
}
