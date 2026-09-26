import 'package:flutter/material.dart';

/// Shows "-20%", or nothing when there is no discount.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    // #docregion shrink
    if (percent == 0) {
      // @note const, zero by zero
      return const SizedBox.shrink();
    }
    return Text('-$percent%');
    // #enddocregion shrink
  }
}

/// The same badge, returning an empty Container for "nothing".
class ContainerDiscountBadge extends StatelessWidget {
  const ContainerDiscountBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    // #docregion container
    if (percent == 0) {
      // @note no child: it grows to fill its parent
      return Container();
    }
    return Text('-$percent%');
    // #enddocregion container
  }
}

/// A product row that skips the badge entirely.
class PriceRow extends StatelessWidget {
  const PriceRow({super.key, required this.price, this.percent = 0});

  final String price;
  final int percent;

  @override
  Widget build(BuildContext context) {
    // #docregion collection-if
    return Row(
      spacing: 8,
      children: [
        Text(price),
        // @note no widget at all when there's no discount
        if (percent > 0) DiscountBadge(percent: percent),
      ],
    );
    // #enddocregion collection-if
  }
}
