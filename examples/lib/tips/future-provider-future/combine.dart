import 'package:flutter_riverpod/flutter_riverpod.dart';

final firstProvider = FutureProvider<int>((ref) async => 1);
final secondProvider = FutureProvider<int>((ref) async => 2);

// #docregion sequential
final totalProvider = FutureProvider<int>((ref) async {
  // @note .future is the Future behind the provider
  final a = await ref.watch(firstProvider.future);
  final b = await ref.watch(secondProvider.future);
  // @note plain async code from here on
  return a + b;
});
// #enddocregion sequential

// #docregion parallel
final fastTotalProvider = FutureProvider<int>((ref) async {
  // @note both start now, so they run in parallel
  final (a, b) = await (
    ref.watch(firstProvider.future),
    ref.watch(secondProvider.future),
  ).wait;
  return a + b;
});
// #enddocregion parallel
