# Contributing

Thanks for helping. This handbook has one promise: every snippet still compiles. The rules below exist to keep that promise, and CI checks all of them.

## Quick start

```sh
# Fix a typo or improve wording: edit the Markdown and open a PR.
# You don't need Flutter for that; CI runs the checks.

# Add or change code: you need Flutter (version in .fvmrc) and Dart.
cd examples && flutter pub get && cd ..
dart run tool/bin/tips.dart new "Your tip title" -c dart
# write the example + test, then:
dart run tool/bin/tips.dart sync       # copy code from examples/ into the tip
dart run tool/bin/tips.dart validate   # check the content rules
dart run tool/bin/tips.dart generate   # number the tip, update README and nav
(cd examples && flutter analyze lib test && flutter test)
```

A dev container (`.devcontainer/`) has Flutter and Node ready to go.

## How a tip is built

```
examples/lib/tips/<slug>/*.dart   real code, with #docregion markers and // @note lines
examples/test/tips/<slug>_test.dart   proves the code does what the tip says
content/tips/<slug>/index.md      frontmatter + prose + excerpt markers
```

### Frontmatter

```yaml
---
slug: stopwatch-measure-time        # same as the folder name
title: Measure execution time with Stopwatch   # ≤ 80 chars
summary: One sentence, ≤ 160 chars.
category: dart          # dart | widgets | state | architecture | testing | tooling | devtools | firebase | platform | practices
tags: [performance, async]          # from content/tags.yaml
level: beginner         # beginner | intermediate | advanced
published: 2026-09-01
status: current         # draft | current | outdated | archived
packages: { flutter_riverpod: "^3.0.0" }   # optional
experimental: false     # optional; true for experimental APIs
origin:                 # only for tips adapted from the original collection
  upstream_id: 116
  upstream_path: tips/0116-measure-time/index.md
  change: rewritten     # kept | modernized | rewritten | merged
related: [future-provider-future]           # optional, existing slugs
---
```

Numbers (`#057`) are assigned by `tips generate`. Don't write them yourself.

### Code comes from `examples/`

Never paste Dart into a tip. Mark a region in real code and point to it:

```dart
// #docregion helper
Future<(T, Duration)> measure<T>(Future<T> Function() action) async {
  // @note monotonic: it never jumps backwards
  final stopwatch = Stopwatch()..start();
  ...
}
// #enddocregion helper
```

````md
<?code-excerpt "stopwatch-measure-time/measure.dart" region="helper"?>
```dart
```
````

`tips sync` fills the fence. Paths are relative to `examples/lib/tips/`, or to `examples/` when they start with `test/` or `broken/`. Regions can sit inside a `build` method; they are dedented. Disjoint parts of one region are joined with `// ···`.

**Notes.** A line that is only `// @note text` annotates the line below it. The site draws it as a handwritten note with an arrow. Keep notes under 60 characters and use at most 4 per snippet. Put them on the lines that matter, not on every line.

**Do / Don't pairs.** Put `dont="caption"` and `do="caption"` on two consecutive fences. The site shows them side by side.

````md
<?code-excerpt "stopwatch-measure-time/measure.dart" region="avoid"?>
```dart dont="Wall-clock time. It can jump while you measure."
```

<?code-excerpt "stopwatch-measure-time/measure.dart" region="prefer"?>
```dart do="Monotonic. It only moves forward."
```
````

**Code that must not compile** (for example a Riverpod 2 API that no longer exists) goes in `examples/broken/<slug>/*.dart` with a comment naming the diagnostics it must produce: `// expect: undefined_method`. `tips check-broken` verifies it.

**Code that can't live in `examples/` at all** (rare) needs an explicit reason:

````md
<!-- nocheck: shows a pubspec snippet, not Dart -->
```dart nocheck
```
````

YAML, shell and JSON fences can be inline; just give every fence a language.

### Tests

Every example has a test that proves the tip's claim, not just that the code runs. If the tip says "the gap is 12 px", the test measures 12 px. Use `ProviderContainer.test()` for Riverpod and `testWidgets` for widgets.

## Voice

Write like a senior developer explaining something to a colleague at their desk.

- Start with the problem in one sentence. Then the code. Then why. Then what to watch out for.
- Short sentences. Name the API. Admit trade-offs.
- 350 words of prose at most.
- No emoji. No "Did you know?", "supercharge", "seamless", "game-changer", "dive in", "let's break it down". `tips validate` flags these.
- Headings inside a tip are `##`, and short: "Why not DateTime.now()?", "Good to know", "Watch out".

## Credit

Many tips are adapted from [Flutter Tips & Tricks](https://github.com/bizz84/flutter-tips-and-tricks) by Andrea Bizzotto (MIT). If your tip derives from one of them, set `origin`. Use `change: rewritten` when you wrote it fresh from the idea; the site then says "Inspired by" instead of "Adapted from". See [ATTRIBUTION.md](ATTRIBUTION.md).

## Pull requests

One tip per PR. CI runs `validate`, `sync --check`, `generate --check`, analysis, tests and a site build. A green PR is a mergeable PR.
