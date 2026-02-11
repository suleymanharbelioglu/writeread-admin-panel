import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/get_all_comics.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_state.dart';

class ComicsCubit extends Cubit<ComicsState> {
  ComicsCubit({required GetAllComicsUseCase getAllComicsUseCase})
      : _getAllComicsUseCase = getAllComicsUseCase,
        super(const ComicsInitial());

  final GetAllComicsUseCase _getAllComicsUseCase;

  Future<void> loadComics() async {
    emit(const ComicsLoading());
    final result = await _getAllComicsUseCase.call();
    result.fold(
      (message) => emit(ComicsError(message: message)),
      (comics) => emit(ComicsSuccess(comics: comics)),
    );
  }
}
