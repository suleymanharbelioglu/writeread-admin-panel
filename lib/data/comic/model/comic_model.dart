import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';

class ComicModel {
  final String comicId;
  final String title;
  final String description;
  final String image;
  final int likeCount;
  final int readCount;
  final int chapterCount; // 🔥 eklendi
  final Timestamp createdDate;
  final String categoryId;
  final String categoryName;
  final List<ChapterModel> chapters;

  ComicModel({
    required this.comicId,
    required this.title,
    required this.description,
    required this.image,
    required this.likeCount,
    required this.readCount,
    required this.chapterCount, // 🔥 constructor
    required this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.chapters,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "comicId": comicId,
      "title": title,
      "description": description,
      "image": image,
      "likeCount": likeCount,
      "readCount": readCount,
      "chapterCount": chapterCount, // 🔥 map
      "createdDate": createdDate,
      "categoryId": categoryId,
      "categoryName": categoryName,
      "chapters": chapters.map((c) => c.toMap()).toList(),
    };
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    return ComicModel(
      comicId: map["comicId"] as String,
      title: map["title"] as String,
      description: map["description"] as String,
      image: map["image"] as String,
      likeCount: map["likeCount"] as int,
      readCount: map["readCount"] as int? ?? 0,
      chapterCount: map["chapterCount"] as int, // 🔥 fromMap
      createdDate: map["createdDate"] as Timestamp,
      categoryId: map["categoryId"] as String,
      categoryName: map["categoryName"] as String,
      chapters:
          (map["chapters"] as List<dynamic>?)
              ?.map((c) => ChapterModel.fromMap(c))
              .toList() ??
          [],
    );
  }
}

// ComicModel -> ComicEntity
extension ComicXModel on ComicModel {
  ComicEntity toEntity() {
    return ComicEntity(
      comicId: comicId,
      title: title,
      description: description,
      image: image,
      likeCount: likeCount,
      readCount: readCount,
      chapterCount: chapterCount, // 🔥
      createdDate: createdDate,
      categoryId: categoryId,
      categoryName: categoryName,
      chapters: chapters.map((c) => c.toEntity()).toList(),
    );
  }
}

// ComicEntity -> ComicModel
extension ComicXEntity on ComicEntity {
  ComicModel fromEntity() {
    return ComicModel(
      comicId: comicId,
      title: title,
      description: description,
      image: image,
      likeCount: likeCount,
      readCount: readCount,
      chapterCount: chapterCount, // 🔥
      createdDate: createdDate,
      categoryId: categoryId,
      categoryName: categoryName,
      chapters: chapters.map((c) => c.fromEntity()).toList(),
    );
  }
}
