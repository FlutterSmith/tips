import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/sizedbox-shrink/discount_badge.dart';

Widget _centered(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  testWidgets('SizedBox.shrink takes no space', (tester) async {
    await tester.pumpWidget(
      _centered(const DiscountBadge(percent: 0)),
    );
    expect(tester.getSize(find.byType(DiscountBadge)), Size.zero);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('an empty Container fills the space it is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      _centered(const ContainerDiscountBadge(percent: 0)),
    );
    // Center passes loose constraints up to the screen size.
    expect(
      tester.getSize(find.byType(ContainerDiscountBadge)),
      tester.view.physicalSize / tester.view.devicePixelRatio,
    );
  });

  testWidgets('shows the discount when there is one', (tester) async {
    await tester.pumpWidget(
      _centered(const DiscountBadge(percent: 20)),
    );
    expect(find.text('-20%'), findsOneWidget);
  });

  testWidgets('tight constraints still win over shrink', (
    tester,
  ) async {
    await tester.pumpWidget(
      _centered(
        const SizedBox(
          width: 50,
          height: 10,
          child: DiscountBadge(percent: 0),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(DiscountBadge)),
      const Size(50, 10),
    );
  });

  testWidgets('collection-if leaves the badge out of the Row', (
    tester,
  ) async {
    await tester.pumpWidget(_centered(const PriceRow(price: r'$9')));
    expect(find.byType(DiscountBadge), findsNothing);
    expect(
      tester.widget<Row>(find.byType(Row)).children,
      hasLength(1),
    );

    await tester.pumpWidget(
      _centered(const PriceRow(price: r'$9', percent: 10)),
    );
    expect(find.text('-10%'), findsOneWidget);
  });

  testWidgets(
    'an empty box still gets a gap, a missing one does not',
    (tester) async {
      Future<double> height(List<Widget> children) async {
        await tester.pumpWidget(
          _centered(
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: children,
            ),
          ),
        );
        return tester.getSize(find.byType(Column)).height;
      }

      final withoutBadge = await height([const Text(r'$9')]);
      final withEmptyBadge = await height([
        const Text(r'$9'),
        const DiscountBadge(percent: 0),
      ]);
      expect(withEmptyBadge - withoutBadge, 8);
    },
  );
}
