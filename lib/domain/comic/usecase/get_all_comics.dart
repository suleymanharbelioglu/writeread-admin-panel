import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class GetAllComicsUseCase implements UseCase<Either<String, List<ComicEntity>>, dynamic> {
  @override
  Future<Either<String, List<ComicEntity>>> call({dynamic params}) async {
    return sl<ComicRepository>().getAllComics();
  }
}
