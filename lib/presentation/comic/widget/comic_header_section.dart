import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_image_address_row.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_info_row.dart';

class ComicHeaderSection extends StatelessWidget {
  const ComicHeaderSection({
    super.key,
    required this.comic,
    required this.imageUrl,
  });

  final ComicEntity comic;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comic.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ComicInfoRow(label: 'Comic ID', value: comic.comicId),
                ComicImageAddressRow(
                  label: 'Comic image address',
                  url: imageUrl,
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
                  value: comic.createdDate.toDate().toIso8601String().split('T').first,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 240,
              height: 340,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 64),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
