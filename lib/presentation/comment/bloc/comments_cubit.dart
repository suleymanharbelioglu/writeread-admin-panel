import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/delete_comment.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/get_chapter_comments.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/get_comic_comments.dart';
import 'package:writeread_admin_panel/presentation/comment/bloc/comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required GetComicCommentsUseCase getComicCommentsUseCase,
    required GetChapterCommentsUseCase getChapterCommentsUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  })  : _getComicCommentsUseCase = getComicCommentsUseCase,
        _getChapterCommentsUseCase = getChapterCommentsUseCase,
        _deleteCommentUseCase = deleteCommentUseCase,
        super(const CommentsInitial());

  final GetComicCommentsUseCase _getComicCommentsUseCase;
  final GetChapterCommentsUseCase _getChapterCommentsUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  Future<void> loadComicComments(String comicId) async {
    emit(const CommentsLoading());
    final result = await _getComicCommentsUseCase.call(params: comicId);
    result.fold(
      (m) => emit(CommentsFailure(m)),
      (list) => emit(CommentsSuccess(list)),
    );
  }

  Future<void> loadChapterComments(String comicId, String chapterId) async {
    emit(const CommentsLoading());
    final result = await _getChapterCommentsUseCase.call(
      params: GetChapterCommentsParams(comicId: comicId, chapterId: chapterId),
    );
    result.fold(
      (m) => emit(CommentsFailure(m)),
      (list) => emit(CommentsSuccess(list)),
    );
  }

  Future<void> deleteComment(CommentEntity comment) async {
    final curr = state;
    if (curr is! CommentsSuccess) return;

    emit(
      CommentDeleting(comments: curr.comments, deletingCommentId: comment.id),
    );

    final isChapterComment =
        comment.chapterId != null && comment.chapterId!.isNotEmpty;
    final result = await _deleteCommentUseCase.call(
      params: DeleteCommentParams(
        commentId: comment.id,
        isChapterComment: isChapterComment,
      ),
    );
    result.fold(
      (m) => emit(CommentsFailure(m)),
      (_) {
        final updated =
            curr.comments.where((c) => c.id != comment.id).toList();
        emit(CommentsSuccess(updated));
      },
    );
  }
}

