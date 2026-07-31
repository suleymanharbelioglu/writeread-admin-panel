import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/auth/params/user_signin_req.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth_repository.dart';

class SigninUseCase
    implements UseCase<Either<String, bool>, UserSigninReq> {
  SigninUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<String, bool>> call({UserSigninReq? params}) async {
    if (params == null) return const Left('Sign in params required');
    if (params.email.trim().isEmpty) return const Left('Email is required');
    if (params.password.isEmpty) return const Left('Password is required');
    return _authRepository.signin(params);
  }
}
