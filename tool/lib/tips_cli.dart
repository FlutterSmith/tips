/// Command-line tooling for the fluttersmith/tips handbook.
library;

import 'dart:io';

import 'package:args/command_runner.dart';

import 'src/broken.dart';
import 'src/excerpt.dart';
import 'src/generate.dart' as gen;
import 'src/issue.dart';
import 'src/model.dart';
import 'src/repo.dart';
import 'src/scaffold.dart';
import 'src/validate.dart';

export 'src/broken.dart';
export 'src/excerpt.dart';
export 'src/generate.dart';
export 'src/issue.dart';
export 'src/model.dart';
export 'src/repo.dart';
export 'src/scaffold.dart';
export 'src/validate.dart';

/// Runs the CLI and returns the process exit code.
Future<int> runTips(List<String> args) async {
  final runner = CommandRunner<int>('tips', 'Keep the tips handbook honest.')
    ..argParser.addOption('root', help: 'Repository root (default: search up).')
    ..addCommand(_ValidateCommand())
    ..addCommand(_SyncCommand())
    ..addCommand(_GenerateCommand())
    ..addCommand(_NewCommand())
    ..addCommand(_CheckBrokenCommand());
  try {
    return await runner.run(args) ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    return 64;
  } on StateError catch (e) {
    stderr.writeln(e.message);
    return 1;
  }
}

abstract class _TipsCommand extends Command<int> {
  Repo get repo => Repo.find(globalResults?.option('root'));

  int report(List<Issue> issues, String ok) {
    if (issues.isEmpty) {
      stdout.writeln(ok);
      return 0;
    }
    issues.forEach(stderr.writeln);
    stderr.writeln(
      '\n${issues.length} '
      '${issues.length == 1 ? 'problem' : 'problems'} found.',
    );
    return 1;
  }
}

class _ValidateCommand extends _TipsCommand {
  @override
  String get name => 'validate';

  @override
  String get description =>
      'Check frontmatter, links, assets, code fences '
      'and copy rules.';

  @override
  Future<int> run() async {
    final repo = this.repo;
    final count = repo.loadTips().length;
    return report(validate(repo), 'All $count tips look good.');
  }
}

class _SyncCommand extends _TipsCommand {
  _SyncCommand() {
    argParser.addFlag(
      'check',
      negatable: false,
      help: 'Fail instead of writing if anything is stale.',
    );
  }

  @override
  String get name => 'sync';

  @override
  String get description => 'Refresh code blocks from examples/ sources.';

  @override
  String get invocation => 'tips sync [--check] [slug ...]';

  @override
  Future<int> run() async {
    final repo = this.repo;
    final check = argResults!.flag('check');
    final issues = <Issue>[];
    final stale = <String>[];
    final only = argResults!.rest.toSet();
    for (final file in repo.loadTips()) {
      if (only.isNotEmpty && !only.contains(file.slug)) continue;
      final result = syncMarkdown(file.text, repo.readExcerpt, path: file.path);
      issues.addAll(result.issues);
      if (result.markdown != file.text) {
        stale.add(file.path);
        if (!check) repo.file(file.path).writeAsStringSync(result.markdown);
      }
    }
    if (check && stale.isNotEmpty) {
      issues.addAll(
        stale.map(
          (path) => Issue(path, 'Code excerpts are stale. Run `tips sync`.'),
        ),
      );
    }
    final verb = check ? 'up to date' : 'synced';
    final summary = !check && stale.isNotEmpty
        ? 'Updated ${stale.length} ${stale.length == 1 ? 'file' : 'files'}.'
        : 'All excerpts $verb.';
    return report(issues, summary);
  }
}

class _GenerateCommand extends _TipsCommand {
  _GenerateCommand() {
    argParser
      ..addFlag(
        'check',
        negatable: false,
        help: 'Fail instead of writing if generated files are stale.',
      )
      ..addFlag(
        'site',
        negatable: false,
        help: 'Also write site/src/generated/meta.json.',
      )
      ..addOption('dart', help: 'Dart version to stamp on the site.')
      ..addOption(
        'verified-at',
        help: 'Date of the last green CI run (YYYY-MM-DD).',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description =>
      'Number tips and write the catalog, navigation '
      'and attribution.';

  @override
  Future<int> run() async {
    final repo = this.repo;
    final args = argResults!;
    final outputs = gen.plan(
      repo,
      site: args.flag('site'),
      dartVersion:
          args.option('dart') ?? Platform.environment['TIPS_DART_VERSION'],
      verifiedAt:
          args.option('verified-at') ??
          Platform.environment['TIPS_VERIFIED_AT'],
    );
    final check = args.flag('check');
    final changed = gen.write(repo, outputs, dryRun: check);
    if (check) {
      return report([
        for (final path in changed) Issue(path, 'Stale. Run `tips generate`.'),
      ], 'Generated files are up to date.');
    }
    stdout.writeln(
      changed.isEmpty
          ? 'Nothing to update.'
          : 'Updated:\n${changed.map((c) => '  $c').join('\n')}',
    );
    return 0;
  }
}

class _NewCommand extends _TipsCommand {
  _NewCommand() {
    argParser
      ..addOption(
        'category',
        abbr: 'c',
        mandatory: true,
        allowed: Category.values.map((c) => c.name),
      )
      ..addOption('slug', help: 'Override the slug derived from the title.');
  }

  @override
  String get name => 'new';

  @override
  String get description => 'Scaffold a draft tip with an example and a test.';

  @override
  String get invocation => 'tips new "<title>" -c <category>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 1) usageException('Pass the title in quotes.');
    final category = Category.values.byName(argResults!.option('category')!);
    final created = scaffold(
      repo,
      title: rest.single,
      category: category,
      slug: argResults!.option('slug'),
    );
    stdout
      ..writeln('Created:')
      ..writeln(created.map((c) => '  $c').join('\n'))
      ..writeln(
        '\nWrite the example, then run `tips sync` and '
        '`tips validate`.',
      );
    return 0;
  }
}

class _CheckBrokenCommand extends _TipsCommand {
  _CheckBrokenCommand() {
    argParser.addOption(
      'dart',
      defaultsTo: 'dart',
      help: 'Path to the dart executable.',
    );
  }

  @override
  String get name => 'check-broken';

  @override
  String get description =>
      'Verify examples/broken/ fails exactly as each '
      "file's `// expect:` comment says.";

  @override
  Future<int> run() async => report(
    await checkBroken(repo, dart: argResults!.option('dart')!),
    'Broken examples fail as expected.',
  );
}
