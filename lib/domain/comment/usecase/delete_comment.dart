import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/comment/repository/comment.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class DeleteCommentParams {
  final String commentId;
  final bool isChapterComment;

  const DeleteCommentParams({
    required this.commentId,
    required this.isChapterComment,
  });
}

class DeleteCommentUseCase
    implements UseCase<Either<String, void>, DeleteCommentParams> {
  @override
  Future<Either<String, void>> call({DeleteCommentParams? params}) async {
    if (params == null || params.commentId.trim().isEmpty) {
      return const Left('Comment id required');
    }
    return sl<CommentRepository>().deleteComment(
      commentId: params.commentId.trim(),
      isChapterComment: params.isChapterComment,
    );
  }
}

