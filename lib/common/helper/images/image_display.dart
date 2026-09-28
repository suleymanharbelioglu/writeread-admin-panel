import 'package:writeread_admin_panel/core/constants/app_urls.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/core/locale/chapter_storage_paths.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

/// Builds display URLs for comic and chapter images.
class ImageDisplayHelper {
  static String generateComicImageURL(String image) {
    final encoded = image.split('/').map(Uri.encodeComponent).join('%2F');
    return AppUrl.comicImage + encoded + AppUrl.alt;
  }

  static List<String> generateChapterImageURLs(
    ChapterEntity chapter, {
    String locale = AppLocales.english,
  }) {
    return List.generate(chapter.pageCount, (index) {
      return ChapterStoragePaths.pageDownloadUrl(
        comicId: chapter.comicId,
        chapterId: chapter.chapterId,
        pageNumber: index + 1,
        locale: locale,
        pagesVersion: chapter.pagesVersion,
      );
    });
  }
}
