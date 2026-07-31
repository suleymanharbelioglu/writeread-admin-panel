import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_state.dart';

class EditComicCubit extends Cubit<EditComicState> {
  EditComicCubit({required UpdateComicUseCase updateComicUseCase})
      : _updateComicUseCase = updateComicUseCase,
        super(const EditComicInitial());

  final UpdateComicUseCase _updateComicUseCase;

  Future<void> updateComic(UpdateComicParams params) async {
    emit(const EditComicLoading());
    try {
      final result = await _updateComicUseCase.call(params: params);
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('UpdateComic failure: $message');
          emit(EditComicFailure(message));
        },
        (comic) => emit(EditComicSuccess(comic: comic)),
      );
    } catch (e, stackTrace) {
      AppLog.error('EditComicCubit.updateComic', e, stackTrace);
      if (isClosed) return;
      emit(
        const EditComicFailure(
          'Unexpected error while updating the comic',
        ),
      );
    }
  }
}
