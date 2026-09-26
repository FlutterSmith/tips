---
slug: provider-anatomy
title: The parts of a Riverpod 3 provider
summary: A provider is a global variable, a type, a body that gets a Ref, and optional modifiers. Here is what each part does.
category: state
tags: [riverpod, providers]
level: beginner
published: 2026-09-05
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 40
  upstream_path: tips/0040-anatomy-of-a-riverpod-provider/index.md
  change: rewritten
related: [which-provider, ref-watch-read-listen, notifier-with-arguments]
---

Riverpod code is easier to read once you can name the parts of a declaration. Without code generation, every provider is a top-level `final` built from the same few pieces:

<?code-excerpt "provider-anatomy/anatomy.dart" region="functional"?>
```dart
// @note the variable is the provider's identity
final greetingProvider = Provider<String>((ref) {
  // @note ref reads other providers
  final name = ref.watch(visitorNameProvider);
  return 'Hello, $name';
});
```

- **The variable** (`greetingProvider`) is how the rest of the app finds this value. It is not the value itself; the value lives in a `ProviderContainer`.
- **The type argument** (`<String>`) is what the provider exposes.
- **The body** runs when someone first asks for the value. It gets a `Ref`, which in Riverpod 3 has no type parameter.
- **`ref.watch`** inside the body makes this provider rebuild when `visitorNameProvider` changes.

## State you can change

When the value needs methods, the body becomes a class. `NotifierProvider` takes two type arguments and a constructor tear-off:

<?code-excerpt "provider-anatomy/anatomy.dart" region="notifier"?>
```dart
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
```

`build` plays the role of the function body above. The notifier has `ref` and `state` as members, so methods can read other providers and update the value.

## Modifiers

`family` adds an argument and `autoDispose` frees the state when nothing listens. Riverpod 3 also accepts `isAutoDispose: true`, which reads better once there are several type arguments:

<?code-excerpt "provider-anatomy/anatomy.dart" region="modifiers"?>
```dart
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
```

`forecastProvider('Oslo')` returns a provider. Two calls with equal arguments return equal providers, so they share one state.

## Using it

A `ConsumerWidget` adds a `WidgetRef` to `build`. Watch the provider and use the value:

<?code-excerpt "provider-anatomy/anatomy.dart" region="widget"?>
```dart
class Greeting extends ConsumerWidget {
  const Greeting({super.key});

  @override
  // @note ConsumerWidget hands you a WidgetRef
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    return Text(greeting);
  }
}
```

## Good to know

- Providers are global, but their state isn't. Each `ProviderScope` (and each `ProviderContainer.test()` in a test) holds its own copy. That makes overrides and tests simple.
- The type arguments are optional when Dart can infer them. Writing them out keeps the declaration readable and catches mistakes early.
- Wrap your app in `ProviderScope` once, at the top. Without it, `ref.watch` has nowhere to store state and throws.

<!-- tips:nav -->

---

**#006** · State management · [All tips](../../../CATALOG.md)

← Previous: [#005 A Result type with a sealed class](../sealed-class-result/index.md)  
→ Next: [#007 Use MediaQuery.sizeOf instead of MediaQuery.of](../mediaquery-sizeof/index.md)
<!-- /tips:nav -->
