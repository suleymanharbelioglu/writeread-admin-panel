import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/auth/model/user_signin_req.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either<String, bool>> signin(UserSigninReq user) async {
    return sl<AuthFirebaseService>().signin(user);
  }

  @override
  Future<Either<String, void>> signout() async {
    return sl<AuthFirebaseService>().signout();
  }

  @override
  Future<Either<String, bool>> isAdmin() async {
    return sl<AuthFirebaseService>().isAdmin();
  }
}
