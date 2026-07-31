import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/get_all_comics.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_state.dart';

class ComicsCubit extends Cubit<ComicsState> {
  ComicsCubit({required GetAllComicsUseCase getAllComicsUseCase})
      : _getAllComicsUseCase = getAllComicsUseCase,
        super(const ComicsInitial());

  final GetAllComicsUseCase _getAllComicsUseCase;

  Future<void> loadComics() async {
    emit(const ComicsLoading());
    try {
      final result = await _getAllComicsUseCase.call();
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('LoadComics failure: $message');
          emit(ComicsError(message: message));
        },
        (comics) => emit(ComicsSuccess(comics: comics)),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicsCubit.loadComics', e, stackTrace);
      if (isClosed) return;
      emit(
        const ComicsError(
          message: 'Unexpected error while loading comics',
        ),
      );
    }
  }
}
