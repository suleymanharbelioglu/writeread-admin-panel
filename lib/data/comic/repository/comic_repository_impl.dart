import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';

class ComicRepositoryImpl extends ComicRepository {
  ComicRepositoryImpl(this._comicFirebaseService);

  final ComicFirebaseService _comicFirebaseService;

  @override
  Future<Either<String, List<ComicEntity>>> getAllComics() async {
    final result = await _comicFirebaseService.getAllComics();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, ComicEntity>> addComic(
    String title,
    String description,
    String categoryName, {
    required bool isSensitive,
    required String contentType,
    required bool isFree,
    required String productId,
    List<int>? imageBytes,
  }) async {
    final result = await _comicFirebaseService.addComic(
      title,
      description,
      categoryName,
      isSensitive: isSensitive,
      contentType: contentType,
      isFree: isFree,
      productId: productId,
      imageBytes: imageBytes,
    );
    return result.map((model) => model.toEntity());
  }

  @override
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
  }) async {
    final result = await _comicFirebaseService.updateComic(
      comicId,
      title: title,
      description: description,
      isSensitive: isSensitive,
      contentType: contentType,
      isFree: isFree,
      productId: productId,
      oldImageFilename: oldImageFilename,
      newImageBytes: newImageBytes,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, void>> deleteComic(String comicId) {
    return _comicFirebaseService.deleteComic(comicId);
  }

  @override
  Future<Either<String, ComicEntity>> updateLocaleMetadata(
    String comicId,
    String locale, {
    required String title,
    required String description,
    required String categoryName,
  }) async {
    final result = await _comicFirebaseService.updateLocaleMetadata(
      comicId,
      locale,
      title: title,
      description: description,
      categoryName: categoryName,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, ComicEntity>> upsertLocaleChapter(
    String comicId,
    String locale,
    ChapterLocaleContent chapter,
  ) async {
    final result = await _comicFirebaseService.upsertLocaleChapter(
      comicId,
      locale,
      chapter,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, ComicEntity>> clearLocaleChapterPages(
    String comicId,
    String locale,
    String chapterId,
  ) async {
    final result = await _comicFirebaseService.clearLocaleChapterPages(
      comicId,
      locale,
      chapterId,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, ComicEntity>> deleteLocale(
    String comicId,
    String locale,
  ) async {
    final result = await _comicFirebaseService.deleteLocale(comicId, locale);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, ComicEntity>> uploadLocaleCover(
    String comicId,
    String locale,
    List<int> imageBytes,
  ) async {
    final result = await _comicFirebaseService.uploadLocaleCover(
      comicId,
      locale,
      imageBytes,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, ComicEntity>> clearLocaleCover(
    String comicId,
    String locale,
  ) async {
    final result = await _comicFirebaseService.clearLocaleCover(
      comicId,
      locale,
    );
    return result.map((model) => model.toEntity());
  }
}
