// Kept on purpose to show the older style.
// ignore_for_file: use_null_aware_elements

// #docregion spread
List<String> nextPage(List<String>? loaded, List<String> page) {
  // @note ...? adds nothing when loaded is null
  return [...?loaded, ...page];
}
// #enddocregion spread

// #docregion element
Map<String, String> queryParams({
  required String q,
  String? sort,
  int? page,
}) {
  return {
    'q': q,
    // @note ?value: the entry is skipped when sort is null
    'sort': ?sort,
    'page': ?page?.toString(),
  };
}
// #enddocregion element

// #docregion list
List<String> tags(String? primary, String? secondary) => [
  // @note same for list and set elements
  ?primary,
  ?secondary,
  'all',
];
// #enddocregion list

Map<String, String> queryParamsWithIfs({
  required String q,
  String? sort,
  int? page,
}) {
  // #docregion collection-if
  return {
    'q': q,
    if (sort != null) 'sort': sort,
    if (page != null) 'page': page.toString(),
  };
  // #enddocregion collection-if
}
