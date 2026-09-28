class ChapterEntity {
  final String chapterId;
  final String comicId;
  final int pageCount;
  final String chapterName;
  final DateTime createdDate;
  /// Readable without buying the comic (only applies when comic requires purchase).
  final bool isFreePreview;
  /// Download URL for chapter music (optional).
  final String? musicUrl;
  /// Bumped on every page/music change so page URLs change. 0 = legacy.
  final int pagesVersion;

  const ChapterEntity({
    required this.chapterId,
    required this.comicId,
    required this.pageCount,
    required this.chapterName,
    required this.createdDate,
    this.isFreePreview = false,
    this.musicUrl,
    this.pagesVersion = 0,
  });

  ChapterEntity copyWith({
    String? chapterId,
    String? comicId,
    int? pageCount,
    String? chapterName,
    DateTime? createdDate,
    bool? isFreePreview,
    String? musicUrl,
    bool clearMusicUrl = false,
    int? pagesVersion,
  }) {
    return ChapterEntity(
      chapterId: chapterId ?? this.chapterId,
      comicId: comicId ?? this.comicId,
      pageCount: pageCount ?? this.pageCount,
      chapterName: chapterName ?? this.chapterName,
      createdDate: createdDate ?? this.createdDate,
      isFreePreview: isFreePreview ?? this.isFreePreview,
      musicUrl: clearMusicUrl ? null : (musicUrl ?? this.musicUrl),
      pagesVersion: pagesVersion ?? this.pagesVersion,
    );
  }
}
