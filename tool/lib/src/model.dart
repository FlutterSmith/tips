import 'package:yaml/yaml.dart';

/// Fixed top-level grouping of tips. Order here is the order on the site.
enum Category {
  dart('Dart language'),
  widgets('Widgets & layout'),
  state('State management'),
  architecture('Architecture'),
  testing('Testing'),
  tooling('Tooling & IDE'),
  devtools('DevTools & performance'),
  firebase('Firebase & backend'),
  platform('Platform & release'),
  practices('Practices');

  const Category(this.label);

  final String label;
}

enum Level { beginner, intermediate, advanced }

enum Status {
  /// Work in progress: validated, but never published.
  draft,
  current,

  /// Still published, flagged with the outdated banner.
  outdated,

  /// Kept for history; not listed in the index.
  archived;

  bool get isPublished => this != draft;
}

/// How an adapted tip relates to its upstream original.
enum Change { kept, modernized, rewritten, merged }

/// Link back to the upstream MIT-licensed tip this one derives from.
class Origin {
  const Origin({
    required this.upstreamId,
    required this.upstreamPath,
    required this.change,
  });

  final int upstreamId;
  final String upstreamPath;
  final Change change;

  /// Credit wording; rewrites are "inspired by" so our words are never
  /// presented as the original author's.
  String get creditVerb =>
      change == Change.rewritten ? 'Inspired by' : 'Adapted from';
}

/// A tip parsed from `content/tips/<slug>/index.md`.
class Tip {
  const Tip({
    required this.slug,
    required this.title,
    required this.summary,
    required this.category,
    required this.tags,
    required this.level,
    required this.published,
    required this.status,
    required this.packages,
    required this.experimental,
    required this.origin,
    required this.related,
    required this.body,
    required this.bodyLineOffset,
  });

  final String slug;
  final String title;
  final String summary;
  final Category category;
  final List<String> tags;
  final Level level;
  final DateTime published;
  final Status status;
  final Map<String, String> packages;
  final bool experimental;
  final Origin? origin;
  final List<String> related;

  /// Markdown after the frontmatter.
  final String body;

  /// Number of lines before [body] in the file, for `file:line` messages.
  final int bodyLineOffset;
}

/// Thrown when a tip's frontmatter is missing or malformed.
class TipFormatException implements Exception {
  const TipFormatException(this.message, {this.line = 1});

  final String message;
  final int line;

  @override
  String toString() => 'TipFormatException(line $line): $message';
}

/// Splits `---` frontmatter from the Markdown body.
({String yaml, String body, int bodyLineOffset}) splitFrontmatter(String text) {
  final normalized = text.replaceAll('\r\n', '\n');
  if (!normalized.startsWith('---\n')) {
    throw const TipFormatException('File must start with "---" frontmatter.');
  }
  final end = normalized.indexOf('\n---\n', 3);
  if (end == -1) {
    throw const TipFormatException('Frontmatter is not closed with "---".');
  }
  final yaml = normalized.substring(4, end + 1);
  final body = normalized.substring(end + 5);
  final offset = '\n'.allMatches(normalized.substring(0, end + 5)).length;
  return (yaml: yaml, body: body, bodyLineOffset: offset);
}

/// Parses a tip file. [slug] is the folder name.
Tip parseTip(String slug, String text) {
  final parts = splitFrontmatter(text);
  final Object? doc;
  try {
    doc = loadYaml(parts.yaml);
  } on YamlException catch (e) {
    throw TipFormatException(
      'Invalid YAML: ${e.message}',
      line: (e.span?.start.line ?? 0) + 2,
    );
  }
  if (doc is! YamlMap) {
    throw const TipFormatException('Frontmatter must be a YAML map.');
  }
  final fields = _Fields(doc);

  final declaredSlug = fields.string('slug');
  if (declaredSlug != slug) {
    throw TipFormatException(
      'slug "$declaredSlug" must match its folder name "$slug".',
      line: fields.line('slug'),
    );
  }

  return Tip(
    slug: slug,
    title: fields.string('title'),
    summary: fields.string('summary'),
    category: fields.enumValue('category', Category.values),
    tags: fields.stringList('tags'),
    level: fields.enumValue('level', Level.values),
    published: fields.date('published'),
    status: fields.enumValue('status', Status.values),
    packages: fields.stringMap('packages'),
    experimental: fields.boolean('experimental'),
    origin: fields.origin('origin'),
    related: fields.stringList('related'),
    body: parts.body,
    bodyLineOffset: parts.bodyLineOffset,
  );
}

const _knownKeys = {
  'slug',
  'title',
  'summary',
  'category',
  'tags',
  'level',
  'published',
  'status',
  'packages',
  'experimental',
  'origin',
  'related',
};

/// Typed, line-aware accessors over a YAML map.
class _Fields {
  _Fields(this._map) {
    for (final key in _map.keys) {
      if (!_knownKeys.contains(key)) {
        throw TipFormatException('Unknown field "$key".', line: line('$key'));
      }
    }
  }

  final YamlMap _map;

  int line(String key) {
    final node = _map.nodes[key];
    return node == null ? 1 : node.span.start.line + 2;
  }

  Object? _value(String key, {bool required = true}) {
    final value = _map[key];
    if (value == null && required) {
      throw TipFormatException('Missing required field "$key".');
    }
    return value;
  }

  String string(String key) {
    final value = _value(key);
    if (value is! String || value.trim().isEmpty) {
      throw TipFormatException(
        '"$key" must be a non-empty string.',
        line: line(key),
      );
    }
    return value.trim();
  }

  T enumValue<T extends Enum>(String key, List<T> values) {
    final value = string(key);
    for (final v in values) {
      if (v.name == value) return v;
    }
    throw TipFormatException(
      '"$key" must be one of ${values.map((v) => v.name).join(', ')}; '
      'got "$value".',
      line: line(key),
    );
  }

  List<String> stringList(String key) {
    final value = _value(key, required: false);
    if (value == null) return const [];
    if (value is! YamlList || value.any((e) => e is! String)) {
      throw TipFormatException(
        '"$key" must be a list of strings.',
        line: line(key),
      );
    }
    return List.unmodifiable(value.cast<String>());
  }

  Map<String, String> stringMap(String key) {
    final value = _value(key, required: false);
    if (value == null) return const {};
    if (value is! YamlMap) {
      throw TipFormatException('"$key" must be a map.', line: line(key));
    }
    return Map.unmodifiable({
      for (final e in value.entries) '${e.key}': '${e.value}',
    });
  }

  bool boolean(String key) {
    final value = _value(key, required: false);
    if (value == null) return false;
    if (value is! bool) {
      throw TipFormatException(
        '"$key" must be true or false.',
        line: line(key),
      );
    }
    return value;
  }

  DateTime date(String key) {
    final value = '${_value(key)}';
    final parsed = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)
        ? DateTime.tryParse(value)
        : null;
    if (parsed == null) {
      throw TipFormatException(
        '"$key" must be a date like 2026-10-12.',
        line: line(key),
      );
    }
    return parsed;
  }

  Origin? origin(String key) {
    final value = _value(key, required: false);
    if (value == null) return null;
    if (value is! YamlMap) {
      throw TipFormatException('"$key" must be a map.', line: line(key));
    }
    final id = value['upstream_id'];
    final path = value['upstream_path'];
    final change = value['change'];
    if (id is! int || path is! String || change is! String) {
      throw TipFormatException(
        '"$key" needs upstream_id (int), upstream_path and change.',
        line: line(key),
      );
    }
    final parsed = Change.values.where((c) => c.name == change);
    if (parsed.isEmpty) {
      throw TipFormatException(
        '"$key.change" must be one of '
        '${Change.values.map((c) => c.name).join(', ')}.',
        line: line(key),
      );
    }
    return Origin(upstreamId: id, upstreamPath: path, change: parsed.first);
  }
}
