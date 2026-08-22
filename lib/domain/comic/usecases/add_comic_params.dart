import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';

class AddComicParams {
  const AddComicParams({
    required this.title,
    required this.description,
    required this.categoryName,
    required this.isSensitive,
    this.contentType = ComicContentType.comic,
    this.isFree = true,
    this.productId = '',
    this.imageBytes,
  });
  final String title;
  final String description;
  final String categoryName;
  final bool isSensitive;
  final String contentType;
  final bool isFree;
  /// App Store / Play Store IAP product ID. Always required (free/paid can change later).
  final String productId;
  final List<int>? imageBytes;
}
