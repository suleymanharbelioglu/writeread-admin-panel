import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comment/source/comment_firebase_service.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';
import 'package:writeread_admin_panel/domain/comment/repository/comment.dart';
import 'package:writeread_admin_panel/service_locator.dart';
import 'package:writeread_admin_panel/data/comment/model/comment_model.dart';

class CommentRepositoryImpl extends CommentRepository {
  @override
  Future<Either<String, List<CommentEntity>>> getComicComments(
    String comicId,
  ) async {
    final result = await sl<CommentFirebaseService>().getComicComments(comicId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, List<CommentEntity>>> getChapterComments(
    String comicId,
    String chapterId,
  ) async {
    final result = await sl<CommentFirebaseService>().getChapterComments(
      comicId,
      chapterId,
    );
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<String, void>> deleteComment({
    required String commentId,
    required bool isChapterComment,
  }) async {
    return sl<CommentFirebaseService>().deleteComment(
      commentId: commentId,
      isChapterComment: isChapterComment,
    );
  }
}

