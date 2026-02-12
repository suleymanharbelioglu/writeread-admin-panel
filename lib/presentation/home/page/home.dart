import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/get_all_comics.dart';
import 'package:writeread_admin_panel/presentation/add_comic/bloc/add_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/add_comic/page/add_comic.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_cubit.dart';
import 'package:writeread_admin_panel/presentation/home/bloc/comics_state.dart';
import 'package:writeread_admin_panel/presentation/home/widget/comic_card.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ComicsCubit(getAllComicsUseCase: sl<GetAllComicsUseCase>())
            ..loadComics(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => AddComicCubit(
                        addComicUseCase: sl<AddComicUseCase>(),
                      ),
                      child: const AddComicPage(),
                    ),
                  ),
                );
              },
              tooltip: 'Add new comic',
            ),
          ],
        ),
        body: BlocBuilder<ComicsCubit, ComicsState>(
          builder: (context, state) {
            if (state is ComicsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ComicsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.read<ComicsCubit>().loadComics(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is ComicsSuccess) {
              final comics = state.comics;
              if (comics.isEmpty) {
                return const Center(child: Text('No comics yet'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return ComicCard(comic: comics[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
