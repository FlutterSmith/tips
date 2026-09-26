// Riverpod 2 code: StateProvider is no longer exported from the
// main library, so this doesn't compile against Riverpod 3.
// expect: undefined_function
// #docregion old-import
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentPageProvider = StateProvider<int>((ref) => 1);
// #enddocregion old-import
