import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/domain/chapter/entity/chapter_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_state.dart';

class ComicPage extends StatelessWidget {
  const ComicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentComicCubit, CurrentComicState>(
      builder: (context, state) {
        if (state is! CurrentComicSet) {
          return Scaffold(
            appBar: AppBar(title: const Text('Comic')),
            body: const Center(child: Text('No comic selected')),
          );
        }
        final comic = state.comic;
        final imageUrl = comic.image.isNotEmpty
            ? ImageDisplayHelper.generateComicImageURL(comic.image)
            : ImageDisplayHelper.generateComicImageURL(comic.title);

        return Scaffold(
          appBar: AppBar(title: Text(comic.title)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
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
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(label: 'Comic ID', value: comic.comicId),
                            _ImageAddressRow(
                              label: 'Comic image address',
                              url: imageUrl,
                            ),
                            _InfoRow(
                              label: 'Category',
                              value: comic.categoryName,
                            ),
                            _InfoRow(
                              label: 'Category ID',
                              value: comic.categoryId,
                            ),
                            _InfoRow(
                              label: 'Likes',
                              value: comic.likeCount.toString(),
                            ),
                            _InfoRow(
                              label: 'Reads',
                              value: comic.readCount.toString(),
                            ),
                            _InfoRow(
                              label: 'Chapters',
                              value: comic.chapterCount.toString(),
                            ),
                            _InfoRow(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 240,
                          height: 340,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comic.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (comic.chapters.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapters (${comic.chapters.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...comic.chapters.map(
                          (ch) => _ChapterTile(
                            chapter: ch,
                            imageUrls:
                                ImageDisplayHelper.generateChapterImageURLs(ch),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ImageAddressRow extends StatelessWidget {
  const _ImageAddressRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            url,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatefulWidget {
  const _ChapterTile({required this.chapter, required this.imageUrls});

  final ChapterEntity chapter;
  final List<String> imageUrls;

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile> {
  bool _expanded = false;

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
                  Text(
                    'Chapter image addresses (${imageUrls.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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
