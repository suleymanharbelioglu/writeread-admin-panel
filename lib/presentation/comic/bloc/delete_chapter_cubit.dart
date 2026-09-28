import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_last_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_last_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';

class DeleteChapterCubit extends Cubit<DeleteChapterState> {
  DeleteChapterCubit({
    required DeleteLastChapterUseCase deleteLastChapterUseCase,
  })  : _deleteLastChapterUseCase = deleteLastChapterUseCase,
        super(const DeleteChapterInitial());

  final DeleteLastChapterUseCase _deleteLastChapterUseCase;

  Future<void> deleteLastChapter(
    String comicId, {
    String locale = AppLocales.english,
  }) async {
    emit(const DeleteChapterLoading());
    try {
      final result = await _deleteLastChapterUseCase.call(
        params: DeleteLastChapterParams(comicId: comicId, locale: locale),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('DeleteChapter failure: $message');
          emit(DeleteChapterFailure(message));
        },
        (_) => emit(DeleteChapterSuccess(locale: locale)),
      );
    } catch (e, stackTrace) {
      AppLog.error('DeleteChapterCubit.deleteLastChapter', e, stackTrace);
      if (isClosed) return;
      emit(
        const DeleteChapterFailure(
          'Unexpected error while deleting the chapter',
        ),
      );
    }
  }
}
