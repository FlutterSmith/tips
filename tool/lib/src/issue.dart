/// A problem found in the content, reported as `file:line: message`.
class Issue implements Comparable<Issue> {
  const Issue(this.path, this.message, {this.line = 1});

  /// Path relative to the repository root.
  final String path;
  final int line;
  final String message;

  @override
  int compareTo(Issue other) {
    final byPath = path.compareTo(other.path);
    return byPath != 0 ? byPath : line.compareTo(other.line);
  }

  @override
  String toString() => '$path:$line: $message';
}
