---
slug: which-provider
title: Which Riverpod 3 provider should you use?
summary: Six providers cover almost every job in Riverpod 3. StateProvider, StateNotifierProvider and ChangeNotifierProvider now live in legacy.dart.
category: state
tags: [riverpod, providers, migration]
level: beginner
published: 2026-09-09
status: current
packages: { flutter_riverpod: "^3.0.0" }
origin:
  upstream_id: 64
  upstream_path: tips/0064-all-riverpod-providers/index.md
  change: rewritten
related: [provider-anatomy, notifier-replaces-state-notifier, future-provider-future]
---

Riverpod has a provider for each kind of value, and the choice comes down to two questions. Is the value sync, a `Future` or a `Stream`? And does outside code need to change it?

| | Read only | Has methods that change it |
|---|---|---|
| Sync | `Provider` | `NotifierProvider` |
| `Future` | `FutureProvider` | `AsyncNotifierProvider` |
| `Stream` | `StreamProvider` | `StreamNotifierProvider` |

The left column takes a function. Its value only changes when something it watches changes:

<?code-excerpt "which-provider/providers.dart" region="functional"?>
```dart
// A value or a service that doesn't change on its own.
final clockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

// Load once, then show loading, error or data.
final latestReleaseProvider = FutureProvider<Release>(
  (ref) => fetchLatestRelease(),
);

// Values that keep arriving: sockets, auth state, a database.
final onlineUsersProvider = StreamProvider<int>(
  (ref) => onlineUsers(),
);
```

The right column takes a class with a `build` method for the initial value and your own methods to update `state`:

<?code-excerpt "which-provider/providers.dart" region="notifiers"?>
```dart
// Synchronous state plus the methods that change it.
final stepCounterProvider = NotifierProvider<StepCounter, int>(
  StepCounter.new,
);

class StepCounter extends Notifier<int> {
  @override
  int build() => 0;

  void step() => state++;
}

// Async state you load, then change: a cart, a profile form.
final watchlistProvider =
    AsyncNotifierProvider<Watchlist, List<String>>(Watchlist.new);

class Watchlist extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async => ['Dune'];

  Future<void> add(String title) async {
    // @note waits for build if it is still loading
    final current = await future;
    state = AsyncData([...current, title]);
  }
}

// A stream you also act on: a chat room you can post to.
final chatProvider = StreamNotifierProvider<ChatRoom, String>(
  ChatRoom.new,
);

class ChatRoom extends StreamNotifier<String> {
  @override
  Stream<String> build() => Stream.value('Welcome');

  void post(String message) => state = AsyncData(message);
}
```

The async ones (`FutureProvider`, `StreamProvider` and the async notifiers) expose an `AsyncValue`, so the UI handles loading and errors in one place.

## What about StateProvider?

`StateProvider`, `StateNotifierProvider` and `ChangeNotifierProvider` still exist, but Riverpod 3 moved them out of the main library. Riverpod 2 code that used them stops compiling:

<?code-excerpt "broken/which-provider/state_provider.dart" region="old-import"?>
```dart dont="Riverpod 3: StateProvider isn't defined here any more."
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentPageProvider = StateProvider<int>((ref) => 1);
```

<?code-excerpt "which-provider/legacy.dart" region="legacy"?>
```dart do="Same code, one import changed. Fine while you migrate."
// @note StateProvider & co. moved here in Riverpod 3
import 'package:flutter_riverpod/legacy.dart';

final currentPageProvider = StateProvider<int>((ref) => 1);
```

Changing the import gets old code compiling again. For new code, a `Notifier` with one method does what `StateProvider` did, and it gives the logic a name you can find and test.

## Good to know

- Start with the left column. Move to a notifier when the UI needs to trigger a change, not before.
- Don't reach for a notifier just to refetch data. `ref.invalidate(latestReleaseProvider)` reloads a `FutureProvider`.
- `Provider` is also the right home for services: a repository, an API client, a clock. Tests replace them with `overrideWithValue`.

<!-- tips:nav -->

---

**#012** · State management · [All tips](../../../CATALOG.md)

← Previous: [#011 Return SizedBox.shrink() when there is nothing to show](../sizedbox-shrink/index.md)  
→ Next: [#013 Destructure lists with list patterns](../destructure-lists/index.md)
<!-- /tips:nav -->
