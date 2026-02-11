sealed class IsAdminState {}

final class IsAdminInitial extends IsAdminState {}

final class IsAdminLoading extends IsAdminState {}

final class IsAdminSuccess extends IsAdminState {}

final class IsAdminNotAdmin extends IsAdminState {
  IsAdminNotAdmin({required this.message});
  final String message;
}
