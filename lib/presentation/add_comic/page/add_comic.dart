import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_feedback.dart';
import 'package:writeread_admin_panel/common/widgets/info_tip.dart';
import 'package:writeread_admin_panel/common/widgets/loading_overlay.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/page/comic.dart';

class AddComicPage extends StatefulWidget {
  const AddComicPage({super.key});

  @override
  State<AddComicPage> createState() => _AddComicPageState();
}

class _AddComicPageState extends State<AddComicPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _productIdController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _productIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final bytes = await AppFilePicker.pickImageBytes();
    if (!mounted || bytes == null) return;
    context.read<AddComicCubit>().setImageBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddComicCubit, AddComicState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == AddComicStatus.success ||
              curr.status == AddComicStatus.failure),
      listener: (context, state) {
        final comic = state.comic;
        if (state.status == AddComicStatus.success && comic != null) {
          AppNavigator.pushReplacement<void>(context, ComicPage.route(comic));
          return;
        }
        if (state.status == AddComicStatus.failure &&
            state.errorMessage != null) {
          AppFeedback.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddComicCubit>();
        final loading = state.isLoading;

        return LoadingOverlay(
          isLoading: loading,
          message: loading ? 'Saving comic...' : null,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add new comic'),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => cubit.submit(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            categoryName: _categoryNameController.text,
                            productId: _productIdController.text,
                          ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const InfoTip(message: AppCopy.addComicTip),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      helperText: AppCopy.titleHelper,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      helperText: AppCopy.descriptionHelper,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryNameController,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      border: OutlineInputBorder(),
                      helperText: AppCopy.categoryHelper,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Free comic'),
                    subtitle: Text(
                      state.isFree ? AppCopy.freeComicOn : AppCopy.freeComicOff,
                    ),
                    value: state.isFree,
                    onChanged: loading ? null : cubit.setFree,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _productIdController,
                    enabled: !loading,
                    decoration: const InputDecoration(
                      labelText: 'Store Product ID (IAP) *',
                      border: OutlineInputBorder(),
                      hintText: AppCopy.productIdHint,
                      helperText: AppCopy.productIdHelper,
                      helperMaxLines: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sensitive content'),
                    subtitle: const Text(AppCopy.sensitiveSubtitle),
                    value: state.isSensitive,
                    onChanged: loading ? null : cubit.setSensitive,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: loading ? null : _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(
                      state.imageBytes != null
                          ? 'Change image'
                          : 'Pick image from folder',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppCopy.coverHelper,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  if (state.imageBytes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Image selected (${(state.imageBytes!.length / 1024).toStringAsFixed(1)} KB)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
