import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';

class DeleteComicUseCase implements UseCase<Either<String, void>, String> {
  DeleteComicUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, void>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return const Left('Comic id required');
    }
    return _comicRepository.deleteComic(params);
  }
}
