import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/provider-anatomy/anatomy.dart';

void main() {
  test('the body uses ref to read another provider', () {
    final container = ProviderContainer.test(
      overrides: [visitorNameProvider.overrideWithValue('Grace')],
    );
    expect(container.read(greetingProvider), 'Hello, Grace');
  });

  test('a notifier starts from build and changes via methods', () {
    final container = ProviderContainer.test();
    expect(container.read(basketCountProvider), 0);
    container.read(basketCountProvider.notifier).add();
    container.read(basketCountProvider.notifier).add();
    expect(container.read(basketCountProvider), 2);
  });

  test('each family argument gets its own provider', () async {
    final container = ProviderContainer.test();
    final oslo = await container.read(
      forecastProvider('Oslo').future,
    );
    final lima = await container.read(
      forecastProvider('Lima').future,
    );
    expect(oslo.city, 'Oslo');
    expect(lima.city, 'Lima');
    expect(forecastProvider('Oslo'), forecastProvider('Oslo'));
  });

  test(
    'isAutoDispose drops the state with its last listener',
    () async {
      final container = ProviderContainer.test();
      final provider = forecastProvider('Oslo');
      final sub = container.listen(provider, (_, _) {});
      await container.read(provider.future);
      expect(container.exists(provider), isTrue);
      sub.close();
      await container.pump();
      expect(container.exists(provider), isFalse);
    },
  );

  testWidgets('ConsumerWidget watches the provider', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Greeting(),
        ),
      ),
    );
    expect(find.text('Hello, Ada'), findsOneWidget);
  });
}
