import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';

abstract class CommentRepository {
  Future<Either<String, List<CommentEntity>>> getComicComments(
    String comicId,
  );

  Future<Either<String, List<CommentEntity>>> getChapterComments(
    String comicId,
    String chapterId,
  );

  Future<Either<String, void>> deleteComment({
    required String commentId,
    required bool isChapterComment,
  });
}

