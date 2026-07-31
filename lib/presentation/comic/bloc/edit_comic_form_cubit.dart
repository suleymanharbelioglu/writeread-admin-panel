import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_form_state.dart';

/// Holds comic edit-form UI fields; persists via [EditComicCubit].
class EditComicFormCubit extends Cubit<EditComicFormState> {
  EditComicFormCubit({required EditComicCubit editComicCubit})
      : _editComicCubit = editComicCubit,
        super(const EditComicFormState());

  final EditComicCubit _editComicCubit;

  void startEdit(ComicEntity comic) {
    emit(
      EditComicFormState(
        isEditing: true,
        isFree: comic.isFree,
        isSensitive: comic.isSensitive,
      ),
    );
  }

  void cancel(ComicEntity comic) {
    emit(
      EditComicFormState(
        isEditing: false,
        isFree: comic.isFree,
        isSensitive: comic.isSensitive,
      ),
    );
  }

  void resetFromComic(ComicEntity comic) {
    emit(
      EditComicFormState(
        isEditing: false,
        isFree: comic.isFree,
        isSensitive: comic.isSensitive,
      ),
    );
  }

  void setFree(bool value) {
    emit(state.copyWith(isFree: value, clearValidation: true));
  }

  void setSensitive(bool value) {
    emit(state.copyWith(isSensitive: value, clearValidation: true));
  }

  void setImageBytes(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) {
      emit(state.copyWith(clearImage: true, clearValidation: true));
      return;
    }
    emit(state.copyWith(newImageBytes: bytes, clearValidation: true));
  }

  void save({
    required ComicEntity comic,
    required String title,
    required String description,
    required String productId,
  }) {
    emit(state.copyWith(clearValidation: true));
    _editComicCubit.updateComic(
      UpdateComicParams(
        comicId: comic.comicId,
        title: title.trim(),
        description: description.trim(),
        isSensitive: state.isSensitive,
        isFree: state.isFree,
        productId: productId.trim(),
        oldImageFilename: comic.image.isNotEmpty ? comic.image : null,
        newImageBytes: state.newImageBytes,
      ),
    );
  }

  /// Applies persisted comic from UseCase result to [CurrentComicCubit].
  void applyPersistSuccess({
    required CurrentComicCubit currentComic,
    required ComicEntity updatedComic,
  }) {
    currentComic.setComic(updatedComic);
    emit(
      EditComicFormState(
        isEditing: false,
        isFree: updatedComic.isFree,
        isSensitive: updatedComic.isSensitive,
      ),
    );
  }
}
