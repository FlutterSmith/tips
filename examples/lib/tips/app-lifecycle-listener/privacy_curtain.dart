import 'package:flutter/material.dart';

/// Covers [child] while the app is not in the foreground, so the
/// app switcher doesn't show sensitive data.
class PrivacyCurtain extends StatefulWidget {
  const PrivacyCurtain({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyCurtain> createState() => _PrivacyCurtainState();
}

class _PrivacyCurtainState extends State<PrivacyCurtain> {
  // #docregion listener
  late final AppLifecycleListener _listener;
  var _covered = false;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      // @note resumed -> inactive: we're leaving the foreground
      onInactive: () => setState(() => _covered = true),
      onResume: () => setState(() => _covered = false),
    );
  }

  @override
  void dispose() {
    // @note it registers an observer, so dispose it
    _listener.dispose();
    super.dispose();
  }
  // #enddocregion listener

  @override
  Widget build(BuildContext context) {
    // #docregion build
    return Stack(
      fit: StackFit.expand,
      children: [
        // @note the child keeps its state underneath
        widget.child,
        if (_covered) const ColoredBox(color: Colors.black),
      ],
    );
    // #enddocregion build
  }
}

/// Wraps every route in the curtain.
class PrivateApp extends StatelessWidget {
  const PrivateApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    // #docregion app
    return MaterialApp(
      builder: (context, child) => PrivacyCurtain(child: child!),
      home: home,
    );
    // #enddocregion app
  }
}

/// Logs every state change, whichever the transition.
class LifecycleLog extends StatefulWidget {
  const LifecycleLog({super.key, required this.onChange});

  final ValueChanged<AppLifecycleState> onChange;

  @override
  State<LifecycleLog> createState() => _LifecycleLogState();
}

class _LifecycleLogState extends State<LifecycleLog> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // #docregion state-change
    _listener = AppLifecycleListener(onStateChange: widget.onChange);
    // #enddocregion state-change
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
