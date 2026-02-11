import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class IsAdminUseCase implements UseCase<Either<String, bool>, dynamic> {
  @override
  Future<Either<String, bool>> call({dynamic params}) async {
    return sl<AuthRepository>().isAdmin();
  }
}
