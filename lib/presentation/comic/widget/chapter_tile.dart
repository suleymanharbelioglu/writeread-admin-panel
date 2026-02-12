import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter_params.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';

class ChapterTile extends StatefulWidget {
  const ChapterTile({
    super.key,
    required this.comicId,
    required this.chapter,
    required this.imageUrls,
  });

  final String comicId;
  final ChapterEntity chapter;
  final List<String> imageUrls;

  @override
  State<ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<ChapterTile> {
  bool _expanded = false;

  Future<void> _addMoreImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytesList = result.files
        .where((f) => f.bytes != null && f.bytes!.lengthInBytes > 0)
        .map((f) => f.bytes!.buffer.asUint8List().toList())
        .toList();
    if (bytesList.isEmpty) return;
    if (!mounted) return;
    context.read<EditChapterCubit>().updateChapter(UpdateChapterParams(
          comicId: widget.comicId,
          chapterId: widget.chapter.chapterId,
          additionalImageBytesList: bytesList,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final imageUrls = widget.imageUrls;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(chapter.chapterName),
            subtitle: Text(
              '${chapter.pageCount} pages • ${chapter.isVip ? "VIP" : "Free"}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (chapter.isVip) const Icon(Icons.lock, size: 20),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<EditChapterCubit, EditChapterState>(
                    buildWhen: (prev, curr) => prev != curr,
                    builder: (context, editState) {
                      final loading = editState is EditChapterLoading &&
                          editState.chapterId == chapter.chapterId;
                      return Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: SwitchListTile(
                              value: chapter.isVip,
                              onChanged: loading
                                  ? null
                                  : (value) {
                                      context.read<EditChapterCubit>().updateChapter(
                                            UpdateChapterParams(
                                              comicId: widget.comicId,
                                              chapterId: chapter.chapterId,
                                              isVip: value,
                                            ),
                                          );
                                    },
                              title: const Text('VIP'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _addMoreImages,
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: const Text('Add more images'),
                          ),
                          if (imageUrls.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: loading
                                  ? null
                                  : () {
                                      context.read<EditChapterCubit>().deleteAllChapterImages(
                                            widget.comicId,
                                            chapter.chapterId,
                                          );
                                    },
                              icon: const Icon(Icons.delete_forever, size: 18),
                              label: const Text('Delete All Images'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (imageUrls.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No image yet'),
                      ),
                    )
                  else
                    ...imageUrls.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Page ${e.key + 1}:',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SelectableText(
                              e.value,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
