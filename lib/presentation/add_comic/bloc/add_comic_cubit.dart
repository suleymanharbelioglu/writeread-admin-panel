import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic_params.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_state.dart';

class AddComicCubit extends Cubit<AddComicState> {
  AddComicCubit({required AddComicUseCase addComicUseCase})
    : _addComicUseCase = addComicUseCase,
      super(const AddComicInitial());

  final AddComicUseCase _addComicUseCase;

  Future<void> addComic(AddComicParams params) async {
    try {
      print("CUBIT: EMIT LOADING");
      emit(const AddComicLoading());

      print("CUBIT: CALLING USECASE");
      final result = await _addComicUseCase.call(params: params);

      print("CUBIT: USECASE RETURNED");

      result.fold(
        (message) {
          print("CUBIT: EMIT FAILURE -> $message");
          emit(AddComicFailure(message));
        },
        (comic) {
          print("CUBIT: EMIT SUCCESS");
          emit(AddComicSuccess(comic: comic));
        },
      );
    } catch (e, stackTrace) {
      print("CUBIT: UNEXPECTED ERROR -> $e");
      print(stackTrace);
      emit(AddComicFailure('Unexpected error: $e'));
    }
  }
}
