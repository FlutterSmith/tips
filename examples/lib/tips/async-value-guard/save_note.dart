import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesApi {
  Future<void> save(String text) async {}
}

final notesApiProvider = Provider<NotesApi>((ref) => NotesApi());

final saveNoteProvider = AsyncNotifierProvider<SaveNote, void>(
  SaveNote.new,
);

class SaveNote extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // #docregion guard
  Future<void> save(String text) async {
    final api = ref.read(notesApiProvider);
    state = const AsyncLoading();
    // @note data on success, AsyncError on any throw
    state = await AsyncValue.guard(() => api.save(text));
  }
  // #enddocregion guard

  // #docregion try-catch
  Future<void> saveWithTryCatch(String text) async {
    final api = ref.read(notesApiProvider);
    state = const AsyncLoading();
    try {
      await api.save(text);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
  // #enddocregion try-catch
}

final autoSaveNoteProvider =
    AsyncNotifierProvider.autoDispose<AutoSaveNote, void>(
      AutoSaveNote.new,
    );

class AutoSaveNote extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // #docregion mounted
  Future<void> save(String text) async {
    final api = ref.read(notesApiProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => api.save(text));
    // @note the screen may have closed during the await
    if (!ref.mounted) return;
    state = result;
  }
  // #enddocregion mounted
}
