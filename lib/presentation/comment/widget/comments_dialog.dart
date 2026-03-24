import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/delete_comment.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/get_chapter_comments.dart';
import 'package:writeread_admin_panel/domain/comment/usecase/get_comic_comments.dart';
import 'package:writeread_admin_panel/presentation/comment/bloc/comments_cubit.dart';
import 'package:writeread_admin_panel/presentation/comment/bloc/comments_state.dart';
import 'package:writeread_admin_panel/presentation/comment/widget/comment_card.dart';
import 'package:writeread_admin_panel/service_locator.dart';

enum CommentsDialogMode { comic, chapter }

class CommentsDialog extends StatelessWidget {
  const CommentsDialog.comic({
    super.key,
    required this.comicId,
    required this.comicTitle,
  })  : mode = CommentsDialogMode.comic,
        chapterId = null,
        chapterName = null;

  const CommentsDialog.chapter({
    super.key,
    required this.comicId,
    required this.comicTitle,
    required this.chapterId,
    required this.chapterName,
  }) : mode = CommentsDialogMode.chapter;

  final CommentsDialogMode mode;
  final String comicId;
  final String comicTitle;
  final String? chapterId;
  final String? chapterName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentsCubit(
        getComicCommentsUseCase: sl<GetComicCommentsUseCase>(),
        getChapterCommentsUseCase: sl<GetChapterCommentsUseCase>(),
        deleteCommentUseCase: sl<DeleteCommentUseCase>(),
      ).._initialLoadFor(
          mode: mode,
          comicId: comicId,
          chapterId: chapterId,
        ),
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
          child: Column(
            children: [
              _DialogHeader(
                title: mode == CommentsDialogMode.comic
                    ? 'Comic comments'
                    : 'Chapter comments',
                subtitle: mode == CommentsDialogMode.comic
                    ? comicTitle
                    : '$comicTitle • ${chapterName ?? chapterId}',
                onClose: () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocConsumer<CommentsCubit, CommentsState>(
                  listener: (context, state) {
                    if (state is CommentsFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CommentsLoading || state is CommentsInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is CommentsFailure) {
                      return _ErrorState(
                        message: state.message,
                        onRetry: () => context.read<CommentsCubit>()._initialLoadFor(
                              mode: mode,
                              comicId: comicId,
                              chapterId: chapterId,
                            ),
                      );
                    }

                    List<CommentEntity> comments = const <CommentEntity>[];
                    String? deletingId;
                    if (state is CommentsSuccess) {
                      comments = state.comments;
                    } else if (state is CommentDeleting) {
                      comments = state.comments;
                      deletingId = state.deletingCommentId;
                    }

                    if (comments.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return CommentCard(
                          comment: c,
                          deleting: deletingId == c.id,
                          onDeletePressed: () async {
                            final ok =
                                await _confirmDelete(context, comment: c);
                            if (ok != true || !context.mounted) return;
                            context.read<CommentsCubit>().deleteComment(c);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> _confirmDelete(
    BuildContext context, {
    required CommentEntity comment,
  }) {
    final location = (comment.chapterId == null || comment.chapterId!.isEmpty)
        ? 'comic'
        : 'chapter';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comment?'),
        content: Text('This will permanently delete this $location comment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension on CommentsCubit {
  void _initialLoadFor({
    required CommentsDialogMode mode,
    required String comicId,
    String? chapterId,
  }) {
    if (mode == CommentsDialogMode.comic) {
      loadComicComments(comicId);
    } else {
      loadChapterComments(comicId, chapterId ?? '');
    }
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No comments',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

