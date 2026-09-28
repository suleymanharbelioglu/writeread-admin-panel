import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

enum ComicLocaleStatus { idle, loading, success, failure }

class ComicLocaleState {
  const ComicLocaleState({
    this.selectedLocale = AppLocales.english,
    this.status = ComicLocaleStatus.idle,
    this.message,
    this.updatedComic,
    this.chapterId,
    this.addedImageCount,
    this.musicUrl,
    this.chapterName,
    this.isFreePreview,
    /// Locale the in-flight/last success operation targeted (may differ from tab).
    this.operationLocale,
    this.hasUnsavedMetadata = false,
  });

  final String selectedLocale;
  final ComicLocaleStatus status;
  final String? message;
  final ComicEntity? updatedComic;
  final String? chapterId;
  final int? addedImageCount;
  final String? musicUrl;
  final String? chapterName;
  final bool? isFreePreview;
  final String? operationLocale;

  /// True when locale title/description/category fields differ from saved data.
  final bool hasUnsavedMetadata;

  bool get isLoading => status == ComicLocaleStatus.loading;
  bool get isEnglish => AppLocales.isEnglish(selectedLocale);

  ComicLocaleState copyWith({
    String? selectedLocale,
    ComicLocaleStatus? status,
    String? message,
    ComicEntity? updatedComic,
    String? chapterId,
    int? addedImageCount,
    String? musicUrl,
    String? chapterName,
    bool? isFreePreview,
    String? operationLocale,
    bool? hasUnsavedMetadata,
    bool clearStatus = false,
    bool clearUpdatedComic = false,
    bool clearChapterExtras = false,
  }) {
    return ComicLocaleState(
      selectedLocale: selectedLocale ?? this.selectedLocale,
      status: clearStatus ? ComicLocaleStatus.idle : (status ?? this.status),
      message: clearStatus ? null : (message ?? this.message),
      updatedComic: clearUpdatedComic
          ? null
          : (updatedComic ?? this.updatedComic),
      chapterId: clearChapterExtras ? null : (chapterId ?? this.chapterId),
      addedImageCount:
          clearChapterExtras ? null : (addedImageCount ?? this.addedImageCount),
      musicUrl: clearChapterExtras ? null : (musicUrl ?? this.musicUrl),
      chapterName: clearChapterExtras ? null : (chapterName ?? this.chapterName),
      isFreePreview:
          clearChapterExtras ? null : (isFreePreview ?? this.isFreePreview),
      operationLocale: clearChapterExtras
          ? null
          : (operationLocale ?? this.operationLocale),
      hasUnsavedMetadata: hasUnsavedMetadata ?? this.hasUnsavedMetadata,
    );
  }
}
