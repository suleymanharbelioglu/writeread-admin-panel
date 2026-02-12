import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

abstract class ComicRepository {
  Future<Either<String, List<ComicEntity>>> getAllComics();

  Future<Either<String, ComicEntity>> addComic(
    String title,
    String description,
    String categoryName, {
    List<int>? imageBytes,
  });

  Future<Either<String, void>> updateComic(
    String comicId, {
    required String title,
    required String description,
    String? oldImageFilename,
    List<int>? newImageBytes,
  });

  Future<Either<String, void>> deleteComic(String comicId);
}
