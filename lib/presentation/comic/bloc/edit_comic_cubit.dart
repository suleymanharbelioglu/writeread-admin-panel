import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_state.dart';

class EditComicCubit extends Cubit<EditComicState> {
  EditComicCubit({UpdateComicUseCase? updateComicUseCase})
      : _updateComicUseCase = updateComicUseCase,
        super(const EditComicInitial());

  final UpdateComicUseCase? _updateComicUseCase;

  Future<void> updateComic(UpdateComicParams params) async {
    final useCase = _updateComicUseCase;
    if (useCase == null) {
      emit(const EditComicFailure('Update comic use case not available'));
      return;
    }
    emit(const EditComicLoading());
    final result = await useCase.call(params: params);
    result.fold(
      (message) => emit(EditComicFailure(message)),
      (_) => emit(const EditComicSuccess()),
    );
  }
}
