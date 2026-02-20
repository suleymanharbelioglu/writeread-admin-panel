import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';

class AddChapterCubit extends Cubit<AddChapterState> {
  AddChapterCubit({AddChapterUseCase? addChapterUseCase})
      : _addChapterUseCase = addChapterUseCase,
        super(const AddChapterInitial());

  final AddChapterUseCase? _addChapterUseCase;

  Future<void> addChapter(AddChapterParams params) async {
    final useCase = _addChapterUseCase;
    if (useCase == null) {
      emit(const AddChapterFailure('Add chapter use case not available'));
      return;
    }
    emit(const AddChapterLoading());
    final result = await useCase.call(params: params);
    result.fold(
      (message) => emit(AddChapterFailure(message)),
      (musicUrl) => emit(AddChapterSuccess(
            chapterName: params.chapterName.trim(),
            pageCount: params.imageBytesList.length,
            isVip: params.isVip,
            musicUrl: musicUrl,
          )),
    );
  }
}
