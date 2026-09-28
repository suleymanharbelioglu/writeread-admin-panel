import 'package:get_it/get_it.dart';
import 'package:writeread_admin_panel/data/auth/repository/auth_repository_impl.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service_impl.dart';
import 'package:writeread_admin_panel/data/chapter/repository/chapter_repository_impl.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service.dart';
import 'package:writeread_admin_panel/data/chapter/source/chapter_firebase_service_impl.dart';
import 'package:writeread_admin_panel/data/comic/repository/comic_repository_impl.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service.dart';
import 'package:writeread_admin_panel/data/comic/source/comic_firebase_service_impl.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth_repository.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/is_admin.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/signin.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/signout.dart';
import 'package:writeread_admin_panel/domain/chapter/repository/chapter_repository.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/add_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_all_chapter_images.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/delete_last_chapter.dart';
import 'package:writeread_admin_panel/domain/chapter/usecases/update_chapter.dart';
import 'package:writeread_admin_panel/domain/comic/repository/comic_repository.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/add_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_chapter_pages.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/clear_locale_cover.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/delete_locale.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/get_all_comics.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_comic.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/update_locale_metadata.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upload_locale_cover.dart';
import 'package:writeread_admin_panel/domain/comic/usecases/upsert_locale_chapter.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data sources
  sl.registerLazySingleton<AuthFirebaseService>(AuthFirebaseServiceImpl.new);
  sl.registerLazySingleton<ComicFirebaseService>(ComicFirebaseServiceImpl.new);
  sl.registerLazySingleton<ChapterFirebaseService>(
    ChapterFirebaseServiceImpl.new,
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ComicRepository>(
    () => ComicRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChapterRepository>(
    () => ChapterRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerFactory(() => SigninUseCase(sl()));
  sl.registerFactory(() => SignoutUseCase(sl()));
  sl.registerFactory(() => IsAdminUseCase(sl()));
  sl.registerFactory(() => GetAllComicsUseCase(sl()));
  sl.registerFactory(() => AddComicUseCase(sl()));
  sl.registerFactory(() => UpdateComicUseCase(sl()));
  sl.registerFactory(() => DeleteComicUseCase(sl()));
  sl.registerFactory(() => AddChapterUseCase(sl()));
  sl.registerFactory(() => UpdateChapterUseCase(sl()));
  sl.registerFactory(() => DeleteLastChapterUseCase(sl()));
  sl.registerFactory(() => DeleteAllChapterImagesUseCase(sl()));
  sl.registerFactory(() => UpdateLocaleMetadataUseCase(sl()));
  sl.registerFactory(() => UpsertLocaleChapterUseCase(sl()));
  sl.registerFactory(() => ClearLocaleChapterPagesUseCase(sl()));
  sl.registerFactory(() => DeleteLocaleUseCase(sl()));
  sl.registerFactory(() => UploadLocaleCoverUseCase(sl()));
  sl.registerFactory(() => ClearLocaleCoverUseCase(sl()));
}
