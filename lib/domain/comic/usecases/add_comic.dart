import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/add_comic_params.dart';

class AddComicUseCase
    implements UseCase<Either<String, ComicEntity>, AddComicParams> {
  AddComicUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, ComicEntity>> call({AddComicParams? params}) async {
    if (params == null) return const Left('Add comic params required');
    if (params.title.trim().isEmpty) return const Left('Title is required');
    if (params.productId.trim().isEmpty) {
      return const Left('Store Product ID is required');
    }
    return _comicRepository.addComic(
      params.title.trim(),
      params.description.trim(),
      params.categoryName.trim(),
      isSensitive: params.isSensitive,
      contentType: ComicContentType.parse(params.contentType),
      isFree: params.isFree,
      productId: params.productId.trim(),
      imageBytes: params.imageBytes,
    );
  }
}
