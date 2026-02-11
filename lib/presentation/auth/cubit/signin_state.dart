sealed class SigninState {
  const SigninState();
}

final class SigninInitial extends SigninState {
  const SigninInitial();
}

final class SigninLoading extends SigninState {
  const SigninLoading();
}

final class SigninSuccess extends SigninState {
  const SigninSuccess();
}

final class SigninError extends SigninState {
  const SigninError({required this.message});
  final String message;
}
