import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upsert_locale_chapter_params.dart';

class UpsertLocaleChapterUseCase
    implements UseCase<Either<String, ComicEntity>, UpsertLocaleChapterParams> {
  UpsertLocaleChapterUseCase(this._comicRepository);

  final ComicRepository _comicRepository;

  @override
  Future<Either<String, ComicEntity>> call({
    UpsertLocaleChapterParams? params,
  }) async {
    if (params == null) return const Left('Upsert locale chapter params required');
    if (params.comicId.isEmpty) return const Left('Comic id required');
    if (params.chapter.chapterId.isEmpty) {
      return const Left('Chapter id required');
    }
    if (!AppLocales.isSupported(params.locale) ||
        AppLocales.isEnglish(params.locale)) {
      return const Left('Invalid content locale');
    }
    return _comicRepository.upsertLocaleChapter(
      params.comicId,
      params.locale,
      params.chapter,
    );
  }
}
