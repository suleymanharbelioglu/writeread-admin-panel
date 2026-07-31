import 'package:dartz/dartz.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service.dart';
import 'package:writeread_admin_panel/domain/auth/params/user_signin_req.dart';
import 'package:writeread_admin_panel/domain/auth/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._authFirebaseService);

  final AuthFirebaseService _authFirebaseService;

  @override
  Future<Either<String, bool>> signin(UserSigninReq user) {
    return _authFirebaseService.signin(user);
  }

  @override
  Future<Either<String, void>> signout() {
    return _authFirebaseService.signout();
  }

  @override
  Future<Either<String, bool>> isAdmin() {
    return _authFirebaseService.isAdmin();
  }
}
