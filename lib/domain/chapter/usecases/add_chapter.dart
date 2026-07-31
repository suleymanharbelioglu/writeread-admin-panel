import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/add_chapter_params.dart';

class AddChapterUseCase
    implements UseCase<Either<String, ChapterEntity>, AddChapterParams> {
  AddChapterUseCase(this._chapterRepository);

  final ChapterRepository _chapterRepository;

  @override
  Future<Either<String, ChapterEntity>> call({AddChapterParams? params}) async {
    if (params == null) {
      return const Left('Add chapter params required');
    }
    if (params.comicId.isEmpty) {
      return const Left('Comic id is required');
    }
    if (params.chapterName.trim().isEmpty) {
      return const Left('Chapter name is required');
    }
    if (params.imageBytesList.isEmpty) {
      return const Left('Add at least one image');
    }
    return _chapterRepository.addChapter(
      params.comicId,
      params.chapterName.trim(),
      params.imageBytesList,
      musicBytes: params.musicBytes,
      isFreePreview: params.isFreePreview,
    );
  }
}
