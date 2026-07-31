import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/widgets/info_tip.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/get_all_comics.dart';
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
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _openAddComic(BuildContext context) async {
    // AddComicPage replaces itself with ComicPage on success, so this returns
    // only once the whole add/detail flow is popped back to Home.
    await AppNavigator.push<void>(
      context,
      BlocProvider(
        create: (_) => AddComicCubit(addComicUseCase: sl<AddComicUseCase>()),
        child: const AddComicPage(),
      ),
    );
    if (!context.mounted) return;
    context.read<ComicsCubit>().loadComics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddComic(context),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No comics yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + in the top right to add your first comic. '
                        'You will set the title, category, store product ID, '
                        'and cover, then add chapters.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _openAddComic(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add your first comic'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InfoTip(message: AppCopy.homeTip),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: comics.length,
                    itemBuilder: (context, index) {
                      return ComicCard(comic: comics[index]);
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
