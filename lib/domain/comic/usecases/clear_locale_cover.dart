import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_cover_params.dart';

class ClearLocaleCoverUseCase
    implements UseCase<Either<String, ComicEntity>, ClearLocaleCoverParams> {
  ClearLocaleCoverUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, ComicEntity>> call({
    ClearLocaleCoverParams? params,
  }) async {
    if (params == null) return const Left('Clear locale cover params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (!AppLocales.isSupported(params.locale) ||
        AppLocales.isEnglish(params.locale)) {
      return const Left('Invalid content locale');
    }
    return _comicRepository.clearLocaleCover(params.comicId, params.locale);
  }
}
