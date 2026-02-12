import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class ComicRepositoryImpl extends ComicRepository {
  @override
  Future<Either<String, List<ComicEntity>>> getAllComics() async {
    final result = await sl<ComicFirebaseService>().getAllComics();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, ComicEntity>> addComic(
    String title,
    String description,
    String categoryName, {
    List<int>? imageBytes,
  }) async {
    final result = await sl<ComicFirebaseService>().addComic(
      title,
      description,
      categoryName,
      imageBytes: imageBytes,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, void>> updateComic(
    String comicId, {
    required String title,
    required String description,
    String? oldImageFilename,
    List<int>? newImageBytes,
  }) async {
    return sl<ComicFirebaseService>().updateComic(
      comicId,
      title: title,
      description: description,
      oldImageFilename: oldImageFilename,
      newImageBytes: newImageBytes,
    );
  }

  @override
  Future<Either<String, void>> deleteComic(String comicId) async {
    return sl<ComicFirebaseService>().deleteComic(comicId);
  }
}
