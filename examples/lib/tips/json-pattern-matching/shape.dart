// #docregion classes
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
// #enddocregion classes

Shape oldFromJson(Map<String, Object?> json) {
  // #docregion if-else
  final type = json['type'] as String;
  if (type == 'square') {
    return Square(json['side'] as double);
  } else if (type == 'circle') {
    return Circle(json['radius'] as double);
  }
  throw FormatException('Unknown shape: $json');
  // #enddocregion if-else
}

String? avatarUrl(Map<String, Object?> json) {
  // #docregion if-case
  // @note nested maps match too; extra keys are ignored
  if (json case {'user': {'avatar': final String url}}) {
    return url;
  }
  return null;
  // #enddocregion if-case
}
