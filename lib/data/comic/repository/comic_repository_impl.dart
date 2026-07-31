import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
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
    required bool isFree,
    required String productId,
    List<int>? imageBytes,
  }) async {
    final result = await _comicFirebaseService.addComic(
      title,
      description,
      categoryName,
      isSensitive: isSensitive,
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
}
