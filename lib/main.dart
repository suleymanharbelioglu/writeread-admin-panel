import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/core/configs/theme/app_theme.dart';
import 'package:writeread_admin_panel/firebase_options.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/current_comic_cubit.dart';
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
