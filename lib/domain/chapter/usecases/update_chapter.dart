import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter_params.dart';

class UpdateChapterUseCase
    implements UseCase<Either<String, String?>, UpdateChapterParams> {
  UpdateChapterUseCase(this._chapterRepository);

  final ChapterRepository _chapterRepository;

  @override
  Future<Either<String, String?>> call({UpdateChapterParams? params}) async {
    if (params == null) return const Left('Update chapter params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapterId.isEmpty) return const Left('Chapter id required');
    final hasImages = params.additionalImageBytesList != null &&
        params.additionalImageBytesList!.isNotEmpty;
    final hasMusic = params.musicBytes != null && params.musicBytes!.isNotEmpty;
    if (!hasImages && !hasMusic && params.isFreePreview == null) {
      return const Left(
        'Provide free preview setting, additional images, and/or music',
      );
    }
    return _chapterRepository.updateChapter(
      params.comicId,
      params.chapterId,
      isFreePreview: params.isFreePreview,
      additionalImageBytesList: params.additionalImageBytesList,
      musicBytes: params.musicBytes,
    );
  }
}
