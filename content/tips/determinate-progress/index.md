---
slug: determinate-progress
title: Show real progress with a value on progress indicators
summary: Give CircularProgressIndicator or LinearProgressIndicator a value from 0.0 to 1.0 and they show how far along you are instead of spinning.
category: widgets
tags: [progress, accessibility]
level: beginner
published: 2026-09-20
status: current
origin:
  upstream_id: 148
  upstream_path: tips/0148-determinate-circular-progress-indicator/index.md
  change: kept
related: [sizedbox-shrink]
---

A spinner says "something is happening". When you know how far along an upload is, say that instead. Pass a `value` between 0.0 and 1.0:

<?code-excerpt "determinate-progress/upload_progress.dart" region="determinate"?>
```dart
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
```

With a `value`, an indicator is determinate: it draws that fraction of the circle or bar and doesn't animate on its own. Leave `value` null and it's indeterminate, spinning or sliding until you remove it. The test for this tip checks both: the determinate version has no running animations, and the indeterminate one is still going after ten seconds.

Values outside the range are clamped, so 1.2 draws a full ring rather than throwing.

## A countdown ring

Because the indicator just draws whatever `value` it gets, driving it from an `AnimationController` gives you a countdown timer:

<?code-excerpt "determinate-progress/upload_progress.dart" region="countdown"?>
```dart
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
```

`reverse()` runs the controller from 1.0 down to 0.0 over the duration, and `AnimatedBuilder` repaints the ring on each tick. Dispose the controller with the widget.

## Good to know

- Colors: `color` sets the progress part and `backgroundColor` the track behind it. `valueColor` takes an `Animation<Color?>` if the color itself should change.
- `strokeWidth` sets the ring's thickness, `minHeight` the bar's.
- The constructors still take a `year2023` flag. It's deprecated and defaults to true, which keeps the older Material 3 look. Setting it to false opts into the newer design with a gap between the progress and the track.
- Screen readers get the value as a number from 0 to 100. Pass `semanticsLabel` so they also hear what is progressing.

<!-- tips:nav -->

---

**#026** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#025 Initialise async dependencies in main() and use requireValue](../require-value-async-init/index.md)  
→ Next: [#027 Migrate a StateNotifier to a Notifier](../notifier-replaces-state-notifier/index.md)
<!-- /tips:nav -->
