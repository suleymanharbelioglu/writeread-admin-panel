import 'package:dartz/dartz.dart';

abstract class ChapterRepository {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  Future<Either<String, void>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
  });

  Future<Either<String, void>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
  });

  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
