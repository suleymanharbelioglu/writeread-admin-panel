import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/domain/auth/params/user_signin_req.dart';

abstract class AuthFirebaseService {
  Future<Either<String, bool>> signin(UserSigninReq user);
  Future<Either<String, void>> signout();
  Future<Either<String, bool>> isAdmin();
}
