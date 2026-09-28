import 'package:cloud_firestore/cloud_firestore.dart';

/// Non-English overlay stored under Firestore `locales.{code}`.
/// Never includes `en` — English lives on root comic fields.
class ComicLocaleContent {
  final String title;
  final String description;
  final String categoryName;

  /// Locale cover path under Comics/, e.g. `my_comic/tr/cover.jpg`. Empty = EN cover.
  final String image;

  /// Independent chapters for this locale (no English fallback).
  final List<ChapterLocaleContent> chapters;

  const ComicLocaleContent({
    required this.title,
    required this.description,
    required this.categoryName,
    this.image = '',
    this.chapters = const [],
  });

  bool get hasMetadata =>
      title.trim().isNotEmpty || description.trim().isNotEmpty;

  bool get hasTitleAndDescription =>
      title.trim().isNotEmpty && description.trim().isNotEmpty;

  bool get hasCover => image.trim().isNotEmpty;

  bool get hasChapters => chapters.any((c) => c.hasPages);

  ChapterLocaleContent? chapterById(String chapterId) {
    for (final c in chapters) {
      if (c.chapterId == chapterId) return c;
    }
    return null;
  }

  ComicLocaleContent copyWith({
    String? title,
    String? description,
    String? categoryName,
    String? image,
    List<ChapterLocaleContent>? chapters,
    bool clearImage = false,
  }) {
    return ComicLocaleContent(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryName: categoryName ?? this.categoryName,
      image: clearImage ? '' : (image ?? this.image),
      chapters: chapters ?? this.chapters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'categoryName': categoryName,
      if (image.trim().isNotEmpty) 'image': image.trim(),
      'chapters': chapters.map((c) => c.toMap()).toList(),
    };
  }

  factory ComicLocaleContent.fromMap(Map<String, dynamic> map) {
    final chaptersRaw = map['chapters'];
    final chapters = <ChapterLocaleContent>[];
    if (chaptersRaw is List) {
      for (final c in chaptersRaw) {
        if (c is! Map) continue;
        final parsed = ChapterLocaleContent.fromMap(
          Map<String, dynamic>.from(c),
        );
        if (parsed.chapterId.isEmpty) continue;
        chapters.add(parsed);
      }
    }
    return ComicLocaleContent(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      image: map['image'] as String? ?? '',
      chapters: chapters,
    );
  }
}

/// Full chapter for a non-English locale (independent from root EN chapters).
class ChapterLocaleContent {
  final String chapterId;
  final String comicId;
  final String chapterName;
  final int pageCount;
  final DateTime createdDate;
  final bool isFreePreview;
  final String? musicUrl;

  /// Bumped on every page/music change; the app adds it to page URLs so
  /// cached images are never reused after an edit. 0 = legacy (no version).
  final int pagesVersion;

  const ChapterLocaleContent({
    required this.chapterId,
    required this.comicId,
    required this.chapterName,
    required this.pageCount,
    required this.createdDate,
    this.isFreePreview = false,
    this.musicUrl,
    this.pagesVersion = 0,
  });

  bool get hasPages => pageCount > 0;

  ChapterLocaleContent copyWith({
    String? chapterId,
    String? comicId,
    String? chapterName,
    int? pageCount,
    DateTime? createdDate,
    bool? isFreePreview,
    String? musicUrl,
    bool clearMusicUrl = false,
    int? pagesVersion,
  }) {
    return ChapterLocaleContent(
      chapterId: chapterId ?? this.chapterId,
      comicId: comicId ?? this.comicId,
      chapterName: chapterName ?? this.chapterName,
      pageCount: pageCount ?? this.pageCount,
      createdDate: createdDate ?? this.createdDate,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      musicUrl: clearMusicUrl ? null : (musicUrl ?? this.musicUrl),
      pagesVersion: pagesVersion ?? this.pagesVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'comicId': comicId,
      'chapterName': chapterName,
      'pageCount': pageCount,
      'createdDate': Timestamp.fromDate(createdDate),
      'isFreePreview': isFreePreview,
      if (musicUrl != null && musicUrl!.isNotEmpty) 'musicUrl': musicUrl,
      if (pagesVersion > 0) 'pagesVersion': pagesVersion,
    };
  }

  factory ChapterLocaleContent.fromMap(Map<String, dynamic> map) {
    final created = map['createdDate'];
    final createdDate = created is Timestamp
        ? created.toDate()
        : DateTime.now();
    return ChapterLocaleContent(
      chapterId: map['chapterId'] as String? ?? '',
      comicId: map['comicId'] as String? ?? '',
      chapterName: map['chapterName'] as String? ?? '',
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 0,
      createdDate: createdDate,
      isFreePreview: map['isFreePreview'] as bool? ?? false,
      musicUrl: map['musicUrl'] as String?,
      pagesVersion: (map['pagesVersion'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Admin readiness for a content locale (independent chapters).
enum LocaleReadiness { missing, partial, ready }

LocaleReadiness localeReadiness(
  Map<String, ComicLocaleContent> locales,
  String localeCode,
) {
  final overlay = locales[localeCode];
  if (overlay == null) return LocaleReadiness.missing;
  if (!overlay.hasMetadata && !overlay.hasCover && overlay.chapters.isEmpty) {
    return LocaleReadiness.missing;
  }
  final metaOk = overlay.hasTitleAndDescription;
  final chaptersOk = overlay.hasChapters;
  if (metaOk && chaptersOk) return LocaleReadiness.ready;
  return LocaleReadiness.partial;
}
