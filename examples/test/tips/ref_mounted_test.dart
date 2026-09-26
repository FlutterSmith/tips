import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/ref-mounted/search.dart';

class _ControlledApi extends SearchApi {
  final pending = Completer<List<String>>();
  final queries = <String>[];

  @override
  Future<List<String>> find(String query) {
    queries.add(query);
    return pending.future;
  }
}

class _CountingApi extends SearchApi {
  final queries = <String>[];

  @override
  Future<List<String>> find(String query) async {
    queries.add(query);
    return [query];
  }
}

ProviderContainer _container(SearchApi api) => ProviderContainer.test(
  overrides: [searchApiProvider.overrideWithValue(api)],
);

void main() {
  test('checked: disposal during the await is harmless', () async {
    final api = _ControlledApi();
    final container = _container(api);
    final sub = container.listen(searchResultsProvider, (_, _) {});
    final searching = container
        .read(searchResultsProvider.notifier)
        .search('lamp');

    sub.close();
    await container.pump();
    api.pending.complete(['lamp 1']);
    await expectLater(searching, completes);
  });

  test('unchecked: the late write throws', () async {
    final api = _ControlledApi();
    final container = _container(api);
    final sub = container.listen(searchResultsProvider, (_, _) {});
    final searching = container
        .read(searchResultsProvider.notifier)
        .searchUnchecked('lamp');

    sub.close();
    await container.pump();
    api.pending.complete(['lamp 1']);
    await expectLater(
      searching,
      throwsA(
        predicate((e) => '$e'.contains('after it has been disposed')),
      ),
    );
  });

  test('a Notifier rebuild does not unmount its ref', () async {
    final api = _ControlledApi();
    final container = _container(api);
    container.listen(searchResultsProvider, (_, _) {});
    final notifier = container.read(searchResultsProvider.notifier);
    final searching = notifier.search('lamp');

    container.invalidate(searchResultsProvider);
    expect(container.read(searchResultsProvider), isEmpty);
    expect(
      container.read(searchResultsProvider.notifier),
      same(notifier),
    );

    api.pending.complete(['lamp 1']);
    await searching;
    expect(container.read(searchResultsProvider), ['lamp 1']);
  });

  test('debounce: only the last query reaches the API', () {
    fakeAsync((async) {
      final api = _CountingApi();
      final container = _container(api);
      final values = <List<String>>[];
      container.listen(suggestionsProvider, (_, next) {
        if (next case AsyncData(:final value)) values.add(value);
      });
      final query = container.read(searchQueryProvider.notifier);

      for (final text in ['l', 'la', 'lam', 'lamp']) {
        query.set(text);
        async.elapse(const Duration(milliseconds: 100));
      }
      async.elapse(const Duration(milliseconds: 300));

      expect(api.queries, ['lamp']);
      expect(values, [
        ['lamp'],
      ]);
    });
  });
}
