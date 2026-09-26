import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/column-row-spacing/spacing.dart';

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(alignment: Alignment.topLeft, child: child),
);

double _gap(WidgetTester tester, String above, String below) =>
    tester.getTopLeft(find.text(below)).dy -
    tester.getBottomLeft(find.text(above)).dy;

void main() {
  testWidgets('spacing puts 12 px between children', (tester) async {
    await tester.pumpWidget(_wrap(const Toppings()));
    expect(_gap(tester, 'Mushrooms', 'Olives'), 12);
    expect(_gap(tester, 'Olives', 'Basil'), 12);
  });

  testWidgets('matches the SizedBox layout exactly', (tester) async {
    await tester.pumpWidget(_wrap(const Toppings()));
    final withSpacing = tester.getSize(find.byType(Column));
    await tester.pumpWidget(_wrap(const ToppingsWithSizedBoxes()));
    expect(tester.getSize(find.byType(Column)), withSpacing);
  });

  testWidgets('Row spacing works horizontally', (tester) async {
    await tester.pumpWidget(_wrap(const DialogActions()));
    final gap =
        tester.getTopLeft(find.text('Save')).dx -
        tester.getTopRight(find.text('Cancel')).dx;
    expect(gap, 8);
  });
}
