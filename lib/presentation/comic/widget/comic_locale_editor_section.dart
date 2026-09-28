import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/common/helper/images/storage_network_image.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/add_chapter_dialog.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/locale_chapter_tile.dart';

/// Non-English locale editor: metadata + cover + independent chapters.
class ComicLocaleEditorSection extends StatefulWidget {
  const ComicLocaleEditorSection({
    super.key,
    required this.comic,
    required this.locale,
  });

  final ComicEntity comic;
  final String locale;

  @override
  State<ComicLocaleEditorSection> createState() =>
      _ComicLocaleEditorSectionState();
}

class _ComicLocaleEditorSectionState extends State<ComicLocaleEditorSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final overlay = widget.comic.locales[widget.locale];
    _titleController = TextEditingController(text: overlay?.title ?? '');
    _descriptionController =
        TextEditingController(text: overlay?.description ?? '');
    _categoryController =
        TextEditingController(text: overlay?.categoryName ?? '');
    _titleController.addListener(_syncDirty);
    _descriptionController.addListener(_syncDirty);
    _categoryController.addListener(_syncDirty);
  }

  @override
  void didUpdateWidget(covariant ComicLocaleEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale ||
        oldWidget.comic.comicId != widget.comic.comicId) {
      final overlay = widget.comic.locales[widget.locale];
      _titleController.text = overlay?.title ?? '';
      _descriptionController.text = overlay?.description ?? '';
      _categoryController.text = overlay?.categoryName ?? '';
      _syncDirty();
      return;
    }
    final oldOverlay = oldWidget.comic.locales[widget.locale];
    final overlay = widget.comic.locales[widget.locale];
    if (oldOverlay?.title != overlay?.title ||
        oldOverlay?.description != overlay?.description ||
        oldOverlay?.categoryName != overlay?.categoryName) {
      _titleController.text = overlay?.title ?? '';
      _descriptionController.text = overlay?.description ?? '';
      _categoryController.text = overlay?.categoryName ?? '';
      _syncDirty();
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_syncDirty);
    _descriptionController.removeListener(_syncDirty);
    _categoryController.removeListener(_syncDirty);
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _syncDirty() {
    final overlay = widget.comic.locales[widget.locale];
    final dirty = _titleController.text != (overlay?.title ?? '') ||
        _descriptionController.text != (overlay?.description ?? '') ||
        _categoryController.text != (overlay?.categoryName ?? '');
    if (!mounted) return;
    context.read<ComicLocaleCubit>().setMetadataDirty(dirty);
  }

  void _copyFromEnglish() {
    _titleController.text = widget.comic.title;
    _descriptionController.text = widget.comic.description;
    _categoryController.text = widget.comic.categoryName;
  }

  Future<void> _pickCover() async {
    final bytes = await AppFilePicker.pickImageBytes();
    if (bytes == null || bytes.isEmpty || !mounted) return;
    context.read<ComicLocaleCubit>().uploadCover(
          comicId: widget.comic.comicId,
          imageBytes: bytes,
        );
  }

  Future<void> _confirmClearCover() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove locale cover'),
        content: const Text(
          'This removes the translated cover. The English cover will be shown '
          'in the app for this language.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<ComicLocaleCubit>().clearCover(widget.comic.comicId);
  }

  Future<void> _confirmDeleteLocale() async {
    final name = AppLocales.nativeName(widget.locale);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $name locale'),
        content: Text(
          'This permanently deletes all $name metadata, cover, chapters, '
          'and Storage files under Comics/${widget.comic.comicId}/${widget.locale}/. '
          'English content is not affected.',
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
            child: const Text('Delete locale'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<ComicLocaleCubit>().deleteLocale(widget.comic.comicId);
  }

  Future<void> _openAddChapter() async {
    final addChapterCubit = context.read<AddChapterCubit>()
      ..prepareForComic(widget.comic, locale: widget.locale);
    final currentComicCubit = context.read<CurrentComicCubit>();
    await showDialog<bool>(
      context: context,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider<AddChapterCubit>.value(value: addChapterCubit),
          BlocProvider<CurrentComicCubit>.value(value: currentComicCubit),
        ],
        child: AddChapterDialog(
          comic: widget.comic,
          locale: widget.locale,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteLastChapter() async {
    final chapters = widget.comic.locales[widget.locale]?.chapters ?? const [];
    if (chapters.isEmpty) return;
    final last = chapters.last;
    final localeName = AppLocales.nativeName(widget.locale);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete last $localeName chapter'),
        content: Text(
          'This deletes only the last $localeName chapter: '
          '"${last.chapterName}". Its page images and music will also be '
          'removed. English chapters are not affected.',
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
    if (ok != true || !mounted) return;
    context.read<DeleteChapterCubit>().deleteLastChapter(
          widget.comic.comicId,
          locale: widget.locale,
        );
  }

  @override
  Widget build(BuildContext context) {
    final localeName = AppLocales.nativeName(widget.locale);
    final overlay = widget.comic.locales[widget.locale];
    final localeChapters = overlay?.chapters ?? const [];
    final hasLocaleCover = overlay?.hasCover == true;
    final coverField =
        hasLocaleCover ? overlay!.image : widget.comic.image;
    final coverUrl = coverField.isNotEmpty
        ? ImageDisplayHelper.generateComicImageURL(coverField)
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<ComicLocaleCubit, ComicLocaleState>(
        builder: (context, state) {
          final loading = state.isLoading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$localeName content',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Translate metadata and optional cover. Chapters for $localeName '
                'are independent — they do not fall back to English. '
                'Missing cover falls back to English.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cover',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 96,
                      height: 128,
                      child: coverUrl != null
                          ? StorageNetworkImage(
                              url: coverUrl,
                              fit: BoxFit.cover,
                            )
                          : ColoredBox(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasLocaleCover
                              ? 'Using $localeName cover'
                              : 'Using English cover (fallback)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: loading ? null : _pickCover,
                              icon: const Icon(Icons.upload, size: 18),
                              label: Text(
                                hasLocaleCover
                                    ? 'Replace cover'
                                    : 'Upload cover',
                              ),
                            ),
                            if (hasLocaleCover)
                              OutlinedButton.icon(
                                onPressed: loading ? null : _confirmClearCover,
                                icon: const Icon(Icons.hide_image, size: 18),
                                label: const Text('Use English cover'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                enabled: !loading,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  border: OutlineInputBorder(),
                ),
                enabled: !loading,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: loading
                        ? null
                        : () => context.read<ComicLocaleCubit>().saveMetadata(
                              comicId: widget.comic.comicId,
                              title: _titleController.text,
                              description: _descriptionController.text,
                              categoryName: _categoryController.text,
                            ),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save locale metadata'),
                  ),
                  OutlinedButton.icon(
                    onPressed: loading ? null : _copyFromEnglish,
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Copy from English'),
                  ),
                  if (overlay != null)
                    OutlinedButton.icon(
                      onPressed: loading ? null : _confirmDeleteLocale,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete locale'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Chapters (${localeChapters.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Independent of English. If empty, the app shows “Coming soon” '
                'for this language.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 8),
              if (localeChapters.isEmpty)
                Text(
                  'No $localeName chapters yet. Tap Add Chapter to upload pages.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                )
              else
                ...localeChapters.map(
                  (ch) => LocaleChapterTile(
                    comic: widget.comic,
                    chapter: ch,
                  ),
                ),
              const SizedBox(height: 12),
              BlocBuilder<DeleteChapterCubit, DeleteChapterState>(
                builder: (context, deleteState) {
                  final isDeleting = deleteState is DeleteChapterLoading;
                  final isAdding =
                      context.watch<AddChapterCubit>().state.isLoading;
                  return Row(
                    children: [
                      FilledButton.icon(
                        onPressed: isAdding ? null : _openAddChapter,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Chapter'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: localeChapters.isEmpty || isDeleting
                            ? null
                            : _confirmDeleteLastChapter,
                        icon: isDeleting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.delete_outline, size: 20),
                        label: Text(
                          isDeleting ? 'Deleting...' : 'Delete last chapter',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
