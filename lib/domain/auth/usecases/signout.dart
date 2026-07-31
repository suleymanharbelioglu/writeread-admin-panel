import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth_repository.dart';

class SignoutUseCase implements UseCase<Either<String, void>, void> {
  SignoutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<String, void>> call({void params}) {
    return _authRepository.signout();
  }
}
