import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

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
}
