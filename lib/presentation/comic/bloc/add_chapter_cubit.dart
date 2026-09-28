import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/add_chapter_params.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';

class AddChapterCubit extends Cubit<AddChapterState> {
  AddChapterCubit({required AddChapterUseCase addChapterUseCase})
      : _addChapterUseCase = addChapterUseCase,
        super(const AddChapterState());

  final AddChapterUseCase _addChapterUseCase;

  void prepareForComic(
    ComicEntity comic, {
    String locale = AppLocales.english,
  }) {
    emit(
      AddChapterState(
        comicId: comic.comicId,
        comicIsFree: comic.isFree,
        locale: locale,
      ),
    );
  }

  void setFreePreview(bool value) {
    if (state.isLoading) return;
    emit(state.copyWith(isFreePreview: value, clearError: true));
  }

  void setImages(List<List<int>> images) {
    if (state.isLoading) return;
    emit(state.copyWith(imageBytesList: images, clearError: true));
  }

  void setMusic({required List<int> bytes, required String fileName}) {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        musicBytes: bytes,
        musicFileName: fileName,
        clearError: true,
      ),
    );
  }

  Future<void> submit({required String chapterName}) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: AddChapterStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final result = await _addChapterUseCase.call(
        params: AddChapterParams(
          comicId: state.comicId,
          chapterName: chapterName.trim(),
          imageBytesList: state.imageBytesList,
          isFreePreview: !state.comicIsFree && state.isFreePreview,
          musicBytes: state.musicBytes,
          locale: state.locale,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('AddChapter failure: $message');
          emit(
            state.copyWith(
              status: AddChapterStatus.failure,
              errorMessage: message,
            ),
          );
        },
        (chapter) {
          AppLog.info('AddChapter success: ${chapter.chapterId}');
          emit(
            state.copyWith(
              status: AddChapterStatus.success,
              successChapter: chapter,
              clearError: true,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLog.error('AddChapterCubit.submit', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddChapterStatus.failure,
          errorMessage: 'Unexpected error while adding the chapter',
        ),
      );
    }
  }
}
