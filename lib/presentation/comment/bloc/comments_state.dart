import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';

sealed class CommentsState {
  const CommentsState();
}

final class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

final class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

final class CommentsSuccess extends CommentsState {
  const CommentsSuccess(this.comments);
  final List<CommentEntity> comments;
}

final class CommentsFailure extends CommentsState {
  const CommentsFailure(this.message);
  final String message;
}

final class CommentDeleting extends CommentsState {
  const CommentDeleting({
    required this.comments,
    required this.deletingCommentId,
  });

  final List<CommentEntity> comments;
  final String deletingCommentId;
}

