import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_feedback.dart';
import 'package:writeread_admin_panel/domain/auth/usecases/signin.dart';
import 'package:writeread_admin_panel/presentation/auth/bloc/signin_cubit.dart';
import 'package:writeread_admin_panel/presentation/auth/bloc/signin_state.dart';
import 'package:writeread_admin_panel/service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Format hints only; empty/business rules live in SigninUseCase.
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (!EmailValidator.validate(email)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SigninCubit>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _handleSigninState(BuildContext context, SigninState state) {
    if (state.status == SigninStatus.success) {
      // AuthGate watches FirebaseAuth and routes to the admin check / Home.
      AppFeedback.showSuccess(context, 'Signed in successfully');
    }
    if (state.status == SigninStatus.failure && state.errorMessage != null) {
      AppFeedback.showError(context, state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SigninCubit(signinUseCase: sl<SigninUseCase>()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sign in')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Admin panel — sign in with your admin account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<SigninCubit, SigninState>(
                      buildWhen: (prev, curr) =>
                          prev.obscurePassword != curr.obscurePassword,
                      builder: (context, state) {
                        return TextFormField(
                          controller: _passwordController,
                          obscureText: state.obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => context
                                  .read<SigninCubit>()
                                  .toggleObscurePassword(),
                            ),
                          ),
                          validator: _validatePassword,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocConsumer<SigninCubit, SigninState>(
                      listenWhen: (prev, curr) => prev.status != curr.status,
                      listener: (context, state) =>
                          _handleSigninState(context, state),
                      buildWhen: (prev, curr) =>
                          prev.isLoading != curr.isLoading,
                      builder: (context, state) {
                        final loading = state.isLoading;
                        return ElevatedButton(
                          onPressed: loading ? null : () => _submit(context),
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Log in'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
