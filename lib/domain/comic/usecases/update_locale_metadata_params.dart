class UpdateLocaleMetadataParams {
  const UpdateLocaleMetadataParams({
    required this.comicId,
    required this.locale,
    required this.title,
    required this.description,
    required this.categoryName,
  });

  final String comicId;
  final String locale;
  final String title;
  final String description;
  final String categoryName;
}
