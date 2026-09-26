import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/selection-area/article.dart';

/// Drags a mouse from the first line to the end of the last one.
Future<void> _dragAcross(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getTopLeft(find.text('Sourdough basics')),
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump();
  await gesture.moveTo(
    tester.getBottomRight(find.text('Bake at 250 degrees.')) -
        const Offset(1, 1),
  );
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('one drag selects across several Text widgets', (
    tester,
  ) async {
    SelectedContent? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: ArticlePage(onSelectionChanged: (c) => selected = c),
      ),
    );

    await _dragAcross(tester);

    final text = selected!.plainText;
    expect(text, contains('Sourdough basics'));
    expect(text, contains('Feed the starter twice a day.'));
    expect(text, contains('Bake at 250 degrees'));
    // The disabled container is left out.
    expect(text, isNot(contains('Share')));
  });

  testWidgets('without the disabled container, Share is copied too', (
    tester,
  ) async {
    SelectedContent? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectionArea(
            onSelectionChanged: (c) => selected = c,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sourdough basics'),
                TextButton(
                  onPressed: () {},
                  child: const Text('Share'),
                ),
                const Text('Bake at 250 degrees.'),
              ],
            ),
          ),
        ),
      ),
    );
    await _dragAcross(tester);
    expect(selected!.plainText, contains('Share'));
  });
}
