import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/data/auth/model/user_signin_req.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/signin.dart';
import 'package:writeread_admin_panel/presentation/auth/cubit/signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit({required SigninUseCase signinUseCase})
      : _signinUseCase = signinUseCase,
        super(const SigninInitial());

  final SigninUseCase _signinUseCase;

  Future<void> signIn({required String email, required String password}) async {
    emit(const SigninLoading());
    final result = await _signinUseCase.call(
      params: UserSigninReq(email: email, password: password),
    );
    result.fold(
      (message) => emit(SigninError(message: message is String ? message : message.toString())),
      (_) => emit(const SigninSuccess()),
    );
  }
}
