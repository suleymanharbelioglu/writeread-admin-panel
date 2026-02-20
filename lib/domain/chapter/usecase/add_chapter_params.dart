class AddChapterParams {
  const AddChapterParams({
    required this.comicId,
    required this.chapterName,
    required this.imageBytesList,
    this.isVip = true,
    this.musicBytes,
  });

  final String comicId;
  final String chapterName;
  final List<List<int>> imageBytesList;
  final bool isVip;
  /// Optional music file bytes (e.g. MP3). Uploaded to Storage; URL saved in chapter as musicUrl.
  final List<int>? musicBytes;
}
