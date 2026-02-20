import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/core/configs/theme/app_colors.dart';
import 'package:writeread_admin_panel/presentation/auth/page/signin.dart';
import 'package:writeread_admin_panel/presentation/splash/bloc/splash_cubit.dart';
import 'package:writeread_admin_panel/presentation/splash/bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToSignin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SigninPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Text(
            'writeread admin panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
