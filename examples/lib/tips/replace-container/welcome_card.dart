import 'package:flutter/material.dart';

/// A fixed-size teal card, built with Container.
class ContainerWelcomeCard extends StatelessWidget {
  const ContainerWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion container
    // @note not const: Container has no const constructor
    return Container(
      width: 240,
      height: 120,
      color: Colors.teal,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Text('Welcome'),
    );
    // #enddocregion container
  }
}

/// The same card, built from single-purpose widgets.
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion nested
    // @note the whole subtree is const now
    return const SizedBox(
      width: 240,
      height: 120,
      child: ColoredBox(
        color: Colors.teal,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Welcome')),
        ),
      ),
    );
    // #enddocregion nested
  }
}

/// Rounded corners need a decoration, not just a color.
class RoundedWelcomeCard extends StatelessWidget {
  const RoundedWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // #docregion decorated
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.teal,
        // @note DecoratedBox for borders, radius, gradients
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Welcome'),
      ),
    );
    // #enddocregion decorated
  }
}
