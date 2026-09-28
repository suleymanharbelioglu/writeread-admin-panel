class UploadLocaleCoverParams {
  const UploadLocaleCoverParams({
    required this.comicId,
    required this.locale,
    required this.imageBytes,
  });

  final String comicId;
  final String locale;
  final List<int> imageBytes;
}
