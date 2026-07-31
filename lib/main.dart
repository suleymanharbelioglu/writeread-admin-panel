import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/core/configs/theme/app_theme.dart';
import 'package:writeread_admin_panel/firebase_options.dart';
import 'package:writeread_admin_panel/presentation/auth/page/signin.dart';
import 'package:writeread_admin_panel/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chapt',
      theme: AppTheme.appTheme,
      home: const SigninPage(),
    );
  }
}
