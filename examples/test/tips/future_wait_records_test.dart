import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/future-wait-records/wallet.dart';

void main() {
  test('both styles give the same answer', () async {
    final wallet = Wallet();
    expect(await summary(wallet), 'Ada: 12 transactions');
    expect(await summaryWithList(wallet), await summary(wallet));
  });

  test('the futures run concurrently', () {
    fakeAsync((async) {
      String? result;
      unawaited(summary(Wallet()).then((r) => result = r));
      // Each call takes 20 ms. In sequence they would need 40.
      async.elapse(const Duration(milliseconds: 20));
      expect(result, isNotNull);
    });
  });

  test('Future.wait throws a plain error, values lost', () {
    expect(
      summaryWithList(Wallet(failOwner: true)),
      throwsA(isA<Exception>()),
    );
  });

  test('.wait throws ParallelWaitError with typed parts', () async {
    final wallet = Wallet(failOwner: true);
    try {
      await (wallet.transactionCount(), wallet.owner()).wait;
      fail('expected a ParallelWaitError');
    } on ParallelWaitError<
      (int?, String?),
      (AsyncError?, AsyncError?)
    > catch (e) {
      expect(e.values, (12, null));
      expect(e.errors.$1, isNull);
      expect(e.errors.$2!.error, isA<Exception>());
    }
  });

  test('the successful value survives a failure', () async {
    expect(
      await summaryOrPartial(Wallet(failOwner: true)),
      'partial: count 12, owner null',
    );
    expect(await summaryOrPartial(Wallet()), 'Ada: 12 transactions');
  });
}
