class AddComicParams {
  const AddComicParams({
    required this.title,
    required this.description,
    required this.categoryName,
    this.imageBytes,
  });
  final String title;
  final String description;
  final String categoryName;
  final List<int>? imageBytes;
}
