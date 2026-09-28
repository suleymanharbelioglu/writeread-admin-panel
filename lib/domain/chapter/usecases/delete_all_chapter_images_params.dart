import 'package:writeread_admin_panel/core/locale/app_locales.dart';

class DeleteAllChapterImagesParams {
  const DeleteAllChapterImagesParams({
    required this.comicId,
    required this.chapterId,
    this.locale = AppLocales.english,
  });
  final String comicId;
  final String chapterId;
  final String locale;
}
