class UpdateChapterParams {
  const UpdateChapterParams({
    required this.comicId,
    required this.chapterId,
    this.additionalImageBytesList,
    this.musicBytes,
    this.isFreePreview,
  });

  final String comicId;
  final String chapterId;
  final bool? isFreePreview;
  final List<List<int>>? additionalImageBytesList;
  /// New chapter music; uploads to Storage and sets musicUrl. Replaces existing music (old file deleted).
  final List<int>? musicBytes;
}
