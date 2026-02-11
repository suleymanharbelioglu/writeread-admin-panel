import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ChapterModel {
  final String chapterId; // chapter1, chapter2 ...
  final String comicId; // comicId
  final int pageCount; // 🔥 kaç sayfa (görsel)
  final String chapterName; // 🔹 chapter adı
  final Timestamp createdDate;
  final bool isVip; // 🔒 VIP chapter mı?

  ChapterModel({
    required this.chapterId,
    required this.comicId,
    required this.pageCount,
    required this.chapterName,
    required this.createdDate,
    this.isVip = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "chapterId": chapterId,
      "comicId": comicId,
      "pageCount": pageCount,
      "chapterName": chapterName,
      "createdDate": createdDate,
      "isVip": isVip,
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      chapterId: map["chapterId"],
      comicId: map["comicId"],
      pageCount: map["pageCount"],
      chapterName: map["chapterName"],
      createdDate: map["createdDate"],
      isVip: (map["isVip"] ?? false) as bool,
    );
  }
}

// ChapterModel -> ChapterEntity
extension ChapterXModel on ChapterModel {
  ChapterEntity toEntity() {
    return ChapterEntity(
      chapterId: chapterId,
      comicId: comicId,
      pageCount: pageCount,
      chapterName: chapterName,
      createdDate: createdDate,
      isVip: isVip,
    );
  }
}

// ChapterEntity -> ChapterModel
extension ChapterXEntity on ChapterEntity {
  ChapterModel fromEntity() {
    return ChapterModel(
      chapterId: chapterId,
      comicId: comicId,
      pageCount: pageCount,
      chapterName: chapterName,
      createdDate: createdDate,
      isVip: isVip,
    );
  }
}
