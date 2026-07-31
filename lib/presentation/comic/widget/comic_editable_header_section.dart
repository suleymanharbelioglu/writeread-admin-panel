import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/common/helper/files/app_file_picker.dart';
import 'package:writeread_admin_panel/common/helper/images/storage_network_image.dart';
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
                    helperText: 'Shown to readers as the comic title.',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ComicInfoRow(label: 'ID', value: comic.comicId),
                ComicImageAddressRow(
                  label: 'Cover file',
                  url: displayImageUrl ?? imageUrl,
                ),
                ComicInfoRow(label: 'Category', value: comic.categoryName),
                Text(
                  'Category can\'t be changed here — set it carefully when creating the comic.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                ComicInfoRow(label: 'Likes', value: comic.likeCount.toString()),
                ComicInfoRow(label: 'Reads', value: comic.readCount.toString()),
                ComicInfoRow(
                  label: 'Sensitive',
                  value: comic.isSensitive ? 'Yes' : 'No',
                ),
                ComicInfoRow(
                  label: 'Chapters',
                  value: comic.chapterCount.toString(),
                ),
                ComicInfoRow(
                  label: 'Created',
                  value: comic.createdDate.toIso8601String().split('T').first,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the cover or camera icon to change the image. '
                  'Recommended: portrait JPG or PNG.',
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
                    : StorageNetworkImage(
                        url: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: const Center(
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
    final bytes = await AppFilePicker.pickImageBytes();
    if (bytes == null) return;
    onImagePicked(bytes);
  }
}
