import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

abstract class ComicRepository {
  Future<Either<String, List<ComicEntity>>> getAllComics();
}
