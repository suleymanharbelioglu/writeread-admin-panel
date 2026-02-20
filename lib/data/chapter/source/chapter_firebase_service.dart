import 'package:dartz/dartz.dart';

abstract class ChapterFirebaseService {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  /// Adds a new chapter to the comic: uploads images to Storage and appends chapter to Firestore.
  /// Returns the new chapter's musicUrl when music was uploaded, otherwise null.
  Future<Either<String, String?>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isVip = true,
    List<int>? musicBytes,
  });

  /// Updates an existing chapter: [isVip] toggles VIP; [additionalImageBytesList]
  /// appends images; [musicBytes] replaces chapter music (old file deleted).
  /// Returns the new musicUrl when music was updated, otherwise null.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isVip,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
  });

  /// Deletes all images in Storage under Comics/{comicId}/{chapterId}/
  /// and sets that chapter's pageCount to 0 in Firestore. VIP status is unchanged.
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
