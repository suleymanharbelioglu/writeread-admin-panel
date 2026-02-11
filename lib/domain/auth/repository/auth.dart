import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/auth/model/user_signin_req.dart';

abstract class AuthRepository {
  Future<Either<String, bool>> signin(UserSigninReq user);
  Future<Either<String, void>> signout();
  Future<Either<String, bool>> isAdmin();
}
