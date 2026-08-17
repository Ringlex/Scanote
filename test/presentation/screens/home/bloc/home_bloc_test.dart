import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/sync/sync_scheduler.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/home/home_argument.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

class _MockSyncScheduler extends Mock implements SyncScheduler {}

void main() {
  late _MockNoteRepository noteRepository;
  late _MockSyncScheduler syncScheduler;

  final work = Category(id: 1, name: 'praca');
  final home = Category(id: 2, name: 'dom');

  setUpAll(() {
    registerFallbackValue(Category(name: ''));
  });

  setUp(() {
    noteRepository = _MockNoteRepository();
    syncScheduler = _MockSyncScheduler();

    when(() => syncScheduler.results).thenAnswer((_) => const Stream<SyncResult>.empty());

    when(noteRepository.getNotes).thenAnswer((_) => TaskEither<ErrorDetail, List<Note>>.of(const []));
    when(noteRepository.getDeletedNotes).thenAnswer((_) => TaskEither<ErrorDetail, List<Note>>.of(const []));
    when(noteRepository.purgeExpiredBin).thenAnswer((_) => TaskEither<ErrorDetail, int>.of(0));
    when(noteRepository.getCategories).thenAnswer((_) => TaskEither<ErrorDetail, List<Category>>.of([work, home]));
    when(
      () => noteRepository.renameCategory(category: any(named: 'category')),
    ).thenAnswer((_) => TaskEither<ErrorDetail, int>.of(1));
  });

  HomeBloc buildBloc() =>
      HomeBloc(argument: const HomeArgument(), noteRepository: noteRepository, syncScheduler: syncScheduler);

  HomeState seededState() =>
      HomeState.initial(argument: const HomeArgument()).copyWith(type: StateType.loaded, categories: [work, home]);

  group('HomeBloc rename', () {
    blocTest<HomeBloc, HomeState>(
      'goes through when only the letter case changes',
      setUp: () {
        when(
          () => noteRepository.findCategory(name: 'Praca'),
        ).thenAnswer((_) => TaskEither<ErrorDetail, Category?>.of(work));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onCategoryRenamed(id: 1, name: 'Praca')),
      verify: (_) {
        verify(() => noteRepository.renameCategory(category: Category(id: 1, name: 'Praca'))).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'turns down a name another category already goes by',
      setUp: () {
        when(
          () => noteRepository.findCategory(name: 'Dom'),
        ).thenAnswer((_) => TaskEither<ErrorDetail, Category?>.of(home));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onCategoryRenamed(id: 1, name: 'Dom')),
      expect: () => [
        seededState().copyWith(saveType: StateType.error),
        seededState().copyWith(saveType: StateType.initial),
      ],
      verify: (_) {
        verifyNever(() => noteRepository.renameCategory(category: any(named: 'category')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'renames to a name nothing else uses',
      setUp: () {
        when(
          () => noteRepository.findCategory(name: 'Zakupy'),
        ).thenAnswer((_) => TaskEither<ErrorDetail, Category?>.of(null));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onCategoryRenamed(id: 1, name: 'Zakupy')),
      verify: (_) {
        verify(() => noteRepository.renameCategory(category: Category(id: 1, name: 'Zakupy'))).called(1);
      },
    );
  });

  group('HomeBloc bin', () {
    final thrownAway = Note(id: 7, title: 'wyrzucona', deletedAt: DateTime(2026, 3, 1));

    blocTest<HomeBloc, HomeState>(
      'deleting a note only throws it away, so it can still be brought back',
      setUp: () {
        when(() => noteRepository.deleteNote(id: 7)).thenAnswer((_) => TaskEither<ErrorDetail, int>.of(1));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onNoteDeleted(noteId: 7)),
      verify: (_) {
        verify(() => noteRepository.deleteNote(id: 7)).called(1);

        verifyNever(() => noteRepository.purgeNote(id: any(named: 'id')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'the bin lands in its own part of the state, apart from the live notes',
      setUp: () {
        when(noteRepository.getDeletedNotes).thenAnswer((_) => TaskEither<ErrorDetail, List<Note>>.of([thrownAway]));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeEvent.onInitiated()),
      verify: (bloc) {
        expect(bloc.state.deletedNotes, [thrownAway]);
        expect(bloc.state.notes, isEmpty);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'restoring puts the note back',
      setUp: () {
        when(() => noteRepository.restoreNote(id: 7)).thenAnswer((_) => TaskEither<ErrorDetail, int>.of(1));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onNoteRestored(noteId: 7)),
      verify: (_) {
        verify(() => noteRepository.restoreNote(id: 7)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'purging destroys the note for good',
      setUp: () {
        when(() => noteRepository.purgeNote(id: 7)).thenAnswer((_) => TaskEither<ErrorDetail, int>.of(1));
      },
      build: buildBloc,
      seed: seededState,
      act: (bloc) => bloc.add(const HomeEvent.onNotePurged(noteId: 7)),
      verify: (_) {
        verify(() => noteRepository.purgeNote(id: 7)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'whatever has outstayed its welcome is swept up on start-up',
      build: buildBloc,
      act: (bloc) => bloc.add(const HomeEvent.onInitiated()),
      verify: (_) {
        verify(noteRepository.purgeExpiredBin).called(1);
      },
    );
  });
}
