import 'dart:developer';

// #docregion helper
/// Runs [action] and returns its result together with how long it took.
Future<(T, Duration)> measure<T>(Future<T> Function() action) async {
  // @note monotonic: it never jumps backwards
  final stopwatch = Stopwatch()..start();
  final result = await action();
  // @note a record: the value and the time
  return (result, stopwatch.elapsed);
}
// #enddocregion helper

// #docregion usage
Future<String> loadProfile(Future<String> Function() fetch) async {
  final (profile, took) = await measure(fetch);
  log('Profile loaded in ${took.inMilliseconds} ms');
  return profile;
}
// #enddocregion usage

Future<Duration> wallClock(Future<void> Function() work) async {
  // #docregion avoid
  final start = DateTime.now();
  await work();
  final took = DateTime.now().difference(start);
  // #enddocregion avoid
  return took;
}

Future<Duration> monotonic(Future<void> Function() work) async {
  // #docregion prefer
  final stopwatch = Stopwatch()..start();
  await work();
  final took = stopwatch.elapsed;
  // #enddocregion prefer
  return took;
}
