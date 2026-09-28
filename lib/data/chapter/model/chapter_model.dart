import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';

class ChapterModel {
  final String chapterId;
  final String comicId;
  final int pageCount;
  final String chapterName;
  final DateTime createdDate;
  final bool isFreePreview;
  final String? musicUrl;
  final int pagesVersion;

  ChapterModel({
    required this.chapterId,
    required this.comicId,
    required this.pageCount,
    required this.chapterName,
    required this.createdDate,
    this.isFreePreview = false,
    this.musicUrl,
    this.pagesVersion = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'comicId': comicId,
      'pageCount': pageCount,
      'chapterName': chapterName,
      'createdDate': Timestamp.fromDate(createdDate),
      'isFreePreview': isFreePreview,
      if (musicUrl != null && musicUrl!.isNotEmpty) 'musicUrl': musicUrl,
      if (pagesVersion > 0) 'pagesVersion': pagesVersion,
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      chapterId: map['chapterId'] as String? ?? '',
      comicId: map['comicId'] as String? ?? '',
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 0,
      chapterName: map['chapterName'] as String? ?? '',
      createdDate: _parseDate(map['createdDate']),
      isFreePreview: map['isFreePreview'] as bool? ?? false,
      musicUrl: map['musicUrl'] as String?,
      pagesVersion: (map['pagesVersion'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

extension ChapterModelX on ChapterModel {
  ChapterEntity toEntity() {
    return ChapterEntity(
      chapterId: chapterId,
      comicId: comicId,
      pageCount: pageCount,
      chapterName: chapterName,
      createdDate: createdDate,
      isFreePreview: isFreePreview,
      musicUrl: musicUrl,
      pagesVersion: pagesVersion,
    );
  }
}

extension ChapterEntityX on ChapterEntity {
  ChapterModel toModel() {
    return ChapterModel(
      chapterId: chapterId,
      comicId: comicId,
      pageCount: pageCount,
      chapterName: chapterName,
      createdDate: createdDate,
      isFreePreview: isFreePreview,
      musicUrl: musicUrl,
      pagesVersion: pagesVersion,
    );
  }
}
