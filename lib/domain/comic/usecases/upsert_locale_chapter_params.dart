import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class UpsertLocaleChapterParams {
  const UpsertLocaleChapterParams({
    required this.comicId,
    required this.locale,
    required this.chapter,
  });

  final String comicId;
  final String locale;
  final ChapterLocaleContent chapter;
}
