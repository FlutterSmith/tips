import 'package:flutter/material.dart';

/// Shows how far an upload has got, from 0.0 to 1.0.
class UploadProgress extends StatelessWidget {
  const UploadProgress({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    // #docregion determinate
    return Column(
      spacing: 16,
      children: [
        CircularProgressIndicator(
          // @note 0.0 to 1.0; null means "spin forever"
          value: progress,
          strokeWidth: 8,
          backgroundColor: Colors.grey.shade300,
        ),
        LinearProgressIndicator(value: progress, minHeight: 6),
        Text('${(progress * 100).round()}%'),
      ],
    );
    // #enddocregion determinate
  }
}

/// A ring that empties over [duration].
class CountdownRing extends StatefulWidget {
  const CountdownRing({super.key, required this.duration});

  final Duration duration;

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing>
    with SingleTickerProviderStateMixin {
  // #docregion countdown
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    // @note start full, then run down to 0.0
    value: 1,
  )..reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CircularProgressIndicator(
        value: _controller.value,
        strokeWidth: 12,
      ),
    );
  }
  // #enddocregion countdown
}
