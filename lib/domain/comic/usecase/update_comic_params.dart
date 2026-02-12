class UpdateComicParams {
  const UpdateComicParams({
    required this.comicId,
    required this.title,
    required this.description,
    this.oldImageFilename,
    this.newImageBytes,
  });

  final String comicId;
  final String title;
  final String description;
  final String? oldImageFilename;
  final List<int>? newImageBytes;
}
