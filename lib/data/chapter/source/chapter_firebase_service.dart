import 'package:dartz/dartz.dart';

abstract class ChapterFirebaseService {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  /// Adds a new chapter to the comic: uploads images to Storage and appends chapter to Firestore.
  /// [imageBytesList] – page images in order (e.g. 1.jpeg, 2.jpeg).
  Future<Either<String, void>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
  });

  /// Updates an existing chapter: [isVip] toggles VIP; [additionalImageBytesList]
  /// appends images to Storage and increases pageCount.
  Future<Either<String, void>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
  });

  /// Deletes all images in Storage under Comics/{comicId}/{chapterId}/
  /// and sets that chapter's pageCount to 0 in Firestore. VIP status is unchanged.
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
