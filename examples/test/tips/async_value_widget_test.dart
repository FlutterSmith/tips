import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/async-value-widget/async_value_view.dart';

Widget _app(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(home: Scaffold(body: ProductScreen())),
);

final _spinner = find.byType(CircularProgressIndicator);

Widget _both(AsyncValue<int> value) => MaterialApp(
  home: Column(
    children: [
      AsyncValueView(value: value, data: (v) => Text('switch $v')),
      AsyncValueWhenView(value: value, data: (v) => Text('when $v')),
    ],
  ),
);

final _price = NotifierProvider<_Price, double>(_Price.new);

class _Price extends Notifier<double> {
  @override
  double build() => 39;

  void cut() => state = 29;
}

void main() {
  testWidgets('shows a spinner, then the data', (tester) async {
    await tester.pumpWidget(_app(const []));
    expect(_spinner, findsOneWidget);

    await tester.pump();
    expect(_spinner, findsNothing);
    expect(find.text('Lamp: 39.0'), findsOneWidget);
  });

  testWidgets('shows the error', (tester) async {
    await tester.pumpWidget(
      _app([
        productProvider.overrideWithValue(
          AsyncError(StateError('sold out'), StackTrace.empty),
        ),
      ]),
    );
    expect(find.text('Bad state: sold out'), findsOneWidget);
  });

  testWidgets('keeps the data on screen during a refresh', (
    tester,
  ) async {
    var calls = 0;
    final second = Completer<Product>();
    await tester.pumpWidget(
      _app([
        productProvider.overrideWith(
          (ref) => calls++ == 0
              ? Future.value(const Product('Lamp', 39))
              : second.future,
        ),
      ]),
    );
    await tester.pump();

    tester.container().invalidate(productProvider);
    await tester.pump();
    final state = tester.container().read(productProvider);
    expect(state, isA<AsyncData<Product>>());
    expect(state.isLoading, isTrue);
    expect(find.text('Lamp: 39.0'), findsOneWidget);
    expect(_spinner, findsNothing);

    second.complete(const Product('Lamp', 29));
    await tester.pumpAndSettle();
    expect(find.text('Lamp: 29.0'), findsOneWidget);
  });

  testWidgets('shows the spinner when a dependency changes', (
    tester,
  ) async {
    final repriced = Completer<Product>();
    await tester.pumpWidget(
      _app([
        productProvider.overrideWith((ref) {
          final price = ref.watch(_price);
          return price == 39
              ? Future.value(Product('Lamp', price))
              : repriced.future;
        }),
      ]),
    );
    await tester.pump();
    expect(find.text('Lamp: 39.0'), findsOneWidget);

    tester.container().read(_price.notifier).cut();
    await tester.pump();
    final state = tester.container().read(productProvider);
    expect(state, isA<AsyncLoading<Product>>());
    expect(state.value?.price, 39);
    expect(_spinner, findsOneWidget);

    repriced.complete(const Product('Lamp', 29));
    await tester.pumpAndSettle();
    expect(find.text('Lamp: 29.0'), findsOneWidget);
  });

  testWidgets('switch and when agree on every state', (tester) async {
    await tester.pumpWidget(_both(const AsyncData(1)));
    expect(find.text('switch 1'), findsOneWidget);
    expect(find.text('when 1'), findsOneWidget);

    await tester.pumpWidget(_both(const AsyncLoading()));
    expect(_spinner, findsNWidgets(2));

    await tester.pumpWidget(
      _both(AsyncError(StateError('x'), StackTrace.empty)),
    );
    expect(find.text('Bad state: x'), findsNWidgets(2));
  });
}
