---
slug: json-pattern-matching
title: Parse JSON safely with map patterns
summary: A switch on a map pattern checks keys and value types in one go, so bad JSON reaches your fallback case instead of a TypeError.
category: dart
tags: [json, patterns, sealed-classes]
level: intermediate
published: 2026-09-22
status: current
origin:
  upstream_id: 113
  upstream_path: tips/0113-conditional-json-parsing/index.md
  change: kept
related: [sealed-class-result, switch-on-records, null-aware-elements]
---

JSON often changes shape based on one field: a square has a `side`, a circle has a `radius`. The usual parser reads `type` and then casts:

<?code-excerpt "json-pattern-matching/shape.dart" region="if-else"?>
```dart dont="Every as is a TypeError waiting for bad input."
final type = json['type'] as String;
if (type == 'square') {
  return Square(json['side'] as double);
} else if (type == 'circle') {
  return Circle(json['radius'] as double);
}
throw FormatException('Unknown shape: $json');
```

A `switch` on map patterns checks the type, the keys and the value types together, and binds the values you need:

<?code-excerpt "json-pattern-matching/shape.dart" region="classes"?>
```dart do="Match and bind. Bad input goes to the last case."
sealed class Shape {
  const Shape();

  factory Shape.fromJson(Map<String, Object?> json) {
    return switch (json) {
      // @note matches the type, checks and binds side
      {'type': 'square', 'side': final double side} => Square(side),
      {'type': 'circle', 'radius': final double radius} => Circle(
        radius,
      ),
      // @note wrong type, missing key, not a double: all end here
      _ => throw FormatException('Unknown shape: $json'),
    };
  }
}

final class Square extends Shape {
  const Square(this.side);
  final double side;
}

final class Circle extends Shape {
  const Circle(this.radius);
  final double radius;
}
```

## What a map pattern checks

- `'type': 'square'` matches only if the key exists and the value equals `'square'`.
- `'side': final double side` matches only if `side` is there and is a `double`, and then binds it.
- Keys you don't mention are ignored. Extra fields in the payload won't break parsing.

Anything that doesn't fit falls to `_`, where you throw one clear `FormatException`. The cast version throws a `TypeError` instead, which says little about what was wrong with the JSON.

## One value, deep inside

When you only need one nested field, `if-case` does the same checks without a full switch:

<?code-excerpt "json-pattern-matching/shape.dart" region="if-case"?>
```dart
// @note nested maps match too; extra keys are ignored
if (json case {'user': {'avatar': final String url}}) {
  return url;
}
return null;
```

## Watch out

- `jsonDecode` returns `1` for `1` and `1.0` for `1.0` on the VM. A pattern that asks for a `double` won't match an `int`. Use `num` and call `toDouble()` if the server isn't strict.
- The switch doesn't check that you handled every `type`. It only guarantees that anything unhandled reaches `_`. Making `Shape` sealed covers the other direction: every switch over a `Shape` must handle both subclasses.

<!-- tips:nav -->

---

**#028** · Dart language · [All tips](../../../CATALOG.md)

← Previous: [#027 Migrate a StateNotifier to a Notifier](../notifier-replaces-state-notifier/index.md)  
→ Next: [#029 Style an ElevatedButton with styleFrom and themes](../elevated-button-style/index.md)
<!-- /tips:nav -->
