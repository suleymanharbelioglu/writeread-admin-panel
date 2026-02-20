import 'package:cloud_firestore/cloud_firestore.dart';

class ChapterEntity {
  final String chapterId;
  final String comicId;
  final int pageCount; // 🔥 chapter’daki görsel sayısı
  final String chapterName; // 🔹 chapter adı
  final Timestamp createdDate;
  final bool isVip; // 🔒 VIP chapter mı?
  /// Firebase Storage download URL for chapter music (optional).
  final String? musicUrl;

  ChapterEntity({
    required this.chapterId,
    required this.comicId,
    required this.pageCount,
    required this.chapterName,
    required this.createdDate,
    this.isVip = true,
    this.musicUrl,
  });
}
