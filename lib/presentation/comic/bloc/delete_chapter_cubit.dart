import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_last_chapter.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';

class DeleteChapterCubit extends Cubit<DeleteChapterState> {
  DeleteChapterCubit({DeleteLastChapterUseCase? deleteLastChapterUseCase})
      : _deleteLastChapterUseCase = deleteLastChapterUseCase,
        super(const DeleteChapterInitial());

  final DeleteLastChapterUseCase? _deleteLastChapterUseCase;

  Future<void> deleteLastChapter(String comicId) async {
    final useCase = _deleteLastChapterUseCase;
    if (useCase == null) {
      emit(const DeleteChapterFailure('Delete chapter use case not available'));
      return;
    }
    emit(const DeleteChapterLoading());
    final result = await useCase.call(params: comicId);
    result.fold(
      (message) => emit(DeleteChapterFailure(message)),
      (_) => emit(const DeleteChapterSuccess()),
    );
  }
}
