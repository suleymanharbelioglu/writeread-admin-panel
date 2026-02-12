import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class ChapterRepositoryImpl extends ChapterRepository {
  @override
  Future<Either<String, void>> deleteLastChapter(String comicId) async {
    return sl<ChapterFirebaseService>().deleteLastChapter(comicId);
  }

  @override
  Future<Either<String, void>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
  }) async {
    return sl<ChapterFirebaseService>().addChapter(
      comicId,
      chapterName,
      imageBytesList,
      isVip: isVip,
    );
  }

  @override
  Future<Either<String, void>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
  }) async {
    return sl<ChapterFirebaseService>().updateChapter(
      comicId,
      chapterId,
      isVip: isVip,
      additionalImageBytesList: additionalImageBytesList,
    );
  }

  @override
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  ) async {
    return sl<ChapterFirebaseService>().deleteAllChapterImages(
      comicId,
      chapterId,
    );
  }
}
