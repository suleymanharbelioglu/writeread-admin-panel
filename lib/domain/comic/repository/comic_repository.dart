import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

abstract class ComicRepository {
  Future<Either<String, List<ComicEntity>>> getAllComics();

  Future<Either<String, ComicEntity>> addComic(
    String title,
    String description,
    String categoryName, {
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    List<int>? imageBytes,
  });

  Future<Either<String, ComicEntity>> updateComic(
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

  Future<Either<String, void>> deleteComic(String comicId);

  Future<Either<String, ComicEntity>> updateLocaleMetadata(
    String comicId,
    String locale, {
    required String title,
    required String description,
    required String categoryName,
  });

  Future<Either<String, ComicEntity>> upsertLocaleChapter(
    String comicId,
    String locale,
    ChapterLocaleContent chapter,
  );

  Future<Either<String, ComicEntity>> clearLocaleChapterPages(
    String comicId,
    String locale,
    String chapterId,
  );

  Future<Either<String, ComicEntity>> deleteLocale(
    String comicId,
    String locale,
  );

  Future<Either<String, ComicEntity>> uploadLocaleCover(
    String comicId,
    String locale,
    List<int> imageBytes,
  );

  Future<Either<String, ComicEntity>> clearLocaleCover(
    String comicId,
    String locale,
  );
}
