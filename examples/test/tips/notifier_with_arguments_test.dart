import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/notifier-with-arguments/quantity.dart';

void main() {
  test('each argument has its own state', () {
    final container = ProviderContainer.test();
    container.read(quantityProvider('lamp').notifier).increment();
    expect(container.read(quantityProvider('lamp')), 2);
    expect(container.read(quantityProvider('rug')), 1);
  });

  test('the notifier keeps the argument it was built with', () {
    final container = ProviderContainer.test();
    final lamp = container.read(quantityProvider('lamp').notifier);
    expect(lamp.sku, 'lamp');
    expect(
      container.read(quantityProvider('lamp').notifier),
      same(lamp),
    );
  });

  test('methods use the argument without it being passed', () {
    final container = ProviderContainer.test();
    final rug = container.read(quantityProvider('rug').notifier);
    rug.increment();
    expect(container.read(quantityProvider('rug')), 1);

    final lamp = container.read(quantityProvider('lamp').notifier);
    for (var i = 0; i < 5; i++) {
      lamp.increment();
    }
    expect(container.read(quantityProvider('lamp')), 3);
  });

  testWidgets('widgets pass the argument when they call it', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => GestureDetector(
            onTap: () => addOneLamp(ref),
            child: Text(
              '${ref.watch(quantityProvider('lamp'))}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });
}
