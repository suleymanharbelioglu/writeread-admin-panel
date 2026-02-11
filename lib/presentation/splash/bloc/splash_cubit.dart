import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/presentation/splash/bloc/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  static const Duration _splashDuration = Duration(seconds: 2);

  void appStarted() {
    Future.delayed(_splashDuration, () {
      emit(SplashNavigateToSignin());
    });
  }
}
