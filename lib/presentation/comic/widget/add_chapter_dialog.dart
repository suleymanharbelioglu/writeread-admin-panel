import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_feedback.dart';
import 'package:writeread_admin_panel/common/widgets/info_tip.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';

class AddChapterDialog extends StatefulWidget {
  const AddChapterDialog({
    super.key,
    required this.comic,
    this.locale = AppLocales.english,
  });

  final ComicEntity comic;
  final String locale;

  @override
  State<AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<AddChapterDialog> {
  late final TextEditingController _nameController;

  int get _nextChapterNumber {
    if (AppLocales.isEnglish(widget.locale)) {
      return widget.comic.chapters.length + 1;
    }
    return (widget.comic.locales[widget.locale]?.chapters.length ?? 0) + 1;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Chapter $_nextChapterNumber');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await AppFilePicker.pickImageBytesList();
    if (!mounted || images.isEmpty) return;
    context.read<AddChapterCubit>().setImages(images);
  }

  Future<void> _pickMusic() async {
    final picked = await AppFilePicker.pickAudioBytes();
    if (!mounted || picked == null) return;
    context.read<AddChapterCubit>().setMusic(
          bytes: picked.bytes,
          fileName: picked.name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final localeName = AppLocales.isEnglish(widget.locale)
        ? 'English'
        : AppLocales.nativeName(widget.locale);

    return BlocConsumer<AddChapterCubit, AddChapterState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == AddChapterStatus.success ||
              curr.status == AddChapterStatus.failure),
      listener: (context, state) {
        if (state.status == AddChapterStatus.success &&
            state.successChapter != null) {
          final chapter = state.successChapter!;
          if (AppLocales.isEnglish(widget.locale)) {
            context.read<CurrentComicCubit>().appendChapter(chapter);
          } else {
            context.read<CurrentComicCubit>().appendLocaleChapter(
                  locale: widget.locale,
                  chapter: chapter,
                );
          }
          AppFeedback.showSuccess(context, 'Chapter added ($localeName)');
          AppNavigator.pop(context, true);
          return;
        }
        if (state.status == AddChapterStatus.failure &&
            state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddChapterCubit>();
        final loading = state.isLoading;

        return AlertDialog(
          title: Text('Add Chapter ($localeName)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoTip(
                  message: AppLocales.isEnglish(widget.locale)
                      ? AppCopy.addChapterTip
                      : 'Adds a chapter only for $localeName. '
                          'Other languages keep their own chapter lists.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'Chapter name',
                    hintText: 'e.g. Chapter 7',
                    helperText: 'Shown to readers in the chapter list.',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                if (state.showFreePreviewToggle)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Free preview'),
                    subtitle: const Text(AppCopy.freePreviewSubtitle),
                    value: state.isFreePreview,
                    onChanged: loading ? null : cubit.setFreePreview,
                  ),
                if (state.showFreePreviewToggle) const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: loading ? null : _pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick images'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add pages in reading order. At least one image is required.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                if (state.imageCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${state.imageCount} image(s) selected',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: loading ? null : _pickMusic,
                  icon: const Icon(Icons.music_note),
                  label: Text(
                    state.musicFileName == null
                        ? 'Pick chapter music (optional)'
                        : 'Music: ${state.musicFileName}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Optional. MP3 recommended.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  loading ? null : () => AppNavigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () => cubit.submit(chapterName: _nameController.text),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
