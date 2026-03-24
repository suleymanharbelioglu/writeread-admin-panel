import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/comment/model/comment_model.dart';

abstract class CommentFirebaseService {
  Future<Either<String, List<CommentModel>>> getComicComments(String comicId);

  Future<Either<String, List<CommentModel>>> getChapterComments(
    String comicId,
    String chapterId,
  );

  Future<Either<String, void>> deleteComment({
    required String commentId,
    required bool isChapterComment,
  });
}

