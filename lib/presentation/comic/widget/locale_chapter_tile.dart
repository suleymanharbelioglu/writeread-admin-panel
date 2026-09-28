import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_state.dart';

class LocaleChapterTile extends StatefulWidget {
  const LocaleChapterTile({
    super.key,
    required this.comic,
    required this.chapter,
  });

  final ComicEntity comic;
  final ChapterLocaleContent chapter;

  @override
  State<LocaleChapterTile> createState() => _LocaleChapterTileState();
}

class _LocaleChapterTileState extends State<LocaleChapterTile> {
  bool _expanded = false;
  late final TextEditingController _nameController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chapter.chapterName);
  }

  @override
  void didUpdateWidget(covariant LocaleChapterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.chapterName != widget.chapter.chapterName &&
        widget.chapter.chapterName != _nameController.text) {
      _nameController.text = widget.chapter.chapterName;
    }
  }

  @override
  void dispose() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _nameController.dispose();
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

  Future<void> _uploadPages() async {
    final bytesList = await AppFilePicker.pickImageBytesList();
    if (!mounted || bytesList.isEmpty) return;
    context.read<ComicLocaleCubit>().uploadPages(
          comicId: widget.comic.comicId,
          chapterId: widget.chapter.chapterId,
          imageBytesList: bytesList,
          chapterName: _nameController.text.trim(),
        );
  }

  Future<void> _uploadMusic() async {
    final picked = await AppFilePicker.pickAudioBytes();
    if (!mounted || picked == null) return;
    context.read<ComicLocaleCubit>().uploadMusic(
          comicId: widget.comic.comicId,
          chapterId: widget.chapter.chapterId,
          musicBytes: picked.bytes,
          chapterName: _nameController.text.trim(),
        );
  }

  Future<void> _confirmClearPages() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear pages'),
        content: Text(
          'This removes all page images and music for '
          '"${widget.chapter.chapterName}" in this language. Continue?',
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
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<ComicLocaleCubit>().clearPages(
          comicId: widget.comic.comicId,
          chapterId: widget.chapter.chapterId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final pageCount = widget.chapter.pageCount;
    final hasMusic = widget.chapter.musicUrl != null &&
        widget.chapter.musicUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.chapter.chapterName),
            subtitle: Text(
              '$pageCount pages • ${widget.chapter.chapterId}'
              '${widget.chapter.isFreePreview ? ' • free preview' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<ComicLocaleCubit, ComicLocaleState>(
                builder: (context, state) {
                  final loading = state.isLoading &&
                      state.chapterId == widget.chapter.chapterId;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Chapter name',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        enabled: !loading,
                      ),
                      const SizedBox(height: 8),
                      if (!widget.comic.isFree)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Free preview'),
                          value: widget.chapter.isFreePreview,
                          onChanged: loading
                              ? null
                              : (v) => context
                                  .read<ComicLocaleCubit>()
                                  .setFreePreview(
                                    comic: widget.comic,
                                    chapterId: widget.chapter.chapterId,
                                    isFreePreview: v,
                                  ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: loading
                              ? null
                              : () => context
                                  .read<ComicLocaleCubit>()
                                  .saveChapterName(
                                    comic: widget.comic,
                                    chapterId: widget.chapter.chapterId,
                                    chapterName: _nameController.text.trim(),
                                  ),
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save chapter name'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: loading ? null : _uploadPages,
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Upload more pages'),
                          ),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _uploadMusic,
                            icon: const Icon(Icons.music_note, size: 18),
                            label: Text(
                              hasMusic ? 'Replace music' : 'Upload music',
                            ),
                          ),
                          if (pageCount > 0 || hasMusic)
                            OutlinedButton.icon(
                              onPressed: loading ? null : _confirmClearPages,
                              icon: const Icon(Icons.delete_forever, size: 18),
                              label: const Text('Clear pages'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            ),
                          if (hasMusic)
                            IconButton(
                              onPressed: loading ? null : _togglePlayStop,
                              icon: Icon(
                                _isPlaying ? Icons.stop : Icons.play_arrow,
                              ),
                              tooltip: _isPlaying ? 'Stop' : 'Play music',
                            ),
                        ],
                      ),
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
