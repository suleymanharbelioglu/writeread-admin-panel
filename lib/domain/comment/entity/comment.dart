class CommentEntity {
  final String id;
  final String comicId;

  /// null or empty = comic-level comment; non-empty = chapter-level.
  final String? chapterId;

  /// Optional; for display (e.g. "Bölüm 42").
  final String? chapterName;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final bool isSpoiler;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.comicId,
    this.chapterId,
    this.chapterName,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    required this.isSpoiler,
    required this.createdAt,
  });
}

