import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';

abstract class ChapterFirebaseService {
  Future<Either<String, void>> deleteLastChapter(String comicId);

  /// Adds a new chapter to the comic: uploads images to Storage and appends chapter to Firestore.
  Future<Either<String, ChapterModel>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
  });

  /// Updates an existing chapter: [isFreePreview] toggles free preview for paid comics;
  /// [additionalImageBytesList] appends images; [musicBytes] replaces chapter music.
  /// Returns the new musicUrl when music was updated, otherwise null.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
  });

  /// Deletes all images in Storage under Comics/{comicId}/{chapterId}/
  /// and sets that chapter's pageCount to 0 in Firestore.
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId,
  );
}
