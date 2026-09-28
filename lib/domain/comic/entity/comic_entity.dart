import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class ComicEntity {
  final String comicId;
  final String title;
  final String description;
  final String image;
  final bool isSensitive;
  final String contentType;
  /// When true, all chapters are unlocked. When false, purchase (productId) is required.
  final bool isFree;
  /// App Store / Play Store IAP product ID (used when [isFree] is false).
  final String productId;
  final int likeCount;
  final int readCount;
  final int chapterCount;
  final DateTime createdDate;
  final String categoryId;
  final String categoryName;
  final List<ChapterEntity> chapters;

  /// Non-English overlays from Firestore (`locales` map). Never includes `en`.
  final Map<String, ComicLocaleContent> locales;

  const ComicEntity({
    required this.comicId,
    required this.title,
    required this.description,
    required this.image,
    required this.isSensitive,
    this.contentType = ComicContentType.comic,
    this.isFree = true,
    this.productId = '',
    required this.likeCount,
    required this.readCount,
    required this.chapterCount,
    required this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.chapters,
    this.locales = const {},
  });

  /// Readiness for any language tab, including English root content.
  LocaleReadiness readinessFor(String localeCode) {
    if (AppLocales.isEnglish(localeCode)) return englishReadiness;
    return localeReadiness(locales, localeCode);
  }

  /// English root: title + description + at least one chapter with pages.
  LocaleReadiness get englishReadiness {
    final hasMeta =
        title.trim().isNotEmpty && description.trim().isNotEmpty;
    final hasChapters = chapters.any((c) => c.pageCount > 0);
    if (!hasMeta && !hasChapters && image.trim().isEmpty) {
      return LocaleReadiness.missing;
    }
    if (hasMeta && hasChapters) return LocaleReadiness.ready;
    return LocaleReadiness.partial;
  }

  ComicEntity copyWith({
    String? comicId,
    String? title,
    String? description,
    String? image,
    bool? isSensitive,
    String? contentType,
    bool? isFree,
    String? productId,
    int? likeCount,
    int? readCount,
    int? chapterCount,
    DateTime? createdDate,
    String? categoryId,
    String? categoryName,
    List<ChapterEntity>? chapters,
    Map<String, ComicLocaleContent>? locales,
  }) {
    return ComicEntity(
      comicId: comicId ?? this.comicId,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      isSensitive: isSensitive ?? this.isSensitive,
      contentType: contentType ?? this.contentType,
      isFree: isFree ?? this.isFree,
      productId: productId ?? this.productId,
      likeCount: likeCount ?? this.likeCount,
      readCount: readCount ?? this.readCount,
      chapterCount: chapterCount ?? this.chapterCount,
      createdDate: createdDate ?? this.createdDate,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      chapters: chapters ?? this.chapters,
      locales: locales ?? this.locales,
    );
  }
}
