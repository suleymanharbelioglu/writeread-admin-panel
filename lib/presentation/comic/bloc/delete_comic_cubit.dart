import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/delete_comic.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_state.dart';

class DeleteComicCubit extends Cubit<DeleteComicState> {
  DeleteComicCubit({DeleteComicUseCase? deleteComicUseCase})
      : _deleteComicUseCase = deleteComicUseCase,
        super(const DeleteComicInitial());

  final DeleteComicUseCase? _deleteComicUseCase;

  Future<void> deleteComic(String comicId) async {
    final useCase = _deleteComicUseCase;
    if (useCase == null) {
      emit(const DeleteComicFailure('Delete comic use case not available'));
      return;
    }
    emit(const DeleteComicLoading());
    final result = await useCase.call(params: comicId);
    result.fold(
      (message) => emit(DeleteComicFailure(message)),
      (_) => emit(const DeleteComicSuccess()),
    );
  }
}
