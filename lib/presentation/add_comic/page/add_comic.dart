import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic_params.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_state.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
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
  List<int>? _imageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes != null && file.bytes!.lengthInBytes > 0) {
      setState(() => _imageBytes = file.bytes!.buffer.asUint8List().toList());
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }
    context.read<AddComicCubit>().addComic(
          AddComicParams(
            title: title,
            description: _descriptionController.text.trim(),
            categoryName: _categoryNameController.text.trim(),
            imageBytes: _imageBytes,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddComicCubit, AddComicState>(
      listener: (context, state) {
        if (state is AddComicSuccess) {
          context.read<CurrentComicCubit>().setComic(state.comic);
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ComicPage()),
          );
        } else if (state is AddComicFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add new comic'),
          actions: [
            BlocBuilder<AddComicCubit, AddComicState>(
              buildWhen: (prev, curr) =>
                  curr is AddComicLoading || curr is AddComicInitial || curr is AddComicFailure,
              builder: (context, state) {
                final loading = state is AddComicLoading;
                return loading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: loading ? null : _submit,
                        child: const Text('Save'),
                      );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AddComicCubit, AddComicState>(
                buildWhen: (prev, curr) =>
                    curr is AddComicLoading || curr is AddComicInitial,
                builder: (context, state) {
                  final loading = state is AddComicLoading;
                  return OutlinedButton.icon(
                    onPressed: loading ? null : _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(
                      _imageBytes != null
                          ? 'Change image'
                          : 'Pick image from folder',
                    ),
                  );
                },
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Image selected (${(_imageBytes!.length / 1024).toStringAsFixed(1)} KB)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
