---
slug: async-value-widget
title: One widget for AsyncValue loading and error states
summary: Wrap AsyncValue in a small widget with a switch over AsyncData, AsyncError and AsyncLoading, and every async screen writes only its data UI.
category: state
tags: [riverpod, widgets]
level: intermediate
published: 2026-09-11
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 15
  upstream_path: tips/0015-asyncvaluewidget-a-reusable-flutter-widget-to-work-with-asyncvalue/index.md
  change: merged
related: [ref-watch-read-listen, async-value-guard, sealed-class-result]
---

Every screen that watches a `FutureProvider` or an `AsyncNotifier` needs the same spinner and the same error text. Write them once:

<?code-excerpt "async-value-widget/async_value_view.dart" region="widget"?>
```dart
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
```

`AsyncValue` is a sealed class with three subtypes, so a `switch` expression over them is exhaustive. The object patterns pull the value or the error out as they match.

A screen now only describes the data:

<?code-excerpt "async-value-widget/async_value_view.dart" region="usage"?>
```dart
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
```

## Or use when

`AsyncValue.when` gives you the same three branches with callbacks. Pick whichever reads better to your team; they show the same thing for every state.

<?code-excerpt "async-value-widget/async_value_view.dart" region="when"?>
```dart
return value.when(
  data: data,
  error: (error, stackTrace) => Center(child: Text('$error')),
  loading: () => const Center(child: CircularProgressIndicator()),
);
```

## What a refresh looks like

When you call `ref.invalidate(productProvider)`, Riverpod keeps the old result while it fetches again. The state stays an `AsyncData` with `isLoading` set to `true`, so the switch keeps showing the product instead of flashing a spinner. `when` does the same by default (`skipLoadingOnRefresh: true`).

When a provider the product depends on changes, you get an `AsyncLoading` that still carries the old value. Both versions show the spinner then. If you'd rather keep the old data on screen, add an `AsyncLoading(:final value?)` case above `AsyncLoading()`.

## Errors from actions

This widget is for data you load. Errors from things the user does, such as saving or deleting, usually belong in a `SnackBar`. Show them with `ref.listen`, and keep the screen's data where it is.

## Watch out

- The widget returns a box widget. Inside a `CustomScrollView`, wrap the loading and error branches in `SliverToBoxAdapter`, or make a sliver version.
- Riverpod 3 retries failing providers automatically. While a retry is pending, the state is loading and `retrying` is `true`, so the spinner shows until the retries run out.

<!-- tips:nav -->

---

**#014** · State management · [All tips](../../../CATALOG.md)

← Previous: [#013 Destructure lists with list patterns](../destructure-lists/index.md)  
→ Next: [#015 Give buttons the same width with IntrinsicWidth](../intrinsic-width/index.md)
<!-- /tips:nav -->
