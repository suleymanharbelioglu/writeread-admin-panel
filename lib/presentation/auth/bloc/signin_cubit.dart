import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/auth/params/user_signin_req.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/signin.dart';
import 'package:writeread_admin_panel/presentation/auth/bloc/signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit({required SigninUseCase signinUseCase})
      : _signinUseCase = signinUseCase,
        super(const SigninState());

  final SigninUseCase _signinUseCase;

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(
      state.copyWith(status: SigninStatus.loading, clearError: true),
    );
    final result = await _signinUseCase.call(
      params: UserSigninReq(email: email, password: password),
    );
    if (isClosed) return;
    result.fold(
      (message) => emit(
        state.copyWith(
          status: SigninStatus.failure,
          errorMessage: message,
        ),
      ),
      (_) => emit(
        state.copyWith(status: SigninStatus.success, clearError: true),
      ),
    );
  }
}
