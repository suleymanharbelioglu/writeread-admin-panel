enum SigninStatus { initial, loading, success, failure }

class SigninState {
  const SigninState({
    this.obscurePassword = true,
    this.status = SigninStatus.initial,
    this.errorMessage,
  });

  final bool obscurePassword;
  final SigninStatus status;
  final String? errorMessage;

  bool get isLoading => status == SigninStatus.loading;

  SigninState copyWith({
    bool? obscurePassword,
    SigninStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SigninState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
