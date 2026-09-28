import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

abstract class ComicFirebaseService {
  Future<Either<String, List<ComicModel>>> getAllComics();

  /// Creates a new comic (doc ID from title), optional cover at Comics/{comicId}_cover_{version}.jpg, chapters [].
  Future<Either<String, ComicModel>> addComic(
    String title,
    String description,
    String categoryName, {
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    List<int>? imageBytes,
  });

  /// Updates comic title, description, free/paid flag, store product ID, and optionally replaces cover image.
  /// If [newImageBytes] is not null: uploads Comics/[comicId]_cover_{version}.jpg,
  /// updates Firestore image field, then deletes the previous cover file.
  Future<Either<String, ComicModel>> updateComic(
    String comicId, {
    required String title,
    required String description,
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    String? oldImageFilename,
    List<int>? newImageBytes,
  });

  /// Deletes the comic: Firestore document and all Storage (cover + chapter folders).
  /// Locale subfolders under Comics/{comicId}/ are wiped recursively.
  Future<Either<String, void>> deleteComic(String comicId);

  /// Creates or updates `locales.{locale}` metadata (title, description, categoryName).
  /// Preserves existing chapters array when present.
  Future<Either<String, ComicModel>> updateLocaleMetadata(
    String comicId,
    String locale, {
    required String title,
    required String description,
    required String categoryName,
  });

  /// Upserts a chapter overlay under `locales.{locale}.chapters`.
  Future<Either<String, ComicModel>> upsertLocaleChapter(
    String comicId,
    String locale,
    ChapterLocaleContent chapter,
  );

  /// Deletes locale chapter Storage folder and sets pageCount to 0 (clears musicUrl).
  Future<Either<String, ComicModel>> clearLocaleChapterPages(
    String comicId,
    String locale,
    String chapterId,
  );

  /// Deletes Storage Comics/{comicId}/{locale}/ and FieldValue.delete on locales.{locale}.
  Future<Either<String, ComicModel>> deleteLocale(
    String comicId,
    String locale,
  );

  /// Uploads locale cover to Comics/{comicId}/{locale}/cover_{version}.jpg and sets locales.{locale}.image.
  Future<Either<String, ComicModel>> uploadLocaleCover(
    String comicId,
    String locale,
    List<int> imageBytes,
  );

  /// Deletes locale cover file and clears locales.{locale}.image (EN cover unchanged).
  Future<Either<String, ComicModel>> clearLocaleCover(
    String comicId,
    String locale,
  );
}
