import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_image_address_row.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_info_row.dart';

class ComicEditableHeaderSection extends StatelessWidget {
  const ComicEditableHeaderSection({
    super.key,
    required this.comic,
    required this.imageUrl,
    required this.titleController,
    required this.onImagePicked,
    this.newImageBytes,
  });

  final ComicEntity comic;
  final String imageUrl;
  final TextEditingController titleController;
  final void Function(List<int> bytes) onImagePicked;
  final List<int>? newImageBytes;

  @override
  Widget build(BuildContext context) {
    final displayImageUrl = newImageBytes != null && newImageBytes!.isNotEmpty
        ? null
        : imageUrl;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ComicInfoRow(label: 'Comic ID', value: comic.comicId),
                ComicImageAddressRow(
                  label: 'Comic image address',
                  url: displayImageUrl ?? imageUrl,
                ),
                ComicInfoRow(label: 'Category', value: comic.categoryName),
                ComicInfoRow(label: 'Category ID', value: comic.categoryId),
                ComicInfoRow(label: 'Likes', value: comic.likeCount.toString()),
                ComicInfoRow(label: 'Reads', value: comic.readCount.toString()),
                ComicInfoRow(
                  label: 'Chapters',
                  value: comic.chapterCount.toString(),
                ),
                ComicInfoRow(
                  label: 'Created',
                  value: comic.createdDate
                      .toDate()
                      .toIso8601String()
                      .split('T')
                      .first,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => _pickImage(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 240,
                height: 340,
                child: newImageBytes != null && newImageBytes!.isNotEmpty
                    ? Image.memory(
                        Uint8List.fromList(newImageBytes!),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined, size: 64),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () => _pickImage(context),
            tooltip: 'Change cover image',
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.bytes == null) return;
    final bytes = result.files.single.bytes!.buffer.asUint8List().toList();
    onImagePicked(bytes);
  }
}
