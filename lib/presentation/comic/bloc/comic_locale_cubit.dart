import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_log.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter_params.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_chapter_pages.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_chapter_pages_params.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_cover.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_cover_params.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_locale.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_locale_params.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_locale_metadata.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_locale_metadata_params.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upload_locale_cover.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upload_locale_cover_params.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upsert_locale_chapter.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upsert_locale_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_state.dart';

class ComicLocaleCubit extends Cubit<ComicLocaleState> {
  ComicLocaleCubit({
    required UpdateLocaleMetadataUseCase updateLocaleMetadataUseCase,
    required UpsertLocaleChapterUseCase upsertLocaleChapterUseCase,
    required ClearLocaleChapterPagesUseCase clearLocaleChapterPagesUseCase,
    required DeleteLocaleUseCase deleteLocaleUseCase,
    required UpdateChapterUseCase updateChapterUseCase,
    required UploadLocaleCoverUseCase uploadLocaleCoverUseCase,
    required ClearLocaleCoverUseCase clearLocaleCoverUseCase,
  })  : _updateLocaleMetadataUseCase = updateLocaleMetadataUseCase,
        _upsertLocaleChapterUseCase = upsertLocaleChapterUseCase,
        _clearLocaleChapterPagesUseCase = clearLocaleChapterPagesUseCase,
        _deleteLocaleUseCase = deleteLocaleUseCase,
        _updateChapterUseCase = updateChapterUseCase,
        _uploadLocaleCoverUseCase = uploadLocaleCoverUseCase,
        _clearLocaleCoverUseCase = clearLocaleCoverUseCase,
        super(const ComicLocaleState());

  final UpdateLocaleMetadataUseCase _updateLocaleMetadataUseCase;
  final UpsertLocaleChapterUseCase _upsertLocaleChapterUseCase;
  final ClearLocaleChapterPagesUseCase _clearLocaleChapterPagesUseCase;
  final DeleteLocaleUseCase _deleteLocaleUseCase;
  final UpdateChapterUseCase _updateChapterUseCase;
  final UploadLocaleCoverUseCase _uploadLocaleCoverUseCase;
  final ClearLocaleCoverUseCase _clearLocaleCoverUseCase;

  void selectLocale(String locale) {
    emit(
      state.copyWith(
        selectedLocale: locale,
        hasUnsavedMetadata: false,
        clearStatus: true,
        clearUpdatedComic: true,
        clearChapterExtras: true,
      ),
    );
  }

  /// Called by the locale editor when title/description/category diverge from saved.
  void setMetadataDirty(bool dirty) {
    if (state.hasUnsavedMetadata == dirty) return;
    emit(state.copyWith(hasUnsavedMetadata: dirty));
  }

  Future<void> saveMetadata({
    required String comicId,
    required String title,
    required String description,
    required String categoryName,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    emit(state.copyWith(status: ComicLocaleStatus.loading));
    try {
      final result = await _updateLocaleMetadataUseCase.call(
        params: UpdateLocaleMetadataParams(
          comicId: comicId,
          locale: locale,
          title: title,
          description: description,
          categoryName: categoryName,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('UpdateLocaleMetadata failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (comic) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Locale metadata saved',
            updatedComic: comic,
            hasUnsavedMetadata: false,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.saveMetadata', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while saving locale metadata',
        ),
      );
    }
  }

  Future<void> saveChapterName({
    required ComicEntity comic,
    required String chapterId,
    required String chapterName,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    final existing = comic.locales[locale]?.chapterById(chapterId);
    final overlay = ChapterLocaleContent(
      chapterId: chapterId,
      comicId: existing?.comicId.isNotEmpty == true
          ? existing!.comicId
          : comic.comicId,
      chapterName: chapterName,
      pageCount: existing?.pageCount ?? 0,
      createdDate: existing?.createdDate ?? DateTime.now().toUtc(),
      isFreePreview: existing?.isFreePreview ?? false,
      musicUrl: existing?.musicUrl,
      pagesVersion: existing?.pagesVersion ?? 0,
    );

    emit(
      state.copyWith(status: ComicLocaleStatus.loading, chapterId: chapterId),
    );
    try {
      final result = await _upsertLocaleChapterUseCase.call(
        params: UpsertLocaleChapterParams(
          comicId: comic.comicId,
          locale: locale,
          chapter: overlay,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('UpsertLocaleChapter failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (updated) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Chapter name saved',
            updatedComic: updated,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.saveChapterName', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while saving chapter name',
        ),
      );
    }
  }

  Future<void> uploadPages({
    required String comicId,
    required String chapterId,
    required List<List<int>> imageBytesList,
    String? chapterName,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale) || imageBytesList.isEmpty) return;

    emit(
      state.copyWith(status: ComicLocaleStatus.loading, chapterId: chapterId),
    );
    try {
      final result = await _updateChapterUseCase.call(
        params: UpdateChapterParams(
          comicId: comicId,
          chapterId: chapterId,
          additionalImageBytesList: imageBytesList,
          chapterName: chapterName,
          locale: locale,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('Locale upload pages failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (_) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Pages uploaded',
            chapterId: chapterId,
            addedImageCount: imageBytesList.length,
            chapterName: chapterName,
            operationLocale: locale,
            clearUpdatedComic: true,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.uploadPages', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while uploading pages',
        ),
      );
    }
  }

  Future<void> uploadMusic({
    required String comicId,
    required String chapterId,
    required List<int> musicBytes,
    String? chapterName,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale) || musicBytes.isEmpty) return;

    emit(
      state.copyWith(status: ComicLocaleStatus.loading, chapterId: chapterId),
    );
    try {
      final result = await _updateChapterUseCase.call(
        params: UpdateChapterParams(
          comicId: comicId,
          chapterId: chapterId,
          musicBytes: musicBytes,
          chapterName: chapterName,
          locale: locale,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('Locale upload music failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (musicUrl) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Music uploaded',
            chapterId: chapterId,
            musicUrl: musicUrl,
            chapterName: chapterName,
            operationLocale: locale,
            clearUpdatedComic: true,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.uploadMusic', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while uploading music',
        ),
      );
    }
  }

  Future<void> setFreePreview({
    required ComicEntity comic,
    required String chapterId,
    required bool isFreePreview,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    emit(
      state.copyWith(status: ComicLocaleStatus.loading, chapterId: chapterId),
    );
    try {
      final result = await _updateChapterUseCase.call(
        params: UpdateChapterParams(
          comicId: comic.comicId,
          chapterId: chapterId,
          isFreePreview: isFreePreview,
          locale: locale,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('Locale setFreePreview failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (_) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: isFreePreview
                ? 'Free preview enabled'
                : 'Free preview disabled',
            chapterId: chapterId,
            isFreePreview: isFreePreview,
            operationLocale: locale,
            clearUpdatedComic: true,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.setFreePreview', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while updating free preview',
        ),
      );
    }
  }

  Future<void> clearPages({
    required String comicId,
    required String chapterId,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    emit(
      state.copyWith(status: ComicLocaleStatus.loading, chapterId: chapterId),
    );
    try {
      final result = await _clearLocaleChapterPagesUseCase.call(
        params: ClearLocaleChapterPagesParams(
          comicId: comicId,
          locale: locale,
          chapterId: chapterId,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('ClearLocaleChapterPages failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (comic) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Pages cleared',
            updatedComic: comic,
            chapterId: chapterId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.clearPages', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while clearing pages',
        ),
      );
    }
  }

  Future<void> deleteLocale(String comicId) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    emit(state.copyWith(status: ComicLocaleStatus.loading));
    try {
      final result = await _deleteLocaleUseCase.call(
        params: DeleteLocaleParams(comicId: comicId, locale: locale),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('DeleteLocale failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (comic) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Locale deleted',
            updatedComic: comic,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.deleteLocale', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while deleting locale',
        ),
      );
    }
  }

  Future<void> uploadCover({
    required String comicId,
    required List<int> imageBytes,
  }) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale) || imageBytes.isEmpty) return;

    emit(state.copyWith(status: ComicLocaleStatus.loading));
    try {
      final result = await _uploadLocaleCoverUseCase.call(
        params: UploadLocaleCoverParams(
          comicId: comicId,
          locale: locale,
          imageBytes: imageBytes,
        ),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('UploadLocaleCover failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (comic) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Locale cover uploaded',
            updatedComic: comic,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.uploadCover', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while uploading cover',
        ),
      );
    }
  }

  Future<void> clearCover(String comicId) async {
    final locale = state.selectedLocale;
    if (AppLocales.isEnglish(locale)) return;

    emit(state.copyWith(status: ComicLocaleStatus.loading));
    try {
      final result = await _clearLocaleCoverUseCase.call(
        params: ClearLocaleCoverParams(comicId: comicId, locale: locale),
      );
      if (isClosed) return;
      result.fold(
        (message) {
          AppLog.info('ClearLocaleCover failure: $message');
          emit(
            state.copyWith(
              status: ComicLocaleStatus.failure,
              message: message,
            ),
          );
        },
        (comic) => emit(
          state.copyWith(
            status: ComicLocaleStatus.success,
            message: 'Locale cover removed — English cover will be used',
            updatedComic: comic,
          ),
        ),
      );
    } catch (e, stackTrace) {
      AppLog.error('ComicLocaleCubit.clearCover', e, stackTrace);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ComicLocaleStatus.failure,
          message: 'Unexpected error while clearing cover',
        ),
      );
    }
  }
}
