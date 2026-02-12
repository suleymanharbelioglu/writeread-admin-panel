import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class AddComicUseCase implements UseCase<Either<String, ComicEntity>, AddComicParams> {
  @override
  Future<Either<String, ComicEntity>> call({AddComicParams? params}) async {
    if (params == null) return const Left('Add comic params required');
    if (params.title.trim().isEmpty) return const Left('Title is required');
    return sl<ComicRepository>().addComic(
      params.title.trim(),
      params.description.trim(),
      params.categoryName.trim(),
      imageBytes: params.imageBytes,
    );
  }
}
