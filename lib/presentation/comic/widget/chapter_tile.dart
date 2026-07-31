import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';

class ChapterTile extends StatefulWidget {
  const ChapterTile({
    super.key,
    required this.comicId,
    required this.isPaidComic,
    required this.chapter,
    required this.imageUrls,
  });

  final String comicId;
  final bool isPaidComic;
  final ChapterEntity chapter;
  final List<String> imageUrls;

  @override
  State<ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<ChapterTile> {
  bool _expanded = false;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayStop() async {
    final url = widget.chapter.musicUrl;
    if (url == null || url.isEmpty) return;
    if (_isPlaying) {
      await _audioPlayer?.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    _audioPlayer ??= AudioPlayer()
      ..onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    await _audioPlayer!.setSource(UrlSource(url));
    await _audioPlayer!.resume();
    if (mounted) setState(() => _isPlaying = true);
  }

  Future<void> _pickAndUploadMusic() async {
    final picked = await AppFilePicker.pickAudioBytes();
    if (!mounted || picked == null) return;
    context.read<EditChapterCubit>().uploadMusic(
          comicId: widget.comicId,
          chapterId: widget.chapter.chapterId,
          musicBytes: picked.bytes,
        );
  }

  Future<void> _addMoreImages() async {
    final bytesList = await AppFilePicker.pickImageBytesList();
    if (!mounted || bytesList.isEmpty) return;
    context.read<EditChapterCubit>().addImages(
          comicId: widget.comicId,
          chapterId: widget.chapter.chapterId,
          imageBytesList: bytesList,
        );
  }

  Future<void> _confirmDeleteAllImages() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all images'),
        content: Text(
          'This removes every page image from "${widget.chapter.chapterName}". '
          'You can upload new pages afterward. Continue?',
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
    context.read<EditChapterCubit>().deleteAllChapterImages(
          widget.comicId,
          widget.chapter.chapterId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final imageUrls = widget.imageUrls;
    final accessLabel = !widget.isPaidComic
        ? 'Open (free comic)'
        : chapter.isFreePreview
            ? 'Free preview'
            : 'Requires purchase';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(chapter.chapterName),
            subtitle: Text(
              '${chapter.pageCount} pages • $accessLabel',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isPaidComic && !chapter.isFreePreview)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock, size: 20),
                  ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<EditChapterCubit, EditChapterState>(
                builder: (context, editState) {
                  final loading = editState is EditChapterLoading &&
                      editState.chapterId == chapter.chapterId;
                  final cubit = context.read<EditChapterCubit>();
                  final hasMusic =
                      chapter.musicUrl != null && chapter.musicUrl!.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.isPaidComic)
                            SizedBox(
                              width: 220,
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Free preview'),
                                subtitle: const Text(
                                  AppCopy.freePreviewTileSubtitle,
                                ),
                                value: chapter.isFreePreview,
                                onChanged: loading
                                    ? null
                                    : (value) => cubit.setFreePreview(
                                          comicId: widget.comicId,
                                          chapterId: chapter.chapterId,
                                          isFreePreview: value,
                                        ),
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _addMoreImages,
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: const Text('Add more images'),
                          ),
                          if (imageUrls.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed:
                                  loading ? null : _confirmDeleteAllImages,
                              icon: const Icon(Icons.delete_forever, size: 18),
                              label: const Text('Delete All Images'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (hasMusic) ...[
                            const Icon(Icons.music_note, size: 20),
                            const SizedBox(width: 8),
                            const Text('music.mp3', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: loading ? null : _togglePlayStop,
                              icon: Icon(
                                _isPlaying ? Icons.stop : Icons.play_arrow,
                              ),
                              tooltip: _isPlaying ? 'Stop' : 'Play',
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: loading ? null : _pickAndUploadMusic,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Change music'),
                            ),
                          ] else
                            OutlinedButton.icon(
                              onPressed: loading ? null : _pickAndUploadMusic,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add music'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Music is optional. MP3 recommended.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (imageUrls.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No pages yet. Tap Add more images to upload.',
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          '${imageUrls.length} page(s) in reading order',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        ...imageUrls.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Page ${e.key + 1}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
