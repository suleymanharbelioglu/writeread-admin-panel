import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ComicEntity {
  final String comicId;
  final String title;
  final String description;
  final String image;
  final int likeCount;
  final int readCount;
  final int chapterCount;         // 🔥 eklendi
  final Timestamp createdDate;
  final String categoryId;
  final String categoryName;
  final List<ChapterEntity> chapters; // ✅ chapter listesi

  ComicEntity({
    required this.comicId,
    required this.title,
    required this.description,
    required this.image,
    required this.likeCount,    required this.readCount,    required this.chapterCount,    // 🔥 constructor’a eklendi
    required this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.chapters,
  });
}
