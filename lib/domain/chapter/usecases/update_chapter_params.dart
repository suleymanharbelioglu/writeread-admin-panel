import 'package:writeread_admin_panel/core/locale/app_locales.dart';

class UpdateChapterParams {
  const UpdateChapterParams({
    required this.comicId,
    required this.chapterId,
    this.additionalImageBytesList,
    this.musicBytes,
    this.isFreePreview,
    this.chapterName,
    this.locale = AppLocales.english,
  });

  final String comicId;
  final String chapterId;
  final bool? isFreePreview;
  final List<List<int>>? additionalImageBytesList;

  /// New chapter music; uploads to Storage and sets musicUrl. Replaces existing music (old file deleted).
  final List<int>? musicBytes;
  final String? chapterName;
  final String locale;
}
