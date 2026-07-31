class UpdateComicParams {
  const UpdateComicParams({
    required this.comicId,
    required this.title,
    required this.description,
    required this.isSensitive,
    required this.isFree,
    required this.productId,
    this.oldImageFilename,
    this.newImageBytes,
  });

  final String comicId;
  final String title;
  final String description;
  final bool isSensitive;
  final bool isFree;
  final String productId;
  final String? oldImageFilename;
  final List<int>? newImageBytes;
}
