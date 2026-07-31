import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writeread_admin_panel/core/constants/firestore_collections.dart';
import 'package:writeread_admin_panel/core/error/firebase_error_mapper.dart';
import 'package:writeread_admin_panel/data/auth/source/auth_firebase_service.dart';
import 'package:writeread_admin_panel/domain/auth/params/user_signin_req.dart';

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either<String, bool>> signin(UserSigninReq user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      return const Right(true);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Sign in',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Sign out',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<String, bool>> isAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left('Not signed in');
      }
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.admins)
          .doc(user.uid)
          .get();
      return Right(doc.exists);
    } catch (e, stackTrace) {
      return Left(
        FirebaseErrorMapper.map(
          e,
          action: 'Check admin',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
