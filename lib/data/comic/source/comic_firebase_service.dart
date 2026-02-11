import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comic/model/comic_model.dart';

abstract class ComicFirebaseService {
  Future<Either<String, List<ComicModel>>> getAllComics();
}
