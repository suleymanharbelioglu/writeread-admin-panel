import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_feedback.dart';
import 'package:writeread_admin_panel/common/widgets/loading_overlay.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_last_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_content_type.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_form_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_form_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_chapters_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_description_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_editable_header_section.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_header_section.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class ComicPage extends StatelessWidget {
  const ComicPage({super.key});

  /// Feature-scoped providers for the comic detail flow.
  static Widget route(ComicEntity comic) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CurrentComicCubit(initialComic: comic)),
        BlocProvider(
          create: (_) => DeleteChapterCubit(
            deleteLastChapterUseCase: sl<DeleteLastChapterUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) =>
              DeleteComicCubit(deleteComicUseCase: sl<DeleteComicUseCase>()),
        ),
        BlocProvider(
          create: (_) =>
              AddChapterCubit(addChapterUseCase: sl<AddChapterUseCase>()),
        ),
        BlocProvider(
          create: (_) =>
              EditComicCubit(updateComicUseCase: sl<UpdateComicUseCase>()),
        ),
        BlocProvider(
          create: (_) => EditChapterCubit(
            updateChapterUseCase: sl<UpdateChapterUseCase>(),
            deleteAllChapterImagesUseCase: sl<DeleteAllChapterImagesUseCase>(),
          ),
        ),
      ],
      child: const ComicPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<DeleteComicCubit>().state is DeleteComicLoading ||
            context.watch<DeleteChapterCubit>().state is DeleteChapterLoading ||
            context.watch<EditChapterCubit>().state is EditChapterLoading ||
            context.watch<EditComicCubit>().state is EditComicLoading ||
            context.watch<AddChapterCubit>().state.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: isLoading ? 'Please wait...' : null,
      child: MultiBlocListener(
        listeners: [
          BlocListener<DeleteComicCubit, DeleteComicState>(
            listener: (context, state) {
              if (state is DeleteComicSuccess) {
                context.read<CurrentComicCubit>().clear();
                if (context.mounted) AppNavigator.pop(context, true);
                if (context.mounted) {
                  AppFeedback.showSuccess(context, 'Comic deleted');
                }
              } else if (state is DeleteComicFailure) {
                if (context.mounted) {
                  AppFeedback.showError(context, state.message);
                }
              }
            },
          ),
          BlocListener<DeleteChapterCubit, DeleteChapterState>(
            listener: (context, state) {
              if (state is DeleteChapterSuccess) {
                context.read<CurrentComicCubit>().removeLastChapter();
                AppFeedback.showSuccess(context, 'Last chapter deleted');
              } else if (state is DeleteChapterFailure) {
                AppFeedback.showError(context, state.message);
              }
            },
          ),
          BlocListener<EditChapterCubit, EditChapterState>(
            listener: (context, state) {
              final current = context.read<CurrentComicCubit>();
              if (state is EditChapterSuccess) {
                current.applyChapterEdit(
                  chapterId: state.chapterId,
                  isFreePreview: state.isFreePreview,
                  addedImageCount: state.addedImageCount,
                  musicUrl: state.musicUrl,
                );
                AppFeedback.showSuccess(context, 'Chapter updated');
              } else if (state is EditChapterImagesDeleted) {
                current.clearChapterImages(state.chapterId);
                AppFeedback.showSuccess(context, 'All images deleted');
              } else if (state is EditChapterFailure) {
                AppFeedback.showError(context, state.message);
              }
            },
          ),
          BlocListener<EditComicCubit, EditComicState>(
            listener: (context, state) {
              if (state is EditComicSuccess) {
                AppFeedback.showSuccess(context, 'Comic updated');
              } else if (state is EditComicFailure) {
                AppFeedback.showError(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<CurrentComicCubit, CurrentComicState>(
          builder: (context, state) {
            if (state is! CurrentComicSet) {
              return Scaffold(
                appBar: AppBar(title: const Text('Comic')),
                body: const Center(child: Text('No comic selected')),
              );
            }
            return BlocProvider(
              key: ValueKey(state.comic.comicId),
              create: (ctx) => EditComicFormCubit(
                editComicCubit: ctx.read<EditComicCubit>(),
              )..resetFromComic(state.comic),
              child: _ComicContent(comic: state.comic),
            );
          },
        ),
      ),
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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _productIdController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.comic.title);
    _descriptionController =
        TextEditingController(text: widget.comic.description);
    _productIdController =
        TextEditingController(text: widget.comic.productId);
  }

  @override
  void didUpdateWidget(covariant _ComicContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comic.comicId != widget.comic.comicId) {
      _titleController.text = widget.comic.title;
      _descriptionController.text = widget.comic.description;
      _productIdController.text = widget.comic.productId;
      context.read<EditComicFormCubit>().resetFromComic(widget.comic);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDeleteComic() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comic'),
        content: const Text(
          'This permanently deletes the comic, all chapters, page images, '
          'and cover files from the database and storage. This cannot be undone.',
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
    context.read<DeleteComicCubit>().deleteComic(widget.comic.comicId);
  }

  @override
  Widget build(BuildContext context) {
    final comic = widget.comic;
    final imageUrl = comic.image.isNotEmpty
        ? ImageDisplayHelper.generateComicImageURL(comic.image)
        : ImageDisplayHelper.generateComicImageURL(comic.title);

    return MultiBlocListener(
      listeners: [
        BlocListener<EditComicCubit, EditComicState>(
          listener: (context, state) {
            if (state is EditComicSuccess) {
              context.read<EditComicFormCubit>().applyPersistSuccess(
                    currentComic: context.read<CurrentComicCubit>(),
                    updatedComic: state.comic,
                  );
            }
          },
        ),
        BlocListener<EditComicFormCubit, EditComicFormState>(
          listenWhen: (prev, curr) =>
              curr.validationError != null &&
              curr.validationError != prev.validationError,
          listener: (context, state) {
            if (state.validationError != null) {
              AppFeedback.showError(context, state.validationError!);
            }
          },
        ),
      ],
      child: BlocBuilder<EditComicFormCubit, EditComicFormState>(
        builder: (context, form) {
          final formCubit = context.read<EditComicFormCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(form.isEditing ? 'Edit comic' : comic.title),
              actions: [
                if (form.isEditing) ...[
                  TextButton(
                    onPressed: () {
                      _titleController.text = comic.title;
                      _descriptionController.text = comic.description;
                      _productIdController.text = comic.productId;
                      formCubit.cancel(comic);
                    },
                    child: const Text('Cancel'),
                  ),
                  BlocBuilder<EditComicCubit, EditComicState>(
                    builder: (context, editState) {
                      final loading = editState is EditComicLoading;
                      return FilledButton(
                        onPressed: loading
                            ? null
                            : () => formCubit.save(
                                  comic: comic,
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  productId: _productIdController.text,
                                ),
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                    onPressed: () {
                      _titleController.text = comic.title;
                      _descriptionController.text = comic.description;
                      _productIdController.text = comic.productId;
                      formCubit.startEdit(comic);
                    },
                    tooltip: 'Edit comic',
                  ),
                ],
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (form.isEditing)
                    ComicEditableHeaderSection(
                      comic: comic,
                      imageUrl: imageUrl,
                      titleController: _titleController,
                      onImagePicked: formCubit.setImageBytes,
                      newImageBytes: form.newImageBytes,
                    )
                  else
                    ComicHeaderSection(comic: comic, imageUrl: imageUrl),
                  if (form.isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              helperText: AppCopy.descriptionHelper,
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: ComicContentType.parse(form.contentType),
                            decoration: const InputDecoration(
                              labelText: 'Content type',
                              border: OutlineInputBorder(),
                            ),
                            items: ComicContentType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(ComicContentType.label(type)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              formCubit.setContentType(value);
                            },
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Free comic'),
                            subtitle: Text(
                              form.isFree
                                  ? AppCopy.freeComicOn
                                  : AppCopy.freeComicOff,
                            ),
                            value: form.isFree,
                            onChanged: formCubit.setFree,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _productIdController,
                            decoration: const InputDecoration(
                              labelText: 'Store Product ID (IAP) *',
                              border: OutlineInputBorder(),
                              hintText: AppCopy.productIdHint,
                              helperText: AppCopy.productIdHelper,
                              helperMaxLines: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Sensitive content'),
                            subtitle: const Text(AppCopy.sensitiveSubtitle),
                            value: form.isSensitive,
                            onChanged: formCubit.setSensitive,
                          ),
                        ],
                      ),
                    )
                  else
                    ComicDescriptionSection(description: comic.description),
                  ComicChaptersSection(comic: comic),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
