import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_locale_metadata_params.dart';

class UpdateLocaleMetadataUseCase
    implements UseCase<Either<String, ComicEntity>, UpdateLocaleMetadataParams> {
  UpdateLocaleMetadataUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, ComicEntity>> call({
    UpdateLocaleMetadataParams? params,
  }) async {
    if (params == null) return const Left('Locale metadata params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (!AppLocales.isSupported(params.locale) ||
        AppLocales.isEnglish(params.locale)) {
      return const Left('Invalid content locale');
    }
    return _comicRepository.updateLocaleMetadata(
      params.comicId,
      params.locale,
      title: params.title,
      description: params.description,
      categoryName: params.categoryName,
    );
  }
}
