import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_chapters_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_description_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_editable_header_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_header_section.dart';

class ComicPage extends StatelessWidget {
  const ComicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocListener<DeleteComicCubit, DeleteComicState>(
          listener: _onDeleteComicStateChanged,
          child: BlocListener<DeleteChapterCubit, DeleteChapterState>(
            listener: _onDeleteChapterStateChanged,
            child: BlocListener<EditChapterCubit, EditChapterState>(
              listener: _onEditChapterStateChanged,
              child: BlocListener<EditComicCubit, EditComicState>(
                listener: _onEditComicStateChanged,
                child: BlocBuilder<CurrentComicCubit, CurrentComicState>(
                  builder: (context, state) {
                    if (state is! CurrentComicSet) {
                      return _buildEmptyState(context);
                    }
                    return _ComicContent(comic: state.comic);
                  },
                ),
              ),
            ),
          ),
        ),
        const _ComicLoadingOverlay(),
      ],
    );
  }

  void _onDeleteComicStateChanged(
    BuildContext context,
    DeleteComicState state,
  ) {
    if (state is DeleteComicSuccess) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      context.read<CurrentComicCubit>().clear();
      if (context.mounted) Navigator.of(context).pop(true);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comic deleted')));
      }
    } else if (state is DeleteComicFailure) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onEditChapterStateChanged(
    BuildContext context,
    EditChapterState editChapterState,
  ) {
    if (editChapterState is EditChapterSuccess) {
      _applyEditedChapterToCurrentComic(context, editChapterState);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chapter updated')));
      }
    } else if (editChapterState is EditChapterImagesDeleted) {
      _applyImagesDeletedToCurrentComic(context, editChapterState.chapterId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All images deleted')));
      }
    } else if (editChapterState is EditChapterFailure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editChapterState.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _applyEditedChapterToCurrentComic(
    BuildContext context,
    EditChapterSuccess state,
  ) {
    final currentState = context.read<CurrentComicCubit>().state;
    if (currentState is! CurrentComicSet) return;
    final comic = currentState.comic;
    final index = comic.chapters.indexWhere(
      (c) => c.chapterId == state.chapterId,
    );
    if (index < 0) return;
    final chapter = comic.chapters[index];
    final updatedChapter = ChapterEntity(
      chapterId: chapter.chapterId,
      comicId: chapter.comicId,
      chapterName: chapter.chapterName,
      pageCount: state.addedImageCount != null
          ? chapter.pageCount + state.addedImageCount!
          : chapter.pageCount,
      createdDate: chapter.createdDate,
      isVip: state.isVip ?? chapter.isVip,
      musicUrl: state.musicUrl ?? chapter.musicUrl,
    );
    final newChapters = List<ChapterEntity>.from(comic.chapters);
    newChapters[index] = updatedChapter;
    context.read<CurrentComicCubit>().setComic(
      ComicEntity(
        comicId: comic.comicId,
        title: comic.title,
        description: comic.description,
        image: comic.image,
        likeCount: comic.likeCount,
        readCount: comic.readCount,
        chapterCount: comic.chapterCount,
        createdDate: comic.createdDate,
        categoryId: comic.categoryId,
        categoryName: comic.categoryName,
        chapters: newChapters,
      ),
    );
  }

  void _applyImagesDeletedToCurrentComic(
    BuildContext context,
    String chapterId,
  ) {
    final currentState = context.read<CurrentComicCubit>().state;
    if (currentState is! CurrentComicSet) return;
    final comic = currentState.comic;
    final index = comic.chapters.indexWhere((c) => c.chapterId == chapterId);
    if (index < 0) return;
    final chapter = comic.chapters[index];
    final updatedChapter = ChapterEntity(
      chapterId: chapter.chapterId,
      comicId: chapter.comicId,
      chapterName: chapter.chapterName,
      pageCount: 0,
      createdDate: chapter.createdDate,
      isVip: chapter.isVip,
      musicUrl: chapter.musicUrl,
    );
    final newChapters = List<ChapterEntity>.from(comic.chapters);
    newChapters[index] = updatedChapter;
    context.read<CurrentComicCubit>().setComic(
      ComicEntity(
        comicId: comic.comicId,
        title: comic.title,
        description: comic.description,
        image: comic.image,
        likeCount: comic.likeCount,
        readCount: comic.readCount,
        chapterCount: comic.chapterCount,
        createdDate: comic.createdDate,
        categoryId: comic.categoryId,
        categoryName: comic.categoryName,
        chapters: newChapters,
      ),
    );
  }

  void _onDeleteChapterStateChanged(
    BuildContext context,
    DeleteChapterState deleteState,
  ) {
    if (deleteState is DeleteChapterSuccess) {
      _applyDeletedChapterToCurrentComic(context);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Last chapter deleted')));
      }
    } else if (deleteState is DeleteChapterFailure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteState.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onEditComicStateChanged(
    BuildContext context,
    EditComicState editState,
  ) {
    if (editState is EditComicSuccess) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comic updated')));
      }
    } else if (editState is EditComicFailure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editState.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _applyDeletedChapterToCurrentComic(BuildContext context) {
    final currentState = context.read<CurrentComicCubit>().state;
    if (currentState is! CurrentComicSet) return;
    final comic = currentState.comic;
    if (comic.chapters.isEmpty) return;
    final newChapters = comic.chapters.sublist(0, comic.chapters.length - 1);
    context.read<CurrentComicCubit>().setComic(
      ComicEntity(
        comicId: comic.comicId,
        title: comic.title,
        description: comic.description,
        image: comic.image,
        likeCount: comic.likeCount,
        readCount: comic.readCount,
        chapterCount: newChapters.length,
        createdDate: comic.createdDate,
        categoryId: comic.categoryId,
        categoryName: comic.categoryName,
        chapters: newChapters,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comic')),
      body: const Center(child: Text('No comic selected')),
    );
  }
}

class _ComicContent extends StatefulWidget {
  const _ComicContent({required this.comic});

  final ComicEntity comic;

  @override
  State<_ComicContent> createState() => _ComicContentState();
}

class _ComicContentState extends State<_ComicContent> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<int>? _newImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comic.title);
    _descriptionController = TextEditingController(
      text: widget.comic.description,
    );
  }

  @override
  void didUpdateWidget(covariant _ComicContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comic.comicId != widget.comic.comicId) {
      _titleController.text = widget.comic.title;
      _descriptionController.text = widget.comic.description;
      _newImageBytes = null;
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _titleController.text = widget.comic.title;
      _descriptionController.text = widget.comic.description;
      _newImageBytes = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _titleController.text = widget.comic.title;
      _descriptionController.text = widget.comic.description;
      _newImageBytes = null;
    });
  }

  Future<void> _confirmAndDeleteComic() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comic'),
        content: const Text(
          'This will permanently delete the comic and all its chapters and images from the database and storage. Continue?',
        ),
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
    if (ok != true || !mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
    if (!mounted) return;
    context.read<DeleteComicCubit>().deleteComic(widget.comic.comicId);
  }

  void _saveEditing() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    context.read<EditComicCubit>().updateComic(
      UpdateComicParams(
        comicId: widget.comic.comicId,
        title: title,
        description: _descriptionController.text.trim(),
        oldImageFilename: widget.comic.image.isNotEmpty
            ? widget.comic.image
            : null,
        newImageBytes: _newImageBytes,
      ),
    );
  }

  void _onEditSuccess() {
    final comic = widget.comic;
    final newImage = _newImageBytes != null && _newImageBytes!.isNotEmpty
        ? '${comic.comicId}_cover.jpg'
        : comic.image;
    context.read<CurrentComicCubit>().setComic(
      ComicEntity(
        comicId: comic.comicId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        image: newImage,
        likeCount: comic.likeCount,
        readCount: comic.readCount,
        chapterCount: comic.chapterCount,
        createdDate: comic.createdDate,
        categoryId: comic.categoryId,
        categoryName: comic.categoryName,
        chapters: comic.chapters,
      ),
    );
    setState(() {
      _isEditing = false;
      _newImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comic = widget.comic;
    final imageUrl = comic.image.isNotEmpty
        ? ImageDisplayHelper.generateComicImageURL(comic.image)
        : ImageDisplayHelper.generateComicImageURL(comic.title);

    return BlocListener<EditComicCubit, EditComicState>(
      listener: (context, state) {
        if (state is EditComicSuccess) _onEditSuccess();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit comic' : comic.title),
          actions: [
            if (_isEditing) ...[
              TextButton(
                onPressed: _cancelEditing,
                child: const Text('Cancel'),
              ),
              BlocBuilder<EditComicCubit, EditComicState>(
                builder: (context, state) {
                  final loading = state is EditComicLoading;
                  return FilledButton(
                    onPressed: loading ? null : _saveEditing,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  );
                },
              ),
              const SizedBox(width: 8),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _confirmAndDeleteComic,
                tooltip: 'Delete comic',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _startEditing,
                tooltip: 'Edit comic',
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isEditing)
                ComicEditableHeaderSection(
                  comic: comic,
                  imageUrl: imageUrl,
                  titleController: _titleController,
                  onImagePicked: (bytes) =>
                      setState(() => _newImageBytes = bytes),
                  newImageBytes: _newImageBytes,
                )
              else
                ComicHeaderSection(comic: comic, imageUrl: imageUrl),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                )
              else
                ComicDescriptionSection(description: comic.description),
              ComicChaptersSection(comic: comic),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tam ekran loading overlay; comic sayfasındaki bekleme gerektiren işlemler için.
class _ComicLoadingOverlay extends StatelessWidget {
  const _ComicLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final deleteComicLoading =
        context.watch<DeleteComicCubit>().state is DeleteComicLoading;
    final deleteChapterLoading =
        context.watch<DeleteChapterCubit>().state is DeleteChapterLoading;
    final editChapterLoading =
        context.watch<EditChapterCubit>().state is EditChapterLoading;
    final editComicLoading =
        context.watch<EditComicCubit>().state is EditComicLoading;
    final addChapterLoading =
        context.watch<AddChapterCubit>().state is AddChapterLoading;
    final isLoading = deleteComicLoading ||
        deleteChapterLoading ||
        editChapterLoading ||
        editComicLoading ||
        addChapterLoading;

    if (!isLoading) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
