import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/add_comic_params.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_state.dart';

class AddComicCubit extends Cubit<AddComicState> {
  AddComicCubit({required AddComicUseCase addComicUseCase})
      : _addComicUseCase = addComicUseCase,
        super(const AddComicState());

  final AddComicUseCase _addComicUseCase;

  void setContentType(String value) {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        contentType: ComicContentType.parse(value),
        clearError: true,
      ),
    );
  }

  void setFree(bool value) {
    if (state.isLoading) return;
    emit(state.copyWith(isFree: value, clearError: true));
  }

  void setSensitive(bool value) {
    if (state.isLoading) return;
    emit(state.copyWith(isSensitive: value, clearError: true));
  }

  void setImageBytes(List<int>? bytes) {
    if (state.isLoading) return;
    if (bytes == null || bytes.isEmpty) {
      emit(state.copyWith(clearImage: true, clearError: true));
      return;
    }
    emit(state.copyWith(imageBytes: bytes, clearError: true));
  }

  Future<void> submit({
    required String title,
    required String description,
    required String categoryName,
    required String productId,
  }) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: AddComicStatus.loading,
        clearError: true,
        clearComic: true,
      ),
    );

    try {
      final result = await _addComicUseCase.call(
        params: AddComicParams(
          title: title.trim(),
          description: description.trim(),
          categoryName: categoryName.trim(),
          isSensitive: state.isSensitive,
          contentType: state.contentType,
          isFree: state.isFree,
          productId: productId.trim(),
          imageBytes: state.imageBytes,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('AddComic failure: $message');
          emit(
            state.copyWith(
              status: AddComicStatus.failure,
              errorMessage: message,
            ),
          );
        },
        (comic) {
          AppLog.info('AddComic success: ${comic.comicId}');
          emit(
            state.copyWith(
              status: AddComicStatus.success,
              comic: comic,
              clearError: true,
            ),
          );
          AppLog.info('AddComic emit done, status=${state.status}');
        },
      );
    } catch (e, stackTrace) {
      AppLog.error('AddComicCubit.submit', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AddComicStatus.failure,
          errorMessage: 'Unexpected error while adding the comic',
        ),
      );
    }
  }
}
