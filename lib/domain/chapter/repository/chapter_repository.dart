import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

abstract class ChapterRepository {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  /// Returns the created [ChapterEntity] (id assigned in data layer).
  Future<Either<String, ChapterEntity>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
  });

  /// Returns new musicUrl when music was updated, otherwise null.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
  });

  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
