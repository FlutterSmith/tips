import 'package:flutter_riverpod/flutter_riverpod.dart';

class Release {
  const Release(this.version);

  final String version;
}

Future<Release> fetchLatestRelease() async => const Release('3.4.3');

Stream<int> onlineUsers() => Stream.fromIterable([3, 5, 8]);

// #docregion functional
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
// #enddocregion functional

// #docregion notifiers
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
// #enddocregion notifiers
