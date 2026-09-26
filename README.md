<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/assets/wordmark-dark.svg">
    <img alt="fluttersmith/tips" src=".github/assets/wordmark-light.svg" width="360">
  </picture>
</p>

**Flutter tips that still compile.** Short, practical notes on Dart, widgets and Riverpod. Every snippet on the site is real code that CI analyzes and tests against the current Flutter stable release.

[![CI](https://github.com/FlutterSmith/tips/actions/workflows/ci.yml/badge.svg)](https://github.com/FlutterSmith/tips/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-0B7F9C)](LICENSE)

**Read it on the web: [fluttersmith.github.io/tips](https://fluttersmith.github.io/tips/)**. It has search that finds API names, annotated code, dark mode and keyboard shortcuts. Everything below also works right here on GitHub.

## The tips

<!-- tips:catalog -->

**30 tips** in 3 categories. Tap a category to open it.

<details>
<summary><b>Dart language</b> · 10 tips</summary>

- `001` [Measure execution time with Stopwatch](content/tips/stopwatch-measure-time/index.md): DateTime.now() reads the wall clock, which can jump. Stopwatch can't, so use it to time code.
- `005` [A Result type with a sealed class](content/tips/sealed-class-result/index.md): Return success or failure instead of throwing, and let an exhaustive switch make sure every caller handles both.
- `008` [Switch on a record to match several values at once](content/tips/switch-on-records/index.md): Put two or three values in a record and switch on it. Each case is a row in a table, instead of a tangle of if/else.
- `010` [Return multiple values with a record](content/tips/records-multiple-returns/index.md): A record returns two or more values without a throwaway class, and destructuring unpacks them in one line at the call site.
- `013` [Destructure lists with list patterns](content/tips/destructure-lists/index.md): List patterns pull values out of a list by position, and a rest element skips or collects whatever sits in the middle.
- `016` [Await several futures with a record's .wait](content/tips/future-wait-records/index.md): Future.wait gives you a List of Object. A record of futures with .wait keeps each type and tells you which one failed.
- `019` [Extension types vs extension methods](content/tips/extension-types/index.md): An extension method adds to a type. An extension type wraps it in a new static type, so a UserId can't be passed where an OrderId belongs.
- `021` [Skip nulls in collection literals with ...? and ?value](content/tips/null-aware-elements/index.md): The null-aware spread adds nothing for a null list, and a null-aware element leaves out a null entry, so you can drop the if (x != null).
- `024` [firstOrNull instead of try/catch on StateError](content/tips/first-or-null/index.md): first, firstWhere and single throw when nothing matches. The OrNull versions return null, and the type system makes you handle it.
- `028` [Parse JSON safely with map patterns](content/tips/json-pattern-matching/index.md): A switch on a map pattern checks keys and value types in one go, so bad JSON reaches your fallback case instead of a TypeError.

</details>
<details>
<summary><b>Widgets & layout</b> · 10 tips</summary>

- `002` [Column(spacing:) replaces a SizedBox between every child](content/tips/column-row-spacing/index.md): Row, Column and Flex take a spacing value, so you no longer need a SizedBox or the gap package between children.
- `004` [Check context.mounted after every await](content/tips/context-mounted-async-gaps/index.md): A BuildContext can go stale while you await. Check context.mounted before you use it again, or grab what you need first.
- `007` [Use MediaQuery.sizeOf instead of MediaQuery.of](content/tips/mediaquery-sizeof/index.md): MediaQuery.of rebuilds your widget when anything changes. MediaQuery.sizeOf and friends rebuild only when the value you read changes.
- `011` [Return SizedBox.shrink() when there is nothing to show](content/tips/sizedbox-shrink/index.md): A build method must return a widget. For "nothing", return const SizedBox.shrink(), not an empty Container.
- `015` [Give buttons the same width with IntrinsicWidth](content/tips/intrinsic-width/index.md): Wrap a Column in IntrinsicWidth and stretch its children, and every button matches the widest one, whatever the text size.
- `017` [Replace Container with the widgets it wraps](content/tips/replace-container/index.md): Container is a bundle of Padding, ColoredBox, DecoratedBox, Align and SizedBox. Use those directly and the whole subtree can be const.
- `020` [React to the app going to the background with AppLifecycleListener](content/tips/app-lifecycle-listener/index.md): AppLifecycleListener gives you one named callback per lifecycle transition. No observer mixin needed, but you must dispose it.
- `023` [Make text selectable across widgets with SelectionArea](content/tips/selection-area/index.md): Wrap a subtree in SelectionArea and one selection runs across all its Text widgets. SelectionContainer.disabled carves out the parts to skip.
- `026` [Show real progress with a value on progress indicators](content/tips/determinate-progress/index.md): Give CircularProgressIndicator or LinearProgressIndicator a value from 0.0 to 1.0 and they show how far along you are instead of spinning.
- `029` [Style an ElevatedButton with styleFrom and themes](content/tips/elevated-button-style/index.md): Use ElevatedButton.styleFrom for one button, ElevatedButtonThemeData for all of them, and WidgetStateProperty when a style depends on state.

</details>
<details>
<summary><b>State management</b> · 10 tips</summary>

- `003` [Getting a Future from a FutureProvider](content/tips/future-provider-future/index.md): Watch provider.future to await one async provider inside another, and combine the results with plain async code.
- `006` [The parts of a Riverpod 3 provider](content/tips/provider-anatomy/index.md): A provider is a global variable, a type, a body that gets a Ref, and optional modifiers. Here is what each part does.
- `009` [ref.watch, ref.read or ref.listen?](content/tips/ref-watch-read-listen/index.md): Watch to rebuild, read for a one-off value inside a callback, listen to run side effects like SnackBars.
- `012` [Which Riverpod 3 provider should you use?](content/tips/which-provider/index.md): Six providers cover almost every job in Riverpod 3. StateProvider, StateNotifierProvider and ChangeNotifierProvider now live in legacy.dart.
- `014` [One widget for AsyncValue loading and error states](content/tips/async-value-widget/index.md): Wrap AsyncValue in a small widget with a switch over AsyncData, AsyncError and AsyncLoading, and every async screen writes only its data UI.
- `018` [AsyncValue.guard instead of try/catch in notifiers](content/tips/async-value-guard/index.md): AsyncValue.guard runs a Future and hands back AsyncData or AsyncError, so notifier methods need no try/catch.
- `022` [Pass arguments to a Notifier through its constructor](content/tips/notifier-with-arguments/index.md): In Riverpod 3 a family notifier is a plain Notifier that takes its argument in the constructor, so every method can use it as a field.
- `025` [Initialise async dependencies in main() and use requireValue](content/tips/require-value-async-init/index.md): Await a FutureProvider once before runApp, then read it synchronously everywhere with requireValue. No loading states for things that are always ready.
- `027` [Migrate a StateNotifier to a Notifier](content/tips/notifier-replaces-state-notifier/index.md): StateNotifier now lives in legacy.dart. Moving to Notifier takes a few mechanical steps, and one behaviour change is worth knowing about.
- `030` [Check ref.mounted after an await in a provider](content/tips/ref-mounted/index.md): A provider can be disposed while a Future is pending. Check ref.mounted after the await before you touch state, or Riverpod 3 throws.

</details>
<!-- /tips:catalog -->

The full numbered list is in [CATALOG.md](CATALOG.md).

## How it stays correct

```
examples/lib/tips/<slug>/*.dart   real code, analyzed with strict lints
examples/test/tips/*_test.dart    tests that prove what each tip claims
content/tips/<slug>/index.md      the tip; code blocks are copied in from examples/
tool/                             the `tips` CLI: sync, validate, generate
site/                             the website (Astro + Pagefind)
```

- A tip never contains hand-typed Dart. `tips sync` copies each snippet from `examples/`, and CI fails if a tip and its source drift apart.
- Code that is supposed to fail (the "don't do this" examples) lives in `examples/broken/` and CI checks that it fails with exactly the expected error.
- Every week CI re-runs everything against the newest Flutter stable and opens an issue if a tip stops compiling.

## Why this exists

This project started from Andrea Bizzotto's [Flutter Tips & Tricks](https://github.com/bizz84/flutter-tips-and-tricks), a great collection of tips first shared on social media between 2021 and 2024. The ideas are excellent, but most of the code lives in screenshots, and the Flutter ecosystem has moved on since (Riverpod 3, Dart 3 patterns, new widget APIs).

| | Original collection | This project |
|:--|:--|:--|
| Code | Screenshots, mostly | Text you can copy, analyzed and tested in CI |
| Up to date | Last updated June 2024 | Checked weekly against current Flutter |
| Finding things | One chronological list | Categories, tags, learning paths, full-text search |
| Accessibility | Most images have no alt text | Alt text required; code is real text |
| Annotations | Hand-drawn arrows on images | Handwritten notes on real code, kept next to the line they explain |

Tips adapted from the original credit it on every page. See [ATTRIBUTION.md](ATTRIBUTION.md).

## Contributing

Typos and wording fixes need nothing but a pull request. New tips need Flutter and one command to scaffold; [CONTRIBUTING.md](CONTRIBUTING.md) walks through it.

## License

[MIT](LICENSE). Portions adapted from Flutter Tips & Tricks, Copyright (c) 2022 Andrea Bizzotto, also MIT.
