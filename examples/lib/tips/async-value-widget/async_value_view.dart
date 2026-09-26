import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// #docregion widget
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;

  @override
  Widget build(BuildContext context) {
    // @note AsyncValue is sealed: miss a case and it won't compile
    return switch (value) {
      AsyncData(:final value) => data(value),
      AsyncError(:final error) => Center(
        child: Text(
          '$error',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      AsyncLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
    };
  }
}
// #enddocregion widget

class AsyncValueWhenView<T> extends StatelessWidget {
  const AsyncValueWhenView({
    super.key,
    required this.value,
    required this.data,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;

  @override
  Widget build(BuildContext context) {
    // #docregion when
    return value.when(
      data: data,
      error: (error, stackTrace) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
    // #enddocregion when
  }
}

class Product {
  const Product(this.name, this.price);

  final String name;
  final double price;
}

final productProvider = FutureProvider<Product>(
  (ref) async => const Product('Lamp', 39),
);

// #docregion usage
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView(
      value: ref.watch(productProvider),
      // @note only the happy path is left to write
      data: (product) => Text('${product.name}: ${product.price}'),
    );
  }
}
// #enddocregion usage
