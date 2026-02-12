class AddChapterParams {
  const AddChapterParams({
    required this.comicId,
    required this.chapterName,
    required this.imageBytesList,
    this.isVip = true,
  });

  final String comicId;
  final String chapterName;
  final List<List<int>> imageBytesList;
  final bool isVip;
}
