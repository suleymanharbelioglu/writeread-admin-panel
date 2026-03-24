class AddComicParams {
  const AddComicParams({
    required this.title,
    required this.description,
    required this.categoryName,
    required this.isSensitive,
    this.imageBytes,
  });
  final String title;
  final String description;
  final String categoryName;
  final bool isSensitive;
  final List<int>? imageBytes;
}
