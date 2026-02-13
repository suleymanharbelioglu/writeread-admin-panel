import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/page/comic.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_cubit.dart';

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
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ComicPage()))
            .then((value) {
              if (value == true) {
                context.read<ComicsCubit>().loadComics();
              }
            });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(imageUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        color: Colors.white,
                        child: Text(
                          comic.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
