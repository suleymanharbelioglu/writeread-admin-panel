import 'package:dartz/dartz.dart';

abstract class ChapterRepository {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  /// Returns the new chapter's musicUrl when music was uploaded, otherwise null.
  Future<Either<String, String?>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
    List<int>? musicBytes,
  });

  /// Returns new musicUrl when music was updated, otherwise null.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
  });

  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
