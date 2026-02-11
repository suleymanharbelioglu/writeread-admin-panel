import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/core/configs/theme/app_colors.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/page/comic.dart';

class ComicCard extends StatelessWidget {
  const ComicCard({super.key, required this.comic});

  final ComicEntity comic;

  @override
  Widget build(BuildContext context) {
    final imageUrl = comic.image.isNotEmpty
        ? ImageDisplayHelper.generateComicImageURL(comic.image)
        : ImageDisplayHelper.generateComicImageURL(comic.title);

    return GestureDetector(
      onTap: () {
        context.read<CurrentComicCubit>().setComic(comic);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ComicPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      comic.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comic.categoryName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_outline,
                                  size: 15,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  comic.likeCount.toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                comic.readCount.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
