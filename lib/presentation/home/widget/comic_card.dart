import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/images/image_display.dart';
import 'package:writeread_admin_panel/common/helper/images/storage_network_image.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/page/comic.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_cubit.dart';

class ComicCard extends StatelessWidget {
  const ComicCard({super.key, required this.comic});

  final ComicEntity comic;

  @override
  Widget build(BuildContext context) {
    final imageUrl = comic.image.isNotEmpty
        ? ImageDisplayHelper.generateComicImageURL(comic.image)
        : '';

    return GestureDetector(
      onTap: () async {
        await AppNavigator.push<void>(context, ComicPage.route(comic));
        if (context.mounted) {
          context.read<ComicsCubit>().loadComics();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (comic.image.isNotEmpty)
                    StorageNetworkImage(
                      url: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: _imagePlaceholder(),
                      loadingWidget: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    _imagePlaceholder(),
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
        size: 32,
      ),
    );
  }
}
