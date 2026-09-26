import 'package:flutter/widgets.dart';

class Toppings extends StatelessWidget {
  const Toppings({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion spacing
    return const Column(
      // @note one value instead of a SizedBox per gap
      spacing: 12,
      children: [
        Text('Mushrooms'),
        Text('Olives'),
        // @note no extra space after the last child
        Text('Basil'),
      ],
    );
    // #enddocregion spacing
  }
}

class ToppingsWithSizedBoxes extends StatelessWidget {
  const ToppingsWithSizedBoxes({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion sized-boxes
    return const Column(
      children: [
        Text('Mushrooms'),
        SizedBox(height: 12),
        Text('Olives'),
        SizedBox(height: 12),
        Text('Basil'),
      ],
    );
    // #enddocregion sized-boxes
  }
}

class DialogActions extends StatelessWidget {
  const DialogActions({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion row
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(onTap: () {}, child: const Text('Cancel')),
        GestureDetector(onTap: () {}, child: const Text('Save')),
      ],
    );
    // #enddocregion row
  }
}
