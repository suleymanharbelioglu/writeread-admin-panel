import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class AddChapterUseCase implements UseCase<Either<String, void>, AddChapterParams> {
  @override
  Future<Either<String, void>> call({AddChapterParams? params}) async {
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
    return sl<ChapterRepository>().addChapter(
      params.comicId,
      params.chapterName.trim(),
      params.imageBytesList,
      isVip: params.isVip,
    );
  }
}
