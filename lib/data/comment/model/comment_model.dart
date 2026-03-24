import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';

class CommentModel {
  final String id;
  final String comicId;

  /// null or empty = comic-level comment; non-empty = chapter-level.
  final String? chapterId;

  /// Optional; for display (e.g. "Bölüm 42").
  final String? chapterName;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final bool isSpoiler;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.comicId,
    this.chapterId,
    this.chapterName,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    this.isSpoiler = false,
    required this.createdAt,
  });

  CommentModel copyWith({
    String? id,
    String? comicId,
    String? chapterId,
    String? chapterName,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? text,
    bool? isSpoiler,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      text: text ?? this.text,
      isSpoiler: isSpoiler ?? this.isSpoiler,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comicId': comicId,
      'chapterId': chapterId ?? '',
      'chapterName': chapterName ?? '',
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl ?? '',
      'text': text,
      'isSpoiler': isSpoiler,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    final chId = map['chapterId'];
    final chName = map['chapterName'];
    final avatarUrl = map['userAvatarUrl'];
    final spoiler = map['isSpoiler'];
    return CommentModel(
      id: map['id'] as String,
      comicId: map['comicId'] as String,
      chapterId: chId is String ? (chId.isEmpty ? null : chId) : null,
      chapterName: chName is String && chName.isNotEmpty ? chName : null,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userAvatarUrl:
          avatarUrl is String && avatarUrl.isNotEmpty ? avatarUrl : null,
      text: map['text'] as String,
      isSpoiler: spoiler is bool ? spoiler : false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

extension CommentModelX on CommentModel {
  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      comicId: comicId,
      chapterId: chapterId,
      chapterName: chapterName,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      text: text,
      isSpoiler: isSpoiler,
      createdAt: createdAt,
    );
  }
}

extension CommentEntityX on CommentEntity {
  CommentModel toModel() {
    return CommentModel(
      id: id,
      comicId: comicId,
      chapterId: chapterId,
      chapterName: chapterName,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      text: text,
      isSpoiler: isSpoiler,
      createdAt: createdAt,
    );
  }
}

