---
slug: app-lifecycle-listener
title: React to the app going to the background with AppLifecycleListener
summary: AppLifecycleListener gives you one named callback per lifecycle transition. No observer mixin needed, but you must dispose it.
category: widgets
tags: [lifecycle]
level: intermediate
published: 2026-09-15
status: current
origin:
  upstream_id: 34
  upstream_path: tips/0034-how-to-use-widgetsbindingobserver/index.md
  change: rewritten
related: [context-mounted-async-gaps]
---

A banking app shouldn't show your balance in the app switcher. To hide it, you need to know when the app leaves the foreground. `AppLifecycleListener` tells you, with a callback per transition:

<?code-excerpt "app-lifecycle-listener/privacy_curtain.dart" region="listener"?>
```dart
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
```

Creating the listener registers it with `WidgetsBinding`. There's no mixin and no `addObserver` call, but the flip side is that `dispose()` is on you. Forget it, and the next lifecycle change calls `setState` on a dead `State` and throws.

The build method covers the child rather than replacing it, so a half-filled form survives the trip to the background:

<?code-excerpt "app-lifecycle-listener/privacy_curtain.dart" region="build"?>
```dart
return Stack(
  fit: StackFit.expand,
  children: [
    // @note the child keeps its state underneath
    widget.child,
    if (_covered) const ColoredBox(color: Colors.black),
  ],
);
```

Put it in `MaterialApp.builder` and it covers every route:

<?code-excerpt "app-lifecycle-listener/privacy_curtain.dart" region="app"?>
```dart
return MaterialApp(
  builder: (context, child) => PrivacyCurtain(child: child!),
  home: home,
);
```

## Transitions, not states

The callbacks fire on moves between states, and the state only moves one step at a time along resumed, inactive, hidden and paused. That's why the names come in pairs:

- `onInactive` / `onResume`: losing and regaining focus
- `onHide` / `onShow`: leaving and coming back into view
- `onPause` / `onRestart`: stopping and starting again

If you want the state itself, use `onStateChange`:

<?code-excerpt "app-lifecycle-listener/privacy_curtain.dart" region="state-change"?>
```dart
_listener = AppLifecycleListener(onStateChange: widget.onChange);
```

## Good to know

- `onExitRequested` lets you ask "save changes?" before the app quits, when the platform allows the exit to be cancelled. Return `AppExitResponse.cancel` to stay open.
- `WidgetsBindingObserver` still works, and it's what `AppLifecycleListener` uses internally. Reach for the observer when you also need metrics or locale changes.
- In tests, drive it with `tester.binding.handleAppLifecycleStateChanged(...)`. Move one step at a time, or the listener's asserts fail.

<!-- tips:nav -->

---

**#020** · Widgets & layout · [All tips](../../../CATALOG.md)

← Previous: [#019 Extension types vs extension methods](../extension-types/index.md)  
→ Next: [#021 Skip nulls in collection literals with ...? and ?value](../null-aware-elements/index.md)
<!-- /tips:nav -->
