import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic_params.dart';

class UpdateComicUseCase
    implements UseCase<Either<String, ComicEntity>, UpdateComicParams> {
  UpdateComicUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, ComicEntity>> call({UpdateComicParams? params}) async {
    if (params == null) return const Left('Update params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.title.trim().isEmpty) return const Left('Title required');
    if (params.productId.trim().isEmpty) {
      return const Left('Store Product ID is required');
    }
    return _comicRepository.updateComic(
      params.comicId,
      title: params.title.trim(),
      description: params.description.trim(),
      isSensitive: params.isSensitive,
      contentType: ComicContentType.parse(params.contentType),
      isFree: params.isFree,
      productId: params.productId.trim(),
      oldImageFilename: params.oldImageFilename,
      newImageBytes: params.newImageBytes,
    );
  }
}
