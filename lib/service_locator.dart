import 'package:get_it/get_it.dart';
import 'package:writeread_admin_panel/data/auth/repository/auth_repository_impl.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service.dart';
import 'package:writeread_admin_panel/data/chapter/repository/chapter_repository_impl.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service_impl.dart';
import 'package:writeread_admin_panel/data/comic/repository/comic_repository_impl.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service_impl.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/is_admin.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/signin.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/signout.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/delete_last_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecase/update_chapter.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/delete_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/get_all_comics.dart';
import 'package:writeread_admin_panel/domain/comic/usecase/update_comic.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  //services
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<SigninUseCase>(SigninUseCase());
  sl.registerSingleton<SignoutUseCase>(SignoutUseCase());
  sl.registerSingleton<IsAdminUseCase>(IsAdminUseCase());

  sl.registerSingleton<ComicFirebaseService>(ComicFirebaseServiceImpl());

  //repositories
  sl.registerSingleton<ComicRepository>(ComicRepositoryImpl());
  sl.registerSingleton<GetAllComicsUseCase>(GetAllComicsUseCase());
  sl.registerSingleton<AddComicUseCase>(AddComicUseCase());
  sl.registerSingleton<UpdateComicUseCase>(UpdateComicUseCase());
  sl.registerSingleton<DeleteComicUseCase>(DeleteComicUseCase());
  //usecases
  sl.registerSingleton<ChapterFirebaseService>(ChapterFirebaseServiceImpl());
  sl.registerSingleton<ChapterRepository>(ChapterRepositoryImpl());
  sl.registerSingleton<DeleteLastChapterUseCase>(DeleteLastChapterUseCase());
  sl.registerSingleton<AddChapterUseCase>(AddChapterUseCase());
  sl.registerSingleton<UpdateChapterUseCase>(UpdateChapterUseCase());
  sl.registerSingleton<DeleteAllChapterImagesUseCase>(
    DeleteAllChapterImagesUseCase(),
  );
}
