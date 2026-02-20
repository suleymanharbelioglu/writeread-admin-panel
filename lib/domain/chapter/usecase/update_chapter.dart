import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class UpdateChapterUseCase
    implements UseCase<Either<String, String?>, UpdateChapterParams> {
  @override
  Future<Either<String, String?>> call({UpdateChapterParams? params}) async {
    if (params == null) return const Left('Update chapter params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapterId.isEmpty) return const Left('Chapter id required');
    final hasImages = params.additionalImageBytesList != null &&
        params.additionalImageBytesList!.isNotEmpty;
    final hasMusic = params.musicBytes != null && params.musicBytes!.isNotEmpty;
    if (params.isVip == null && !hasImages && !hasMusic) {
      return const Left('Provide isVip, additional images, and/or music');
    }
    return sl<ChapterRepository>().updateChapter(
      params.comicId,
      params.chapterId,
      isVip: params.isVip,
      additionalImageBytesList: params.additionalImageBytesList,
      musicBytes: params.musicBytes,
    );
  }
}
