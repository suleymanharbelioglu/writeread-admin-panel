import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/is_admin.dart';
import 'package:writeread_admin_panel/domain/auth/usecase/signout.dart';
import 'package:writeread_admin_panel/presentation/auth/page/signin.dart';
import 'package:writeread_admin_panel/presentation/home/page/home.dart';
import 'package:writeread_admin_panel/presentation/is_admin/bloc/is_admin_cubit.dart';
import 'package:writeread_admin_panel/presentation/is_admin/bloc/is_admin_state.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class IsAdminPage extends StatelessWidget {
  const IsAdminPage({super.key});

  void _handleState(BuildContext context, IsAdminState state) {
    if (state is IsAdminSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are an admin.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
    if (state is IsAdminNotAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SigninPage()),
      );
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
          return Scaffold(
            appBar: AppBar(title: const Text('Checking access')),
            body: Center(
              child: state is IsAdminLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verifying admin...'),
            ),
          );
        },
      ),
    );
  }
}
