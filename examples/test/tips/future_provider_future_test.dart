import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/future-provider-future/combine.dart';

void main() {
  test('combines two providers', () async {
    final container = ProviderContainer.test();
    expect(await container.read(totalProvider.future), 3);
    expect(await container.read(fastTotalProvider.future), 3);
  });

  test('is loading until its inputs are ready', () {
    final container = ProviderContainer.test();
    expect(container.read(totalProvider), isA<AsyncLoading<int>>());
  });

  test('picks up overrides of its inputs', () async {
    final container = ProviderContainer.test(
      overrides: [firstProvider.overrideWith((ref) async => 40)],
    );
    expect(await container.read(fastTotalProvider.future), 42);
  });
}
