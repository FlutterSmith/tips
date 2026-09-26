import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/elevated-button-style/buttons.dart';

/// The color the button actually paints.
Color? _background(WidgetTester tester, String label) => tester
    .widget<Material>(
      find.descendant(
        of: find.widgetWithText(ElevatedButton, label),
        matching: find.byType(Material),
      ),
    )
    .color;

void main() {
  testWidgets('styleFrom sets the colors and shape', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CheckoutButton(onPressed: () {})),
    );
    expect(_background(tester, 'Checkout'), Colors.indigo);
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.shape, isA<StadiumBorder>());
  });

  testWidgets('styleFrom covers the disabled state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CheckoutButton()),
    );
    expect(_background(tester, 'Checkout'), Colors.grey.shade300);
  });

  testWidgets('the theme styles every unstyled button', (
    tester,
  ) async {
    await tester.pumpWidget(
      ShopApp(
        home: Column(
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('A')),
            ElevatedButton(onPressed: () {}, child: const Text('B')),
            CheckoutButton(onPressed: () {}),
          ],
        ),
      ),
    );
    expect(_background(tester, 'A'), Colors.amber);
    expect(_background(tester, 'B'), Colors.amber);
    // A local style wins over the theme.
    expect(_background(tester, 'Checkout'), Colors.indigo);
  });

  testWidgets('WidgetStateProperty follows the state', (
    tester,
  ) async {
    Widget button({required bool enabled}) => MaterialApp(
      home: Center(
        child: ElevatedButton(
          style: pressableStyle,
          onPressed: enabled ? () {} : null,
          child: const Text('Go'),
        ),
      ),
    );

    await tester.pumpWidget(button(enabled: true));
    expect(_background(tester, 'Go'), Colors.indigo.shade300);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Go')),
    );
    await tester.pump();
    expect(_background(tester, 'Go'), Colors.indigo);
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.pumpWidget(button(enabled: false));
    expect(_background(tester, 'Go'), Colors.grey);
  });

  testWidgets('a local style overrides the theme per property', (
    tester,
  ) async {
    await tester.pumpWidget(
      ShopApp(
        home: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {},
          child: const Text('Mixed'),
        ),
      ),
    );
    expect(_background(tester, 'Mixed'), Colors.red);
    final text = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Mixed'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(text.style.color, Colors.black);
  });
}
