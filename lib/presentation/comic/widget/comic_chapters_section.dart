import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/widgets/info_tip.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/add_chapter_dialog.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/chapter_tile.dart';

class ComicChaptersSection extends StatelessWidget {
  const ComicChaptersSection({super.key, required this.comic});

  final ComicEntity comic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chapters (${comic.chapters.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const InfoTip(message: AppCopy.chaptersTip),
          const SizedBox(height: 12),
          if (comic.chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No chapters yet. Tap Add Chapter to upload page images.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            )
          else
            ...comic.chapters.map(
              (ch) => ChapterTile(
                comicId: comic.comicId,
                isPaidComic: !comic.isFree,
                chapter: ch,
                imageUrls: ImageDisplayHelper.generateChapterImageURLs(ch),
              ),
            ),
          const SizedBox(height: 16),
          _ChapterActions(comic: comic),
        ],
      ),
    );
  }
}

class _ChapterActions extends StatelessWidget {
  const _ChapterActions({required this.comic});

  final ComicEntity comic;

  Future<void> _openAddChapter(BuildContext context) async {
    final addChapterCubit = context.read<AddChapterCubit>()
      ..prepareForComic(comic);
    final currentComicCubit = context.read<CurrentComicCubit>();
    await showDialog<bool>(
      context: context,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider<AddChapterCubit>.value(value: addChapterCubit),
          BlocProvider<CurrentComicCubit>.value(value: currentComicCubit),
        ],
        child: AddChapterDialog(comic: comic),
      ),
    );
  }

  Future<void> _confirmDeleteLastChapter(BuildContext context) async {
    final last = comic.chapters.isEmpty ? null : comic.chapters.last;
    if (last == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete last chapter'),
        content: Text(
          'This deletes only the last chapter: "${last.chapterName}". '
          'Its page images and music will also be removed. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<DeleteChapterCubit>().deleteLastChapter(comic.comicId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteChapterCubit, DeleteChapterState>(
      builder: (context, deleteState) {
        final isDeleting = deleteState is DeleteChapterLoading;
        final isAdding = context.watch<AddChapterCubit>().state.isLoading;
        return Row(
          children: [
            FilledButton.icon(
              onPressed: isAdding ? null : () => _openAddChapter(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Chapter'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: comic.chapters.isEmpty || isDeleting
                  ? null
                  : () => _confirmDeleteLastChapter(context),
              icon: isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.delete_outline, size: 20),
              label: Text(isDeleting ? 'Deleting...' : 'Delete last chapter'),
            ),
          ],
        );
      },
    );
  }
}
