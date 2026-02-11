

import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/core/usecase/usecase.dart';
import 'package:writeread_admin_panel/data/auth/model/user_signin_req.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class SigninUseCase implements UseCase<Either,UserSigninReq> {

  @override
  Future<Either> call({UserSigninReq ? params}) async {
    return sl<AuthRepository>().signin(params!);
  }

}