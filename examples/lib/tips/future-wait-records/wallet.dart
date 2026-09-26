import 'dart:async';

class Wallet {
  Wallet({this.failTransactions = false, this.failOwner = false});

  final bool failTransactions;
  final bool failOwner;

  Future<int> transactionCount() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (failTransactions) throw Exception('transactions down');
    return 12;
  }

  Future<String> owner() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (failOwner) throw Exception('owner down');
    return 'Ada';
  }
}

Future<String> summaryWithList(Wallet wallet) async {
  // #docregion list
  final results = await Future.wait([
    wallet.transactionCount(),
    wallet.owner(),
  ]);
  // @note List<Object>: the types are gone, so you cast
  final count = results[0] as int;
  final owner = results[1] as String;
  // #enddocregion list
  return '$owner: $count transactions';
}

Future<String> summary(Wallet wallet) async {
  // #docregion record
  // @note (int, String): each value keeps its type
  final (count, owner) = await (
    wallet.transactionCount(),
    wallet.owner(),
  ).wait;
  // #enddocregion record
  return '$owner: $count transactions';
}

Future<String> summaryOrPartial(Wallet wallet) async {
  // #docregion errors
  try {
    final (count, owner) = await (
      wallet.transactionCount(),
      wallet.owner(),
    ).wait;
    return '$owner: $count transactions';
    // @note one error type, typed like the record
  } on ParallelWaitError<
    (int?, String?),
    (AsyncError?, AsyncError?)
  > catch (e) {
    // @note values that did arrive are still here
    final (count, owner) = e.values;
    return 'partial: count $count, owner $owner';
  }
  // #enddocregion errors
}
