import 'package:writeread_admin_panel/core/constants/app_urls.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

/// Builds display URLs for comic and chapter images.
/// Storage paths these map to (for delete comic):
/// - Comic image: Comics/{filename} (filename = doc image field, e.g. comicId_cover.jpg)
/// - Chapter images: Comics/{comicId}/{chapterId}/1.jpeg, 2.jpeg, ... → folder Comics/{comicId}/
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
