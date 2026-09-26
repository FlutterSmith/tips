import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/replace-container/welcome_card.dart';

Widget _wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(alignment: Alignment.topLeft, child: child),
);

void main() {
  testWidgets('the nested widgets match the Container layout', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ContainerWelcomeCard()));
    final size = tester.getSize(find.byType(ContainerWelcomeCard));
    final text = tester.getRect(find.text('Welcome'));

    await tester.pumpWidget(_wrap(const WelcomeCard()));
    expect(tester.getSize(find.byType(WelcomeCard)), size);
    expect(tester.getRect(find.text('Welcome')), text);
    expect(size, const Size(240, 120));
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('they paint the same color', (tester) async {
    await tester.pumpWidget(_wrap(const WelcomeCard()));
    final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
    expect(box.color, Colors.teal);
  });

  testWidgets('a const card is not rebuilt with its parent', (
    tester,
  ) async {
    var parentBuilds = 0;
    late StateSetter rebuildParent;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            parentBuilds++;
            return const WelcomeCard();
          },
        ),
      ),
    );
    final before = tester.element(find.byType(ColoredBox)).widget;

    rebuildParent(() {});
    await tester.pump();

    expect(parentBuilds, 2);
    // Same widget instance: Flutter skipped the subtree.
    expect(
      tester.element(find.byType(ColoredBox)).widget,
      same(before),
    );
  });

  testWidgets('DecoratedBox rounds the corners', (tester) async {
    await tester.pumpWidget(_wrap(const RoundedWelcomeCard()));
    final box = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox),
    );
    final decoration = box.decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.all(Radius.circular(12)),
    );
  });
}
