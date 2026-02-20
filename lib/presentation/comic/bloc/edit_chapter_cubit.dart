import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_all_chapter_images_params.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';

class EditChapterCubit extends Cubit<EditChapterState> {
  EditChapterCubit({
    UpdateChapterUseCase? updateChapterUseCase,
    DeleteAllChapterImagesUseCase? deleteAllChapterImagesUseCase,
  })  : _updateChapterUseCase = updateChapterUseCase,
        _deleteAllChapterImagesUseCase = deleteAllChapterImagesUseCase,
        super(const EditChapterInitial());

  final UpdateChapterUseCase? _updateChapterUseCase;
  final DeleteAllChapterImagesUseCase? _deleteAllChapterImagesUseCase;

  Future<void> updateChapter(UpdateChapterParams params) async {
    final useCase = _updateChapterUseCase;
    if (useCase == null) {
      emit(const EditChapterFailure('Update chapter use case not available'));
      return;
    }
    emit(EditChapterLoading(chapterId: params.chapterId));
    final result = await useCase.call(params: params);
    result.fold(
      (message) => emit(EditChapterFailure(message)),
      (musicUrl) => emit(EditChapterSuccess(
            chapterId: params.chapterId,
            isVip: params.isVip,
            addedImageCount: params.additionalImageBytesList?.length,
            musicUrl: musicUrl,
          )),
    );
  }

  Future<void> deleteAllChapterImages(String comicId, String chapterId) async {
    final useCase = _deleteAllChapterImagesUseCase;
    if (useCase == null) {
      emit(const EditChapterFailure(
        'Delete all chapter images use case not available',
      ));
      return;
    }
    emit(EditChapterLoading(chapterId: chapterId));
    final result = await useCase.call(
      params: DeleteAllChapterImagesParams(
        comicId: comicId,
        chapterId: chapterId,
      ),
    );
    result.fold(
      (message) => emit(EditChapterFailure(message)),
      (_) => emit(EditChapterImagesDeleted(chapterId: chapterId)),
    );
  }
}
