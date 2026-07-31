import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_comic.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_state.dart';

class DeleteComicCubit extends Cubit<DeleteComicState> {
  DeleteComicCubit({required DeleteComicUseCase deleteComicUseCase})
      : _deleteComicUseCase = deleteComicUseCase,
        super(const DeleteComicInitial());

  final DeleteComicUseCase _deleteComicUseCase;

  Future<void> deleteComic(String comicId) async {
    emit(const DeleteComicLoading());
    try {
      final result = await _deleteComicUseCase.call(params: comicId);
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('DeleteComic failure: $message');
          emit(DeleteComicFailure(message));
        },
        (_) => emit(const DeleteComicSuccess()),
      );
    } catch (e, stackTrace) {
      AppLog.error('DeleteComicCubit.deleteComic', e, stackTrace);
      if (isClosed) return;
      emit(
        const DeleteComicFailure(
          'Unexpected error while deleting the comic',
        ),
      );
    }
  }
}
