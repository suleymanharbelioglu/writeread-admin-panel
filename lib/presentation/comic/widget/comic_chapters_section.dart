import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';
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
          if (comic.chapters.isNotEmpty)
            ...comic.chapters.map(
              (ch) => ChapterTile(
                comicId: comic.comicId,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteChapterCubit, DeleteChapterState>(
      builder: (context, deleteState) {
        final isDeleting = deleteState is DeleteChapterLoading;
        final isAdding =
            context.watch<AddChapterCubit>().state is AddChapterLoading;
        return Row(
          children: [
            FilledButton.icon(
              onPressed: isAdding
                  ? null
                  : () {
                      final addChapterCubit = context.read<AddChapterCubit>();
                      final currentComicCubit = context
                          .read<CurrentComicCubit>();
                      showDialog<bool>(
                        context: context,
                        builder: (ctx) => MultiBlocProvider(
                          providers: [
                            BlocProvider<AddChapterCubit>.value(
                              value: addChapterCubit,
                            ),
                            BlocProvider<CurrentComicCubit>.value(
                              value: currentComicCubit,
                            ),
                          ],
                          child: AddChapterDialog(comic: comic),
                        ),
                      );
                    },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Chapter'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: comic.chapters.isEmpty || isDeleting
                  ? null
                  : () => context.read<DeleteChapterCubit>().deleteLastChapter(
                      comic.comicId,
                    ),
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
              label: Text(isDeleting ? 'Deleting...' : 'Delete Chapter'),
            ),
          ],
        );
      },
    );
  }
}
