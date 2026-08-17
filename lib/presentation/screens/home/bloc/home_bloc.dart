import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/note/note_images.dart';
import 'package:note/data/model/search_match.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/sync/sync_scheduler.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/home/home_argument.dart';

part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required HomeArgument argument,
    required NoteRepository noteRepository,
    required SyncScheduler syncScheduler,
  }) : _noteRepository = noteRepository,
       _syncScheduler = syncScheduler,
       super(HomeState.initial(argument: argument)) {
    _syncSubscription = _syncScheduler.results
        .where((result) => result.received > 0)
        .listen((_) => add(const HomeEvent.onInitiated()));

    on<_OnInitiated>(_onInitiated);
    on<_OnNoteSubmitted>(_onNoteSubmitted);
    on<_OnFavoriteToggled>(_onFavoriteToggled);
    on<_OnNoteDeleted>(_onNoteDeleted);
    on<_OnNoteRestored>(_onNoteRestored);
    on<_OnNotePurged>(_onNotePurged);
    on<_OnBinEmptied>(_onBinEmptied);
    on<_OnSearchChanged>(_onSearchChanged);
    on<_OnCategoryCreated>(_onCategoryCreated);
    on<_OnCategoryRenamed>(_onCategoryRenamed);
    on<_OnCategoryDeleted>(_onCategoryDeleted);
    on<_OnChecklistItemToggled>(_onChecklistItemToggled);
  }

  final NoteRepository _noteRepository;
  final SyncScheduler _syncScheduler;

  late final StreamSubscription<SyncResult> _syncSubscription;

  @override
  Future<void> close() async {
    await _syncSubscription.cancel();

    return super.close();
  }

  Future<void> _onInitiated(_OnInitiated event, Emitter<HomeState> emit) async {
    emit(state.copyWith(type: StateType.loading));

    await _noteRepository.purgeExpiredBin().run();
    await _loadContent(emit);
  }

  Future<void> _onNoteSubmitted(_OnNoteSubmitted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(saveType: StateType.loading));

    final categoryName = event.categoryName?.trim() ?? '';
    final result = await _resolveCategory(
      categoryName,
    ).flatMap((category) => _noteRepository.saveNote(note: _buildNote(event, category))).run();

    await result.match((error) async => emit(state.copyWith(saveType: StateType.error)), (_) async {
      await _reloadAndSync(emit);
      emit(state.copyWith(saveType: StateType.success));
      emit(state.copyWith(saveType: StateType.initial));
    });
  }

  Future<void> _onFavoriteToggled(_OnFavoriteToggled event, Emitter<HomeState> emit) async {
    final note = state.notes.firstWhereOrNull((note) => note.id == event.noteId);

    if (note == null) {
      return;
    }

    await _noteRepository.saveNote(note: note.copyWith(isFavorite: !note.isFavorite)).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onSearchChanged(_OnSearchChanged event, Emitter<HomeState> emit) async {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onCategoryCreated(_OnCategoryCreated event, Emitter<HomeState> emit) async {
    final name = event.name.trim();

    if (name.isEmpty) {
      return;
    }

    await _noteRepository.resolveCategory(name: name).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onCategoryRenamed(_OnCategoryRenamed event, Emitter<HomeState> emit) async {
    final name = event.name.trim();
    final category = state.categories.firstWhereOrNull((category) => category.id == event.id);

    if (name.isEmpty || category == null || category.name == name) {
      return;
    }

    final result = await _noteRepository.findCategory(name: name).run();
    final existing = result.getOrElse((error) => null);

    if (existing != null && existing.id != category.id) {
      emit(state.copyWith(saveType: StateType.error));
      emit(state.copyWith(saveType: StateType.initial));

      return;
    }

    await _noteRepository.renameCategory(category: category.copyWith(name: name)).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onCategoryDeleted(_OnCategoryDeleted event, Emitter<HomeState> emit) async {
    await _noteRepository.deleteCategory(id: event.id).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onNoteDeleted(_OnNoteDeleted event, Emitter<HomeState> emit) async {
    await _noteRepository.deleteNote(id: event.noteId).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onNoteRestored(_OnNoteRestored event, Emitter<HomeState> emit) async {
    await _noteRepository.restoreNote(id: event.noteId).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onNotePurged(_OnNotePurged event, Emitter<HomeState> emit) async {
    await _noteRepository.purgeNote(id: event.noteId).run();
    await _reloadAndSync(emit);
  }

  Future<void> _onBinEmptied(_OnBinEmptied event, Emitter<HomeState> emit) async {
    await _noteRepository.emptyBin().run();
    await _reloadAndSync(emit);
  }

  Future<void> _onChecklistItemToggled(_OnChecklistItemToggled event, Emitter<HomeState> emit) async {
    final note = state.notes.firstWhereOrNull((note) => note.id == event.noteId);

    if (note == null) {
      return;
    }

    final items = [...note.checklistItems];

    if (event.itemIndex < 0 || event.itemIndex >= items.length) {
      return;
    }

    items[event.itemIndex] = items[event.itemIndex].copyWith(isDone: !items[event.itemIndex].isDone);

    await _noteRepository.saveNote(note: note.copyWith(todoList: Checklist.encode(items))).run();
    await _reloadAndSync(emit);
  }

  Future<void> _reloadAndSync(Emitter<HomeState> emit) async {
    await _loadContent(emit);

    _syncScheduler.schedule();
  }

  Note _buildNote(_OnNoteSubmitted event, Category? category) {
    final storedNote = state.notes.firstWhereOrNull((note) => note.id == event.id);
    final title = event.title.trim();
    final checklistItems = event.checklistItems;

    return (storedNote ?? Note(title: title)).copyWith(
      title: title,
      todoList: checklistItems == null ? null : Checklist.encode(checklistItems),
      noteContents: checklistItems == null ? event.contents : null,
      categoryId: category?.id,
      date: event.date,
      isProtected: event.isProtected,
      imagePaths: NoteImages.encode(event.imageNames),
    );
  }

  TaskEither<ErrorDetail, Category?> _resolveCategory(String name) {
    return name.isEmpty
        ? TaskEither<ErrorDetail, Category?>.of(null)
        : _noteRepository.resolveCategory(name: name).map<Category?>((category) => category);
  }

  Future<void> _loadContent(Emitter<HomeState> emit) async {
    final result = await _noteRepository
        .getNotes()
        .flatMap(
          (notes) => _noteRepository.getCategories().flatMap(
            (categories) => _noteRepository.getDeletedNotes().map(
              (deletedNotes) => (notes: notes, categories: categories, deletedNotes: deletedNotes),
            ),
          ),
        )
        .run();

    result.match(
      (error) => emit(state.copyWith(type: StateType.error)),
      (content) => emit(
        state.copyWith(
          type: content.notes.isEmpty ? StateType.empty : StateType.loaded,
          notes: content.notes,
          categories: content.categories,
          deletedNotes: content.deletedNotes,
        ),
      ),
    );
  }
}
