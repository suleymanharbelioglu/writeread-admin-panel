import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';

class UpdateComicParams {
  const UpdateComicParams({
    required this.comicId,
    required this.title,
    required this.description,
    required this.isSensitive,
    this.contentType = ComicContentType.comic,
    required this.isFree,
    required this.productId,
    this.oldImageFilename,
    this.newImageBytes,
  });

  final String comicId;
  final String title;
  final String description;
  final bool isSensitive;
  final String contentType;
  final bool isFree;
  final String productId;
  final String? oldImageFilename;
  final List<int>? newImageBytes;
}
