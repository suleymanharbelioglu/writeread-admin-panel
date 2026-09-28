import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/data/chapter/model/chapter_model.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class ComicModel {
  final String comicId;
  final String title;
  final String description;
  final String image;
  final bool isSensitive;
  final String contentType;
  final bool isFree;
  final String productId;
  final int likeCount;
  final int readCount;
  final int chapterCount;
  final DateTime createdDate;
  final String categoryId;
  final String categoryName;
  final List<ChapterModel> chapters;
  final Map<String, ComicLocaleContent> locales;

  ComicModel({
    required this.comicId,
    required this.title,
    required this.description,
    required this.image,
    required this.isSensitive,
    this.contentType = ComicContentType.comic,
    this.isFree = true,
    this.productId = '',
    required this.likeCount,
    required this.readCount,
    required this.chapterCount,
    required this.createdDate,
    required this.categoryId,
    required this.categoryName,
    required this.chapters,
    this.locales = const {},
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'comicId': comicId,
      'title': title,
      'description': description,
      'image': image,
      'isSensitive': isSensitive,
      'contentType': contentType,
      'isFree': isFree,
      'productId': productId,
      'likeCount': likeCount,
      'readCount': readCount,
      'chapterCount': chapterCount,
      'createdDate': Timestamp.fromDate(createdDate),
      'categoryId': categoryId,
      'categoryName': categoryName,
      'chapters': chapters.map((c) => c.toMap()).toList(),
    };
    if (locales.isNotEmpty) {
      map['locales'] = {
        for (final e in locales.entries)
          if (!AppLocales.isEnglish(e.key)) e.key: e.value.toMap(),
      };
    }
    return map;
  }

  static Map<String, ComicLocaleContent> _parseLocales(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, ComicLocaleContent>{};
    raw.forEach((key, value) {
      final code = key?.toString() ?? '';
      if (!AppLocales.isSupported(code) || AppLocales.isEnglish(code)) return;
      if (value is! Map) return;
      out[code] = ComicLocaleContent.fromMap(Map<String, dynamic>.from(value));
    });
    return out;
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    final productId = map['productId'] as String? ?? '';
    final isFree = map.containsKey('isFree')
        ? (map['isFree'] as bool? ?? true)
        : productId.isEmpty;
    return ComicModel(
      comicId: map['comicId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
      isSensitive: map['isSensitive'] as bool? ?? false,
      contentType: ComicContentType.parse(map['contentType']),
      isFree: isFree,
      productId: productId,
      likeCount: (map['likeCount'] as num?)?.toInt() ?? 0,
      readCount: (map['readCount'] as num?)?.toInt() ?? 0,
      chapterCount: (map['chapterCount'] as num?)?.toInt() ?? 0,
      createdDate: _parseDate(map['createdDate']),
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      chapters: (map['chapters'] as List<dynamic>?)
              ?.map(
                (c) =>
                    ChapterModel.fromMap(Map<String, dynamic>.from(c as Map)),
              )
              .toList() ??
          [],
      locales: _parseLocales(map['locales']),
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

extension ComicModelX on ComicModel {
  ComicEntity toEntity() {
    return ComicEntity(
      comicId: comicId,
      title: title,
      description: description,
      image: image,
      isSensitive: isSensitive,
      contentType: contentType,
      isFree: isFree,
      productId: productId,
      likeCount: likeCount,
      readCount: readCount,
      chapterCount: chapterCount,
      createdDate: createdDate,
      categoryId: categoryId,
      categoryName: categoryName,
      chapters: chapters.map((c) => c.toEntity()).toList(),
      locales: locales,
    );
  }
}

extension ComicEntityX on ComicEntity {
  ComicModel toModel() {
    return ComicModel(
      comicId: comicId,
      title: title,
      description: description,
      image: image,
      isSensitive: isSensitive,
      contentType: contentType,
      isFree: isFree,
      productId: productId,
      likeCount: likeCount,
      readCount: readCount,
      chapterCount: chapterCount,
      createdDate: createdDate,
      categoryId: categoryId,
      categoryName: categoryName,
      chapters: chapters.map((c) => c.toModel()).toList(),
      locales: locales,
    );
  }
}
