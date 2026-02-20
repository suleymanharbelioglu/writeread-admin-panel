import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter_params.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';

class AddChapterDialog extends StatefulWidget {
  const AddChapterDialog({super.key, required this.comic});

  final ComicEntity comic;

  @override
  State<AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<AddChapterDialog> {
  late final TextEditingController _nameController;
  bool _isVip = true;
  List<PlatformFile> _pickedFiles = [];
  PlatformFile? _pickedMusicFile;

  @override
  void initState() {
    super.initState();
    final nextNumber = widget.comic.chapters.length + 1;
    _nameController = TextEditingController(text: 'Chapter $nextNumber');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _pickedFiles = result.files
          .where((f) => f.bytes != null && f.bytes!.lengthInBytes > 0)
          .toList();
    });
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes == null || file.bytes!.lengthInBytes == 0) return;
    setState(() => _pickedMusicFile = file);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter chapter name')),
      );
      return;
    }
    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one image')),
      );
      return;
    }
    final imageBytesList = _pickedFiles
        .map((f) => f.bytes!.buffer.asUint8List().toList())
        .toList();
    final musicBytes = _pickedMusicFile?.bytes != null
        ? _pickedMusicFile!.bytes!.buffer.asUint8List().toList()
        : null;
    context.read<AddChapterCubit>().addChapter(AddChapterParams(
          comicId: widget.comic.comicId,
          chapterName: name,
          imageBytesList: imageBytesList,
          isVip: _isVip,
          musicBytes: musicBytes,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddChapterCubit, AddChapterState>(
      listener: (context, state) {
        if (state is AddChapterSuccess) {
          _applyNewChapterToCurrentComic(context, state);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chapter added')),
            );
            Navigator.of(context).pop(true);
          }
        } else if (state is AddChapterFailure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: AlertDialog(
        title: const Text('Add Chapter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Chapter name',
                  hintText: 'e.g. Chapter 7',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _isVip,
                onChanged: (v) => setState(() => _isVip = v ?? false),
                title: const Text('VIP chapter'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick images'),
              ),
              if (_pickedFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_pickedFiles.length} image(s) selected',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickMusic,
                icon: const Icon(Icons.music_note),
                label: Text(_pickedMusicFile == null
                    ? 'Pick chapter music (optional)'
                    : 'Music: ${_pickedMusicFile!.name}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          BlocBuilder<AddChapterCubit, AddChapterState>(
            builder: (context, state) {
              final loading = state is AddChapterLoading;
              return FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _applyNewChapterToCurrentComic(BuildContext context, AddChapterSuccess state) {
    final currentState = context.read<CurrentComicCubit>().state;
    if (currentState is! CurrentComicSet) return;
    final comic = currentState.comic;
    final newChapterId = 'chapter${comic.chapters.length + 1}';
    final newChapter = ChapterEntity(
      chapterId: newChapterId,
      comicId: comic.comicId,
      chapterName: state.chapterName,
      pageCount: state.pageCount,
      createdDate: Timestamp.now(),
      isVip: state.isVip,
      musicUrl: state.musicUrl,
    );
    final updatedChapters = [...comic.chapters, newChapter];
    context.read<CurrentComicCubit>().setComic(ComicEntity(
          comicId: comic.comicId,
          title: comic.title,
          description: comic.description,
          image: comic.image,
          likeCount: comic.likeCount,
          readCount: comic.readCount,
          chapterCount: updatedChapters.length,
          createdDate: comic.createdDate,
          categoryId: comic.categoryId,
          categoryName: comic.categoryName,
          chapters: updatedChapters,
        ));
  }
}
