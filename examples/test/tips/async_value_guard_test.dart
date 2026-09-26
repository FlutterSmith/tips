import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tips_examples/tips/async-value-guard/save_note.dart';

class _ControlledApi extends NotesApi {
  final pending = Completer<void>();

  @override
  Future<void> save(String text) => pending.future;
}

class _FailingApi extends NotesApi {
  @override
  Future<void> save(String text) async =>
      throw StateError('disk full');
}

ProviderContainer _container(NotesApi api) => ProviderContainer.test(
  overrides: [notesApiProvider.overrideWithValue(api)],
);

void main() {
  test('guard: loading, then data', () async {
    final api = _ControlledApi();
    final container = _container(api);
    container.listen(saveNoteProvider, (_, _) {});

    final saving = container
        .read(saveNoteProvider.notifier)
        .save('hi');
    expect(container.read(saveNoteProvider).isLoading, isTrue);
    api.pending.complete();
    await saving;
    expect(container.read(saveNoteProvider), isA<AsyncData<void>>());
  });

  test('guard turns a throw into AsyncError', () async {
    final container = _container(_FailingApi());
    container.listen(saveNoteProvider, (_, _) {});
    await container.read(saveNoteProvider.notifier).save('hi');

    final state = container.read(saveNoteProvider);
    expect(state, isA<AsyncError<void>>());
    expect(state.error, isA<StateError>());
  });

  test('try/catch ends in the same states', () async {
    final container = _container(_FailingApi());
    container.listen(saveNoteProvider, (_, _) {});
    final notifier = container.read(saveNoteProvider.notifier);

    await notifier.save('hi');
    final guarded = container.read(saveNoteProvider);
    await notifier.saveWithTryCatch('hi');
    final caught = container.read(saveNoteProvider);

    expect(caught.runtimeType, guarded.runtimeType);
    expect('${caught.error}', '${guarded.error}');
  });

  test('without a mounted check, a late write throws', () async {
    final api = _ControlledApi();
    final container = ProviderContainer(
      overrides: [notesApiProvider.overrideWithValue(api)],
    );
    final saving = container
        .read(saveNoteProvider.notifier)
        .save('hi');
    container.dispose();
    api.pending.complete();
    await expectLater(
      saving,
      throwsA(
        predicate((e) => '$e'.contains('after it has been disposed')),
      ),
    );
  });

  test('with the check, disposal mid-save is fine', () async {
    final api = _ControlledApi();
    final container = _container(api);
    final sub = container.listen(autoSaveNoteProvider, (_, _) {});

    final saving = container
        .read(autoSaveNoteProvider.notifier)
        .save('hi');
    sub.close();
    await container.pump();
    expect(container.exists(autoSaveNoteProvider), isFalse);

    api.pending.complete();
    await expectLater(saving, completes);
  });

  test('a test function narrows what guard catches', () async {
    Future<int> fail() async => throw ArgumentError('bad');
    final caught = await AsyncValue.guard(fail);
    expect(caught, isA<AsyncError<int>>());
    await expectLater(
      AsyncValue.guard(fail, (e) => e is! ArgumentError),
      throwsArgumentError,
    );
  });
}
