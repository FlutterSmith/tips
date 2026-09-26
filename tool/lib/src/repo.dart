import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'issue.dart';
import 'model.dart';

/// A tip file on disk, parsed when possible.
class TipFile {
  TipFile(this.slug, this.path, this.text, this.tip, this.error);

  final String slug;

  /// Path relative to the repository root.
  final String path;
  final String text;
  final Tip? tip;
  final TipFormatException? error;
}

/// An ordered reading list from `content/paths/<id>.yaml`.
class LearningPath {
  const LearningPath(this.id, this.title, this.summary, this.tips);

  final String id;
  final String title;
  final String summary;
  final List<String> tips;
}

/// File-system view of the repository.
class Repo {
  Repo(this.root);

  /// Walks up from [start] to the directory holding `content/tips`.
  factory Repo.find([String? start]) {
    var dir = Directory(start ?? Directory.current.path).absolute;
    while (true) {
      if (Directory(p.join(dir.path, 'content', 'tips')).existsSync()) {
        return Repo(dir.path);
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        throw StateError(
          'Could not find content/tips above ${start ?? Directory.current.path}.',
        );
      }
      dir = parent;
    }
  }

  final String root;

  String get tipsDir => p.join(root, 'content', 'tips');
  String get examplesDir => p.join(root, 'examples');

  String relative(String path) =>
      p.posix.joinAll(p.split(p.relative(path, from: root)));

  File file(String relativePath) => File(p.join(root, relativePath));

  /// Loads every `content/tips/<slug>/index.md`, sorted by slug.
  List<TipFile> loadTips() {
    final dir = Directory(tipsDir);
    final folders = dir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return [for (final folder in folders) _loadTip(folder)];
  }

  TipFile _loadTip(Directory folder) {
    final slug = p.basename(folder.path);
    final index = File(p.join(folder.path, 'index.md'));
    final path = relative(index.path);
    if (!index.existsSync()) {
      return TipFile(
        slug,
        path,
        '',
        null,
        const TipFormatException('Missing index.md.'),
      );
    }
    final text = index.readAsStringSync();
    try {
      return TipFile(slug, path, text, parseTip(slug, text), null);
    } on TipFormatException catch (e) {
      return TipFile(slug, path, text, null, e);
    }
  }

  /// Resolves an excerpt marker path to a file in `examples/`.
  ///
  /// `test/…` and `broken/…` are relative to the package; anything else is
  /// relative to `examples/lib/tips/`.
  File excerptSource(String markerPath) {
    final first = markerPath.split('/').first;
    final base = first == 'test' || first == 'broken'
        ? examplesDir
        : p.join(examplesDir, 'lib', 'tips');
    return File(p.join(base, markerPath));
  }

  String? readExcerpt(String markerPath) {
    final file = excerptSource(markerPath);
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  /// Allowed tags from `content/tags.yaml` (tag → description).
  Map<String, String> loadTags() {
    final file = File(p.join(root, 'content', 'tags.yaml'));
    if (!file.existsSync()) return const {};
    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) return const {};
    return {for (final e in doc.entries) '${e.key}': '${e.value}'};
  }

  (List<LearningPath>, List<Issue>) loadPaths() {
    final dir = Directory(p.join(root, 'content', 'paths'));
    if (!dir.existsSync()) return (const [], const []);
    final paths = <LearningPath>[];
    final issues = <Issue>[];
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.yaml'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final doc = loadYaml(file.readAsStringSync());
      final title = doc is YamlMap ? doc['title'] : null;
      final summary = doc is YamlMap ? doc['summary'] : null;
      final tips = doc is YamlMap ? doc['tips'] : null;
      if (title is! String || summary is! String || tips is! YamlList) {
        issues.add(
          Issue(
            relative(file.path),
            'A path needs title, summary and a list of tips.',
          ),
        );
        continue;
      }
      paths.add(
        LearningPath(
          p.basenameWithoutExtension(file.path),
          title,
          summary,
          tips.map((t) => '$t').toList(),
        ),
      );
    }
    return (paths, issues);
  }

  String get numbersLockPath => p.join(root, 'content', 'numbers.lock');

  /// Stable display numbers (slug → number).
  Map<String, int> loadNumbers() {
    final file = File(numbersLockPath);
    if (!file.existsSync()) return {};
    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) return {};
    return {for (final e in doc.entries) '${e.key}': e.value as int};
  }

  /// Flutter version pinned in `.fvmrc`.
  String flutterVersion() {
    final file = File(p.join(root, '.fvmrc'));
    if (!file.existsSync()) return 'unknown';
    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    return '${json['flutter'] ?? 'unknown'}';
  }
}
