import 'dart:io';

import 'package:path/path.dart' as p;

import 'issue.dart';
import 'repo.dart';

final _expect = RegExp(r'//[ \t]*expect:[ \t]*([\w ,]+)$', multiLine: true);

/// One diagnostic from `dart analyze --format=machine`.
class Diagnostic {
  const Diagnostic(this.code, this.path, this.line);

  final String code;
  final String path;
  final int line;
}

/// Parses machine-format analyzer output.
///
/// Each line is `SEVERITY|TYPE|CODE|FILE|LINE|COLUMN|LENGTH|MESSAGE`.
List<Diagnostic> parseMachineOutput(String output) => [
  for (final line in output.split('\n'))
    if (line.split('|') case [_, _, final code, final file, final l, ...])
      Diagnostic(code.toLowerCase(), p.normalize(file), int.tryParse(l) ?? 1),
];

/// Expected diagnostic codes declared with `// expect: a, b` in [source].
Set<String> expectedCodes(String source) => {
  for (final m in _expect.allMatches(source))
    for (final code in m.group(1)!.split(','))
      if (code.trim().isNotEmpty) code.trim().toLowerCase(),
};

/// Compares expected codes per file with the analyzer's [diagnostics].
List<Issue> compareDiagnostics(
  Repo repo,
  Map<String, Set<String>> expected,
  List<Diagnostic> diagnostics,
) {
  final issues = <Issue>[];
  for (final entry in expected.entries) {
    final path = repo.relative(entry.key);
    final actual = diagnostics
        .where((d) => p.equals(d.path, entry.key))
        .map((d) => d.code)
        .toSet();
    if (entry.value.isEmpty) {
      issues.add(
        Issue(
          path,
          'Declare the diagnostics this file must produce '
          'with "// expect: code".',
        ),
      );
      continue;
    }
    for (final code in entry.value.difference(actual)) {
      issues.add(
        Issue(
          path,
          'Expected "$code" but the analyzer did not '
          'report it. Is the example still broken?',
        ),
      );
    }
    for (final code in actual.difference(entry.value)) {
      issues.add(
        Issue(
          path,
          'Unexpected diagnostic "$code". Add it to the '
          'expect comment or fix the example.',
        ),
      );
    }
  }
  return issues..sort();
}

/// Analyzes `examples/broken/` and checks every file fails exactly as its
/// `// expect:` comment says.
Future<List<Issue>> checkBroken(Repo repo, {String dart = 'dart'}) async {
  final dir = Directory(p.join(repo.examplesDir, 'broken'));
  if (!dir.existsSync()) return const [];
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
  if (files.isEmpty) return const [];

  final result = await Process.run(dart, [
    'analyze',
    '--format=machine',
    dir.path,
  ], workingDirectory: repo.examplesDir);
  final diagnostics = parseMachineOutput('${result.stdout}\n${result.stderr}');
  return compareDiagnostics(repo, {
    for (final f in files)
      p.normalize(f.absolute.path): expectedCodes(f.readAsStringSync()),
  }, diagnostics);
}
