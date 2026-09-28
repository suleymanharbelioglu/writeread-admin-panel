class DeleteLastChapterParams {
  const DeleteLastChapterParams({
    required this.comicId,
    this.locale = 'en',
  });

  final String comicId;
  final String locale;
}
