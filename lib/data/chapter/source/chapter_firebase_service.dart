import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';

abstract class ChapterFirebaseService {
  Future<Either<String, void>> deleteLastChapter(
    String comicId, {
    String locale = AppLocales.english,
  });

  /// Adds a chapter. English → root `chapters`. Other → `locales.{locale}.chapters`.
  Future<Either<String, ChapterModel>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
    String locale = AppLocales.english,
  });

  /// Updates a chapter. When [locale] is English, updates root chapter fields.
  /// When non-English, uploads to locale Storage paths and updates
  /// `locales.{locale}.chapters`.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
    String locale = AppLocales.english,
  });

  /// Deletes all page images (and music) for a chapter.
  /// English: root Storage folder + root pageCount 0.
  /// Other: locale Storage folder + locales.{locale} pageCount 0.
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  });

  /// Deletes Storage for one chapter in one locale only.
  Future<Either<String, void>> deleteChapterStorageFolder(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  });
}
