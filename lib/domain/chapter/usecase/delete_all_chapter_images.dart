import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_all_chapter_images_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class DeleteAllChapterImagesUseCase
    implements UseCase<Either<String, void>, DeleteAllChapterImagesParams> {
  @override
  Future<Either<String, void>> call(
      {DeleteAllChapterImagesParams? params}) async {
    if (params == null) return const Left('Params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapterId.isEmpty) return const Left('Chapter id required');
    return sl<ChapterRepository>().deleteAllChapterImages(
      params.comicId,
      params.chapterId,
    );
  }
}
