import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_last_chapter_params.dart';

class DeleteLastChapterUseCase
    implements UseCase<Either<String, void>, DeleteLastChapterParams> {
  DeleteLastChapterUseCase(this._chapterRepository);

  final ChapterRepository _chapterRepository;

  @override
  Future<Either<String, void>> call({DeleteLastChapterParams? params}) async {
    if (params == null || params.comicId.isEmpty) {
      return const Left('Comic id is required');
    }
    return _chapterRepository.deleteLastChapter(
      params.comicId,
      locale: params.locale,
    );
  }
}
