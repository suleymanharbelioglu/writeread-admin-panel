import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';

class ChapterRepositoryImpl extends ChapterRepository {
  ChapterRepositoryImpl(this._chapterFirebaseService);

  final ChapterFirebaseService _chapterFirebaseService;

  @override
  Future<Either<String, void>> deleteLastChapter(
    String comicId, {
    String locale = AppLocales.english,
  }) {
    return _chapterFirebaseService.deleteLastChapter(comicId, locale: locale);
  }

  @override
  Future<Either<String, ChapterEntity>> addChapter(
    String comicId,
    String chapterName,
    List<List<int>> imageBytesList, {
    List<int>? musicBytes,
    bool isFreePreview = false,
    String locale = AppLocales.english,
  }) async {
    final result = await _chapterFirebaseService.addChapter(
      comicId,
      chapterName,
      imageBytesList,
      musicBytes: musicBytes,
      isFreePreview: isFreePreview,
      locale: locale,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<String, String?>> updateChapter(
    String comicId,
    String chapterId, {
    bool? isFreePreview,
    List<List<int>>? additionalImageBytesList,
    List<int>? musicBytes,
    String? chapterName,
    String locale = AppLocales.english,
  }) {
    return _chapterFirebaseService.updateChapter(
      comicId,
      chapterId,
      isFreePreview: isFreePreview,
      additionalImageBytesList: additionalImageBytesList,
      musicBytes: musicBytes,
      chapterName: chapterName,
      locale: locale,
    );
  }

  @override
  Future<Either<String, void>> deleteAllChapterImages(
    String comicId,
    String chapterId, {
    String locale = AppLocales.english,
  }) {
    return _chapterFirebaseService.deleteAllChapterImages(
      comicId,
      chapterId,
      locale: locale,
    );
  }
}
