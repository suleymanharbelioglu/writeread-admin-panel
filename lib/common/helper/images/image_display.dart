import 'package:writeread_admin_panel/core/constants/app_urls.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ImageDisplayHelper {
  static String generateComicImageURL(String title) {
    return AppUrl.comicImage + title + AppUrl.alt;
  }

  static List<String> generateChapterImageURLs(ChapterEntity chapter) {
    return List.generate(chapter.pageCount, (index) {
      return '${AppUrl.chapterImage}${chapter.comicId}%2F${chapter.chapterId}%2F${index + 1}${AppUrl.chapterImageExtension}${AppUrl.alt}';
    });
  }
}
