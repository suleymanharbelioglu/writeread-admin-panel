import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

abstract class ChapterRepository {
  /// Deletes the last chapter for [locale].
  /// English: root `chapters` + EN storage only.
  /// Other: `locales.{locale}.chapters` + that locale's storage only.
  Future<Either<String, void>> deleteLastChapter(
    String comicId, {
    String locale = AppLocales.english,
  });

  /// Returns the created [ChapterEntity] (id assigned in data layer).
  /// English → root `chapters`. Other locales → `locales.{locale}.chapters`.
  Future<Either<String, ChapterEntity>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    bool isFreePreview = false,
    List<int>? musicBytes,
    String locale = AppLocales.english,
  });

  /// Returns new musicUrl when music was updated, otherwise null.
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
    String locale = AppLocales.english,
  });

  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  });
}
