import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/intrinsic-width/menu.dart';

const _labels = ['Play', 'Settings', 'Leaderboards'];

Widget _app(Widget menu, {double textScale = 1}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: menu)),
    ),
  ),
);

List<double> _buttonWidths(WidgetTester tester) => [
  for (final label in _labels)
    tester
        .getSize(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(ElevatedButton),
          ),
        )
        .width,
];

/// The width 'Leaderboards' takes as a button on its own.
Future<double> _naturalWidth(
  WidgetTester tester,
  double scale,
) async {
  await tester.pumpWidget(
    _app(
      ElevatedButton(
        onPressed: () {},
        child: const Text('Leaderboards'),
      ),
      textScale: scale,
    ),
  );
  return tester.getSize(find.byType(ElevatedButton)).width;
}

void main() {
  testWidgets('every button matches the widest one', (tester) async {
    final widest = await _naturalWidth(tester, 1);
    await tester.pumpWidget(_app(const GameMenu()));
    expect(_buttonWidths(tester), everyElement(widest));
  });

  testWidgets('the width follows the text size', (tester) async {
    final widest = await _naturalWidth(tester, 2);
    await tester.pumpWidget(_app(const GameMenu(), textScale: 2));
    expect(_buttonWidths(tester), everyElement(widest));
    expect(widest, greaterThan(160));
  });

  testWidgets('a fixed width ignores the text size', (tester) async {
    await tester.pumpWidget(
      _app(const FixedWidthGameMenu(), textScale: 2),
    );
    expect(_buttonWidths(tester), everyElement(160));
    // The long label no longer fits on one line.
    final label = tester.getSize(find.text('Leaderboards'));
    final short = tester.getSize(find.text('Play'));
    expect(label.height, greaterThan(short.height));
  });
}
