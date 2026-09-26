import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:tips_cli/tips_cli.dart';

import 'helpers.dart';

void main() {
  test('parses machine output', () {
    final d = parseMachineOutput(
      'ERROR|COMPILE_TYPE_ERROR|INVALID_ASSIGNMENT|/x/a.dart|3|5|2|msg\n'
      'garbage\n',
    );
    expect(d.single.code, 'invalid_assignment');
    expect(d.single.line, 3);
  });

  test('reads expect comments', () {
    expect(
      expectedCodes('// expect: invalid_assignment, Undefined_Method\nx'),
      {'invalid_assignment', 'undefined_method'},
    );
  });

  test('compares expected and actual diagnostics', () {
    final repo = fixtureRepo({});
    final a = p.join(repo.root, 'examples/broken/a.dart');
    final b = p.join(repo.root, 'examples/broken/b.dart');
    final c = p.join(repo.root, 'examples/broken/c.dart');
    final issues = compareDiagnostics(
      repo,
      {
        a: {'invalid_assignment'},
        b: {'undefined_method'},
        c: {},
      },
      [
        Diagnostic('invalid_assignment', a, 1),
        Diagnostic('unused_local_variable', b, 1),
      ],
    );
    expect(issues.map((i) => '${i.path}: ${i.message}'), [
      startsWith('examples/broken/b.dart: Expected "undefined_method"'),
      startsWith('examples/broken/b.dart: Unexpected diagnostic'),
      startsWith('examples/broken/c.dart: Declare'),
    ]);
  });
}
