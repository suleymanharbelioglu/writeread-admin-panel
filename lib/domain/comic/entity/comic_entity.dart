import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ComicEntity {
  final String comicId;
  final String title;
  final String description;
  final String image;
  final bool isSensitive;
  /// When true, all chapters are unlocked. When false, purchase (productId) is required.
  final bool isFree;
  /// App Store / Play Store IAP product ID (used when [isFree] is false).
  final String productId;
  final int likeCount;
  final int readCount;
  final int chapterCount;
  final DateTime createdDate;
  final String categoryId;
  final String categoryName;
  final List<ChapterEntity> chapters;

  const ComicEntity({
    required this.comicId,
    required this.title,
    required this.description,
    required this.image,
    required this.isSensitive,
    this.isFree = true,
    this.productId = '',
    required this.likeCount,
    required this.readCount,
    required this.chapterCount,
    required this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.chapters,
  });

  ComicEntity copyWith({
    String? comicId,
    String? title,
    String? description,
    String? image,
    bool? isSensitive,
    bool? isFree,
    String? productId,
    int? likeCount,
    int? readCount,
    int? chapterCount,
    DateTime? createdDate,
    String? categoryId,
    String? categoryName,
    List<ChapterEntity>? chapters,
  }) {
    return ComicEntity(
      comicId: comicId ?? this.comicId,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      isSensitive: isSensitive ?? this.isSensitive,
      isFree: isFree ?? this.isFree,
      productId: productId ?? this.productId,
      likeCount: likeCount ?? this.likeCount,
      readCount: readCount ?? this.readCount,
      chapterCount: chapterCount ?? this.chapterCount,
      createdDate: createdDate ?? this.createdDate,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      chapters: chapters ?? this.chapters,
    );
  }
}
