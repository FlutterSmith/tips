import 'package:flutter/material.dart';

/// One button, styled on the spot.
class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // #docregion style-from
    return ElevatedButton(
      // @note plain values in, a full ButtonStyle out
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        disabledBackgroundColor: Colors.grey.shade300,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32),
      ),
      onPressed: onPressed,
      child: const Text('Checkout'),
    );
    // #enddocregion style-from
  }
}

/// Every ElevatedButton in the app gets the same style.
class ShopApp extends StatelessWidget {
  const ShopApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    // #docregion theme
    return MaterialApp(
      theme: ThemeData(
        // @note applies to buttons without their own style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.amber,
          ),
        ),
      ),
      home: home,
    );
    // #enddocregion theme
  }
}

/// A style that changes with the button's state.
// #docregion states
final pressableStyle = ButtonStyle(
  // @note called with the current states on every change
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return Colors.grey;
    if (states.contains(WidgetState.pressed)) return Colors.indigo;
    return Colors.indigo.shade300;
  }),
  foregroundColor: const WidgetStatePropertyAll(Colors.white),
);
// #enddocregion states
