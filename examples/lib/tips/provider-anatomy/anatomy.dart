import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final visitorNameProvider = Provider<String>((ref) => 'Ada');

// #docregion functional
// @note the variable is the provider's identity
final greetingProvider = Provider<String>((ref) {
  // @note ref reads other providers
  final name = ref.watch(visitorNameProvider);
  return 'Hello, $name';
});
// #enddocregion functional

// #docregion notifier
// @note <the Notifier class, the state type>
final basketCountProvider = NotifierProvider<BasketCount, int>(
  BasketCount.new,
);

class BasketCount extends Notifier<int> {
  // @note build returns the initial state
  @override
  int build() => 0;

  void add() => state++;
}
// #enddocregion notifier

class Forecast {
  const Forecast(this.city, this.celsius);

  final String city;
  final int celsius;
}

class ForecastApi {
  Future<int> celsius(String city) async => city.length;
}

final forecastApiProvider = Provider<ForecastApi>(
  (ref) => ForecastApi(),
);

// #docregion modifiers
// @note <value type, argument type>
final forecastProvider = FutureProvider.family<Forecast, String>(
  // @note the family argument arrives next to ref
  (ref, city) async {
    final api = ref.watch(forecastApiProvider);
    return Forecast(city, await api.celsius(city));
  },
  // @note same as FutureProvider.autoDispose.family
  isAutoDispose: true,
);
// #enddocregion modifiers

// #docregion widget
class Greeting extends ConsumerWidget {
  const Greeting({super.key});

  @override
  // @note ConsumerWidget hands you a WidgetRef
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    return Text(greeting);
  }
}
// #enddocregion widget
