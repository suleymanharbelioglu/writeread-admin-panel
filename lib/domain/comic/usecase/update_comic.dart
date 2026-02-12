import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic_params.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class UpdateComicUseCase implements UseCase<Either<String, void>, UpdateComicParams> {
  @override
  Future<Either<String, void>> call({UpdateComicParams? params}) async {
    if (params == null) return const Left('Update params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.title.trim().isEmpty) return const Left('Title required');
    return sl<ComicRepository>().updateComic(
      params.comicId,
      title: params.title.trim(),
      description: params.description.trim(),
      oldImageFilename: params.oldImageFilename,
      newImageBytes: params.newImageBytes,
    );
  }
}
