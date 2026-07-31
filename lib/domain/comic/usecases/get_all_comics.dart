import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';

class GetAllComicsUseCase
    implements UseCase<Either<String, List<ComicEntity>>, void> {
  GetAllComicsUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, List<ComicEntity>>> call({void params}) {
    return _comicRepository.getAllComics();
  }
}
