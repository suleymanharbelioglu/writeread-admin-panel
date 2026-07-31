import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_all_chapter_images_params.dart';

class DeleteAllChapterImagesUseCase
    implements UseCase<Either<String, void>, DeleteAllChapterImagesParams> {
  DeleteAllChapterImagesUseCase(this._chapterRepository);

  final ChapterRepository _chapterRepository;

  @override
  Future<Either<String, void>> call({
    DeleteAllChapterImagesParams? params,
  }) async {
    if (params == null) return const Left('Params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapterId.isEmpty) return const Left('Chapter id required');
    return _chapterRepository.deleteAllChapterImages(
      params.comicId,
      params.chapterId,
    );
  }
}
