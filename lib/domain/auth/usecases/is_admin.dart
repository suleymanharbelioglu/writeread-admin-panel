import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth_repository.dart';

class IsAdminUseCase implements UseCase<Either<String, bool>, void> {
  IsAdminUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<String, bool>> call({void params}) {
    return _authRepository.isAdmin();
  }
}
