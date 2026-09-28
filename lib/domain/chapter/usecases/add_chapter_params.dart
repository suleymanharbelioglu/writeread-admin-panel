class AddChapterParams {
  const AddChapterParams({
    required this.comicId,
    required this.chapterName,
    required this.imageBytesList,
    this.musicBytes,
    this.isFreePreview = false,
    this.locale = 'en',
  });

  final String comicId;
  final String chapterName;
  final List<List<int>> imageBytesList;
  final bool isFreePreview;
  /// Optional music file bytes (e.g. MP3). Uploaded to Storage; URL saved in chapter as musicUrl.
  final List<int>? musicBytes;
  /// Content locale (`en` = root chapters, other = locales.{code}.chapters).
  final String locale;
}
