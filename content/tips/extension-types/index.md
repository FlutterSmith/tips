---
slug: extension-types
title: Extension types vs extension methods
summary: An extension method adds to a type. An extension type wraps it in a new static type, so a UserId can't be passed where an OrderId belongs.
category: dart
tags: [extension-types, dart3, types]
level: intermediate
published: 2026-09-14
status: current
origin:
  upstream_id: 146
  upstream_path: tips/0146-extension-types-dart3.3/index.md
  change: kept
related: [records-multiple-returns, sealed-class-result]
---

User IDs and order IDs are both `String`s, so nothing stops you from passing one where the other belongs. An extension method won't help with that. It adds members to `String` but leaves the type as it is:

<?code-excerpt "extension-types/user_id.dart" region="extension"?>
```dart
// @note adds a method; every String method stays
extension ShoutX on String {
  String shout() => '${toUpperCase()}!';
}
```

An extension type creates a new type on top of an existing one. You pick which members it has:

<?code-excerpt "extension-types/user_id.dart" region="type"?>
```dart
// @note a new static type over String, gone at runtime
extension type const UserId(String value) {
  bool get isGuest => value.startsWith('guest-');
}

extension type const OrderId(String value) {}
```

Functions can now ask for exactly the kind of ID they need:

<?code-excerpt "extension-types/user_id.dart" region="usage"?>
```dart
String greet(UserId id) =>
    id.isGuest ? 'Welcome, guest' : 'Welcome back, ${id.value}';
```

<?code-excerpt "extension-types/user_id.dart" region="call"?>
```dart
const id = UserId('ada');
// @note an OrderId or a plain String won't compile here
return greet(id);
```

## What the compiler stops

Mixing up the two IDs is now a compile error. So is calling `String` methods the extension type didn't expose:

<?code-excerpt "broken/extension-types/mix_up.dart" region="mix-up"?>
```dart
const order = OrderId('o-42');
// @note error: an OrderId is not a UserId
greet(order);
// @note error: String methods are hidden
UserId('ada').toUpperCase();
```

If you do want the whole `String` API, declare `implements String` on the extension type, or reach for `.value`.

## Zero cost

A class wrapper allocates an object for every ID. An extension type doesn't. It only exists for the type checker, and at runtime the value is the plain `String`:

<?code-excerpt "extension-types/user_id.dart" region="erased"?>
```dart
const id = UserId('ada');
final Object? raw = id;
// @note the wrapper is erased: at runtime it is a String
return raw is String;
```

## Watch out

That erasure is also the catch. `is` checks and casts see the representation type, so `raw is String` is true and `someString as UserId` always succeeds. An extension type protects you at compile time only. If you need a runtime check, validate in a factory constructor, or use a real class.

<!-- tips:nav -->

---

**#019** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#018 AsyncValue.guard instead of try/catch in notifiers](../async-value-guard/index.md)  
→ Next: [#020 React to the app going to the background with AppLifecycleListener](../app-lifecycle-listener/index.md)
<!-- /tips:nav -->
