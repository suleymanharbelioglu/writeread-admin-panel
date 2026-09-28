import 'package:writeread_admin_panel/core/constants/app_urls.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';

/// Storage path helpers — must stay in sync with Comics-App.
class ChapterStoragePaths {
  ChapterStoragePaths._();

  static const String musicFileName = 'music.mp3';
  static const String comicsFolder = 'Comics';

  static String pageObjectPath({
    required String comicId,
    required String chapterId,
    required int pageNumber,
    String locale = AppLocales.english,
  }) {
    final file = '$pageNumber${AppUrl.chapterImageExtension}';
    if (AppLocales.isEnglish(locale)) {
      return '$comicsFolder/$comicId/$chapterId/$file';
    }
    return '$comicsFolder/$comicId/$locale/$chapterId/$file';
  }

  static String musicObjectPath({
    required String comicId,
    required String chapterId,
    String locale = AppLocales.english,
  }) {
    if (AppLocales.isEnglish(locale)) {
      return '$comicsFolder/$comicId/$chapterId/$musicFileName';
    }
    return '$comicsFolder/$comicId/$locale/$chapterId/$musicFileName';
  }

  static String chapterFolderObjectPath({
    required String comicId,
    required String chapterId,
    String locale = AppLocales.english,
  }) {
    if (AppLocales.isEnglish(locale)) {
      return '$comicsFolder/$comicId/$chapterId';
    }
    return '$comicsFolder/$comicId/$locale/$chapterId';
  }

  static String localeFolderObjectPath({
    required String comicId,
    required String locale,
  }) {
    assert(!AppLocales.isEnglish(locale));
    return '$comicsFolder/$comicId/$locale';
  }

  static String coverObjectPath({
    required String comicId,
    String locale = AppLocales.english,
  }) {
    if (AppLocales.isEnglish(locale)) {
      return '$comicsFolder/${comicId}_cover.jpg';
    }
    return '$comicsFolder/$comicId/$locale/cover.jpg';
  }

  /// Firestore `image` / `locales.{code}.image` value for [generateComicImageURL].
  static String coverImageField({
    required String comicId,
    String locale = AppLocales.english,
  }) {
    if (AppLocales.isEnglish(locale)) {
      return '${comicId}_cover.jpg';
    }
    return '$comicId/$locale/cover.jpg';
  }

  /// New chapter `pagesVersion` for a page/music change. Always greater than
  /// [previous] so page URLs change even if the admin clock is behind.
  static int nextPagesVersion([int previous = 0]) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > previous ? now : previous + 1;
  }

  /// Firestore cover value for a new upload. Every upload must get a new
  /// object name: the app caches images by URL, so reusing a name keeps
  /// showing the old cover on devices.
  static String versionedCoverImageField({
    required String comicId,
    required int version,
    String locale = AppLocales.english,
  }) {
    if (AppLocales.isEnglish(locale)) {
      return '${comicId}_cover_$version.jpg';
    }
    return '$comicId/$locale/cover_$version.jpg';
  }

  /// Storage object path for a Firestore cover value (legacy or versioned).
  static String coverObjectPathFromField(String imageField) =>
      '$comicsFolder/${imageField.trim()}';

  /// Matches root-level EN cover object names of [comicId] (legacy + versioned).
  static bool isRootCoverNameOf(String objectName, String comicId) {
    final pattern = RegExp('^${RegExp.escape(comicId)}_cover(_\\d+)?\\.jpg\$');
    return pattern.hasMatch(objectName);
  }

  static String pageDownloadUrl({
    required String comicId,
    required String chapterId,
    required int pageNumber,
    String locale = AppLocales.english,
    int pagesVersion = 0,
  }) {
    final encoded = pageObjectPath(
      comicId: comicId,
      chapterId: chapterId,
      pageNumber: pageNumber,
      locale: locale,
    ).split('/').map(Uri.encodeComponent).join('%2F');
    final version = pagesVersion > 0 ? '&v=$pagesVersion' : '';
    return '${AppUrl.storageBase}$encoded${AppUrl.alt}$version';
  }
}
