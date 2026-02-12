import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class UpdateChapterUseCase
    implements UseCase<Either<String, void>, UpdateChapterParams> {
  @override
  Future<Either<String, void>> call({UpdateChapterParams? params}) async {
    if (params == null) return const Left('Update chapter params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapterId.isEmpty) return const Left('Chapter id required');
    if (params.isVip == null &&
        (params.additionalImageBytesList == null ||
            params.additionalImageBytesList!.isEmpty)) {
      return const Left('Provide isVip and/or additional images');
    }
    return sl<ChapterRepository>().updateChapter(
      params.comicId,
      params.chapterId,
      isVip: params.isVip,
      additionalImageBytesList: params.additionalImageBytesList,
    );
  }
}
