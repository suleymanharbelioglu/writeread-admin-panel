import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class SignoutUseCase implements UseCase<Either, dynamic> {
  @override
  Future<Either> call({dynamic params}) async {
    return sl<AuthRepository>().signout();
  }
}
