import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/null-aware-elements/query.dart';

void main() {
  test('...? spreads nothing for a null list', () {
    expect(nextPage(null, ['c']), ['c']);
    expect(nextPage(['a', 'b'], ['c']), ['a', 'b', 'c']);
  });

  test('?value leaves the entry out when null', () {
    expect(queryParams(q: 'dart'), {'q': 'dart'});
    expect(queryParams(q: 'dart').containsKey('sort'), isFalse);
    expect(queryParams(q: 'dart', sort: 'new', page: 2), {
      'q': 'dart',
      'sort': 'new',
      'page': '2',
    });
  });

  test('?element works in lists too', () {
    expect(tags(null, 'b'), ['b', 'all']);
    expect(tags('a', null), ['a', 'all']);
  });

  test('matches the collection-if version', () {
    for (final sort in [null, 'new']) {
      for (final page in [null, 3]) {
        expect(
          queryParams(q: 'x', sort: sort, page: page),
          queryParamsWithIfs(q: 'x', sort: sort, page: page),
        );
      }
    }
  });
}
