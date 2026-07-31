import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_all_chapter_images_params.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';

class EditChapterCubit extends Cubit<EditChapterState> {
  EditChapterCubit({
    required UpdateChapterUseCase updateChapterUseCase,
    required DeleteAllChapterImagesUseCase deleteAllChapterImagesUseCase,
  })  : _updateChapterUseCase = updateChapterUseCase,
        _deleteAllChapterImagesUseCase = deleteAllChapterImagesUseCase,
        super(const EditChapterInitial());

  final UpdateChapterUseCase _updateChapterUseCase;
  final DeleteAllChapterImagesUseCase _deleteAllChapterImagesUseCase;

  Future<void> setFreePreview({
    required String comicId,
    required String chapterId,
    required bool isFreePreview,
  }) {
    return _update(
      UpdateChapterParams(
        comicId: comicId,
        chapterId: chapterId,
        isFreePreview: isFreePreview,
      ),
    );
  }

  Future<void> addImages({
    required String comicId,
    required String chapterId,
    required List<List<int>> imageBytesList,
  }) {
    return _update(
      UpdateChapterParams(
        comicId: comicId,
        chapterId: chapterId,
        additionalImageBytesList: imageBytesList,
      ),
    );
  }

  Future<void> uploadMusic({
    required String comicId,
    required String chapterId,
    required List<int> musicBytes,
  }) {
    return _update(
      UpdateChapterParams(
        comicId: comicId,
        chapterId: chapterId,
        musicBytes: musicBytes,
      ),
    );
  }

  Future<void> _update(UpdateChapterParams params) async {
    emit(EditChapterLoading(chapterId: params.chapterId));
    try {
      final result = await _updateChapterUseCase.call(params: params);
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('UpdateChapter failure: $message');
          emit(EditChapterFailure(message));
        },
        (musicUrl) => emit(
          EditChapterSuccess(
            chapterId: params.chapterId,
            isFreePreview: params.isFreePreview,
            addedImageCount: params.additionalImageBytesList?.length,
            musicUrl: musicUrl,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('EditChapterCubit._update', e, stackTrace);
      if (isClosed) return;
      emit(
        const EditChapterFailure(
          'Unexpected error while updating the chapter',
        ),
      );
    }
  }

  Future<void> deleteAllChapterImages(String comicId, String chapterId) async {
    emit(EditChapterLoading(chapterId: chapterId));
    try {
      final result = await _deleteAllChapterImagesUseCase.call(
        params: DeleteAllChapterImagesParams(
          comicId: comicId,
          chapterId: chapterId,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('DeleteChapterImages failure: $message');
          emit(EditChapterFailure(message));
        },
        (_) => emit(EditChapterImagesDeleted(chapterId: chapterId)),
      );
    } catch (e, stackTrace) {
      AppLog.error('EditChapterCubit.deleteAllChapterImages', e, stackTrace);
      if (isClosed) return;
      emit(
        const EditChapterFailure(
          'Unexpected error while deleting chapter images',
        ),
      );
    }
  }
}
