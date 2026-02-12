import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/core/configs/theme/app_theme.dart';
import 'package:writeread_admin_panel/firebase_options.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_last_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/delete_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/add_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/delete_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_chapter_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/edit_comic_cubit.dart';
import 'package:writeread_admin_panel/presentation/splash/bloc/splash_cubit.dart';
import 'package:writeread_admin_panel/presentation/splash/page/splash.dart';
import 'package:writeread_admin_panel/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  // await addSampleCategoriesToFirestore();
  // await addSampleComicsToFirestore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()..appStarted()),
        BlocProvider(create: (_) => CurrentComicCubit()),
        BlocProvider(
          create: (_) => DeleteChapterCubit(
            deleteLastChapterUseCase: sl<DeleteLastChapterUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) =>
              DeleteComicCubit(deleteComicUseCase: sl<DeleteComicUseCase>()),
        ),
        BlocProvider(
          create: (_) =>
              AddChapterCubit(addChapterUseCase: sl<AddChapterUseCase>()),
        ),
        BlocProvider(
          create: (_) =>
              EditComicCubit(updateComicUseCase: sl<UpdateComicUseCase>()),
        ),
        BlocProvider(
          create: (_) => EditChapterCubit(
            updateChapterUseCase: sl<UpdateChapterUseCase>(),
            deleteAllChapterImagesUseCase: sl<DeleteAllChapterImagesUseCase>(),
          ),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Comics App',
        theme: AppTheme.appTheme,
        home: SplashPage(),
      ),
    );
  }
}
