import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/presentation/auth/page/signin.dart';
import 'package:writeread_admin_panel/presentation/is_admin/page/is_admin.dart';

/// Root session router: signed-out → Sign-in; signed-in → admin check → Home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _lastUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;

        if (_lastUser != null && user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.navigatorKey?.currentState?.popUntil((route) => route.isFirst);
          });
        }
        _lastUser = user;

        if (snapshot.connectionState == ConnectionState.waiting &&
            user == null &&
            !snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Starting…'),
                ],
              ),
            ),
          );
        }

        if (user == null) {
          return const SigninPage();
        }
        return const IsAdminPage();
      },
    );
  }
}
