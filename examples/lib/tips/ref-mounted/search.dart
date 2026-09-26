import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchApi {
  Future<List<String>> find(String query) async => [
    '$query 1',
    '$query 2',
  ];
}

final searchApiProvider = Provider<SearchApi>((ref) => SearchApi());

final searchResultsProvider =
    NotifierProvider.autoDispose<SearchResults, List<String>>(
      SearchResults.new,
    );

class SearchResults extends Notifier<List<String>> {
  @override
  List<String> build() => const [];

  // #docregion checked
  Future<void> search(String query) async {
    final results = await ref.read(searchApiProvider).find(query);
    // @note false once the provider is disposed
    if (!ref.mounted) return;
    state = results;
  }
  // #enddocregion checked

  // #docregion unchecked
  Future<void> searchUnchecked(String query) async {
    final results = await ref.read(searchApiProvider).find(query);
    state = results;
  }
  // #enddocregion unchecked
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(
  SearchQuery.new,
);

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

// #docregion debounce
final suggestionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final api = ref.watch(searchApiProvider);
  final query = ref.watch(searchQueryProvider);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  // @note this ref belongs to one build; a new query ends it
  if (!ref.mounted) return const [];
  return api.find(query);
});
// #enddocregion debounce
