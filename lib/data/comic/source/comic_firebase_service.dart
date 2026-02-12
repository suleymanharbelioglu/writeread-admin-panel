import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';

abstract class ComicFirebaseService {
  Future<Either<String, List<ComicModel>>> getAllComics();

  /// Creates a new comic: Firestore doc (auto ID), optional cover at Comics/{comicId}_cover.jpg, chapters [].
  Future<Either<String, ComicModel>> addComic(
    String title,
    String description,
    String categoryName, {
    List<int>? imageBytes,
  });

  /// Updates comic title, description, and optionally replaces cover image.
  /// If [newImageBytes] is not null: deletes Storage Comics/[oldImageFilename],
  /// uploads new image to Comics/[comicId]_cover.jpg, updates Firestore image field.
  Future<Either<String, void>> updateComic(
    String comicId, {
    required String title,
    required String description,
    String? oldImageFilename,
    List<int>? newImageBytes,
  });

  /// Deletes the comic: Firestore document and all Storage (cover + chapter folders).
  Future<Either<String, void>> deleteComic(String comicId);
}
