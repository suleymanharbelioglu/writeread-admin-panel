import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writeread_admin_panel/data/auth/model/user_signin_req.dart';

abstract class AuthFirebaseService {
  Future<Either<String, bool>> signin(UserSigninReq user);
  Future<Either<String, void>> signout();
  Future<Either<String, bool>> isAdmin();
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  static const String _adminsCollection = 'admins';

  @override
  Future<Either<String, bool>> signin(UserSigninReq user) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );
      return const Right(true);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Not user found for this email';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for this user';
      }
      return Left(message);
    }
  }

  @override
  Future<Either<String, void>> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right(null);
    } catch (e) {
      return const Left('Please try again.');
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
          .collection(_adminsCollection)
          .doc(user.uid)
          .get();
      return Right(doc.exists);
    } catch (e) {
      return Left('Failed to check admin status');
    }
  }
}
