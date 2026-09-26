import 'package:flutter/material.dart';

/// Three buttons, all as wide as the widest label.
class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion intrinsic
    // @note sizes the column to its widest child
    return IntrinsicWidth(
      child: Column(
        spacing: 8,
        // @note then every button stretches to that width
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Play')),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Settings'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Leaderboards'),
          ),
        ],
      ),
    );
    // #enddocregion intrinsic
  }
}

/// The same menu with a hard-coded width.
class FixedWidthGameMenu extends StatelessWidget {
  const FixedWidthGameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion fixed
    return SizedBox(
      // @note a guess that breaks with larger text
      width: 160,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Play')),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Settings'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Leaderboards'),
          ),
        ],
      ),
    );
    // #enddocregion fixed
  }
}
