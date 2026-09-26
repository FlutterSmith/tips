---
slug: notifier-with-arguments
title: Pass arguments to a Notifier through its constructor
summary: In Riverpod 3 a family notifier is a plain Notifier that takes its argument in the constructor, so every method can use it as a field.
category: state
tags: [riverpod, providers]
level: intermediate
published: 2026-09-17
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 97
  upstream_path: tips/0097-riverpod-notifier-build-argument/index.md
  change: modernized
related: [provider-anatomy, which-provider, notifier-replaces-state-notifier]
---

A basket needs one quantity per product, and the method that changes it needs to know which product it is working on. In Riverpod 3 you give the notifier a constructor parameter and store it in a field:

<?code-excerpt "notifier-with-arguments/quantity.dart" region="family"?>
```dart
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
```

`NotifierProvider.family` calls the function you give it with the argument. `Quantity.new` is a constructor tear-off, so the argument lands in `sku`. From then on, `build` and every method can read it without passing it around.

Callers pick the instance by calling the provider with an argument:

<?code-excerpt "notifier-with-arguments/quantity.dart" region="usage"?>
```dart
void addOneLamp(WidgetRef ref) {
  ref.read(quantityProvider('lamp').notifier).increment();
}
```

## What changed from Riverpod 2

Riverpod 2 had a separate `FamilyNotifier` class. The argument came in through `build(String sku)` and methods read it back from a getter called `arg`. That class is gone:

<?code-excerpt "broken/notifier-with-arguments/family_notifier.dart" region="old"?>
```dart
class OldQuantity extends FamilyNotifier<int, String> {
  @override
  int build(String sku) => 1;

  void increment() {
    // `arg` held the argument.
    if (arg.isNotEmpty) state++;
  }
}
```

To migrate, extend `Notifier`, move the `build` parameter into the constructor, and rename `arg` to your field. The same goes for `AsyncNotifier` and `StreamNotifier`. There are no family variants of those either.

## Good to know

- One instance per argument. `quantityProvider('lamp')` returns the same notifier every time you call it with `'lamp'`, and `'rug'` gets its own.
- Arguments are compared with `==`. Strings, numbers, enums and records work out of the box. For your own classes, implement `==` and `hashCode`, or every call creates a new provider.
- Need more than one argument? Pass a record, such as `(shop: 'north', sku: 'lamp')`. Records already have value equality.
- Add `.autoDispose` (or `isAutoDispose: true`) if the per-argument state should go away when no screen shows that product.

<!-- tips:nav -->

---

**#022** · State management · [All tips](../../../CATALOG.md)

← Previous: [#021 Skip nulls in collection literals with ...? and ?value](../null-aware-elements/index.md)  
→ Next: [#023 Make text selectable across widgets with SelectionArea](../selection-area/index.md)
<!-- /tips:nav -->
