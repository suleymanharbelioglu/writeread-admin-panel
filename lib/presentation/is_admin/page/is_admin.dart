import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_feedback.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/is_admin.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/signout.dart';
import 'package:writeread_admin_panel/presentation/home/page/home.dart';
import 'package:writeread_admin_panel/presentation/is_admin/bloc/is_admin_cubit.dart';
import 'package:writeread_admin_panel/presentation/is_admin/bloc/is_admin_state.dart';
import 'package:writeread_admin_panel/service_locator.dart';

/// Checks admin claim after AuthGate sees a signed-in user.
/// Success → [HomePage]. Failure → signs out (AuthGate returns to Sign-in).
class IsAdminPage extends StatelessWidget {
  const IsAdminPage({super.key});

  void _handleState(BuildContext context, IsAdminState state) {
    if (state is IsAdminNotAdmin) {
      AppFeedback.showError(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IsAdminCubit(
        isAdminUseCase: sl<IsAdminUseCase>(),
        signoutUseCase: sl<SignoutUseCase>(),
      )..checkAdmin(),
      child: BlocConsumer<IsAdminCubit, IsAdminState>(
        listener: _handleState,
        builder: (context, state) {
          if (state is IsAdminSuccess) {
            return const HomePage();
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Checking access')),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Checking whether this account can manage comics…',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
