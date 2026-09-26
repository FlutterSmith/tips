import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockApi {
  final _stock = <String, int>{'lamp': 3, 'rug': 1};

  int inStock(String sku) => _stock[sku] ?? 0;
}

final stockApiProvider = Provider<StockApi>((ref) => StockApi());

// #docregion family
// @note <Notifier, state, argument>
final quantityProvider =
    NotifierProvider.family<Quantity, int, String>(
      // @note the argument goes to the constructor
      Quantity.new,
    );

class Quantity extends Notifier<int> {
  Quantity(this.sku);

  final String sku;

  @override
  int build() => 1;

  void increment() {
    // @note every method can use the argument
    final max = ref.read(stockApiProvider).inStock(sku);
    if (state < max) state++;
  }
}
// #enddocregion family

// #docregion usage
void addOneLamp(WidgetRef ref) {
  ref.read(quantityProvider('lamp').notifier).increment();
}
// #enddocregion usage
