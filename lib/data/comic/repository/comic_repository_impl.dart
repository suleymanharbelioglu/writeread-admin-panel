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
}
